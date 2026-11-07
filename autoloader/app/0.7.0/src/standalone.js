// Run inline payloads in order using the loader API and shared session state.

import {
  createPayloadSession,
  createSessionState,
  executePayload,
  withDeadline,
  LOADER_VERSION,
  PAYLOAD_TIMEOUT_MS,
} from "./loader.js";

function screenLog(message, type = "log") {
  if (typeof window !== "undefined" && typeof window.writeLog === "function") {
    window.writeLog(message, type);
  } else {
    console.log(`[${type}] ${message}`);
  }
}
screenLog.startBox = (opts) => {
  if (typeof window !== "undefined" && typeof window.startLogBox === "function") {
    return window.startLogBox(opts);
  }
};
screenLog.endBox = () => {
  if (typeof window !== "undefined" && typeof window.endLogBox === "function") {
    return window.endLogBox();
  }
};

function noSocketSendBlob(bytes) {
  const length = bytes instanceof Uint8Array ? bytes.length : (bytes && bytes.length) || 0;
  throw new Error(
    `api.sendBlob(${length} bytes) has no destination: this page carries its payloads ` +
    `inline and is not serving a client. Use the payload as-is with the remote ` +
    `loader (tools/send.py), or write the bytes somewhere with api.p instead.`);
}

// Run { name, source, args } entries; report failures and continue unless the
// current payload explicitly requests api.stopQueue(). Finish its cleanup first.
export async function runPayloadQueue({ p, chain, payloads, onPayload }) {
  const say = screenLog;
  const queue = Array.isArray(payloads) ? payloads : [];
  const state = createSessionState(p, chain);

  say(`standalone runner v${LOADER_VERSION}: ${queue.length} payload(s) inline, no socket`, "success");
  if (queue.length === 0) {
    say(`nothing to run -- this file was built with an empty payload list`, "warn");
    return { run: 0, failed: 0, ok: false };
  }

  let run = 0;
  let failed = 0;
  let stopped = false;
  let stopReason = "";

  for (let i = 0; i < queue.length; i++) {
    const entry = queue[i];
    const label = entry.name || `payload ${i + 1}`;
    const args = Array.isArray(entry.args) ? entry.args : [];

    say(``, "info");
    say(`=== [${i + 1}/${queue.length}] ${label} ===`, "success");
    if (args.length) {
      say(`args: ${args.join(" ")}`, "info");
    }
    if (typeof onPayload === "function") {
      onPayload({ index: i, name: label, total: queue.length });
    }

    // Each payload gets its own API guards and shares session krw.
    const deadlineControl = { reset: null };
    let active = true;
    const api = createPayloadSession({
      p, chain, say, state, deadlineControl,
      log: async (message, type) => { say(message, type); },
      sendBlob: noSocketSendBlob,
      args,
      stopQueue: (reason) => {
        // A timer left behind by a completed payload cannot stop a later one.
        if (!active) return false;
        stopped = true;
        stopReason = reason == null ? `requested by ${label}` : String(reason);
        return true;
      },
    });

    let code = entry.source;
    if (typeof code !== "string" && entry.url) {
      try {
        const resp = await fetch(entry.url);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        code = await resp.text();
      } catch (e) {
        say(`could not load payload from ${entry.url}: ${e && e.message ? e.message : e}`, "error");
        failed++;
        continue;
      }
    }

    const size = typeof code === "string"
      ? new TextEncoder().encode(code).length
      : 0;

    let outcome;
    try {
      outcome = await withDeadline(
        executePayload({ code, size, api, log: api.log, say, servedCount: i + 1 }),
        PAYLOAD_TIMEOUT_MS,
        (ms) => say(`payload has run for ${ms / 1000}s and has not returned`, "error"),
        (reset) => { deadlineControl.reset = reset; },
      );
    } catch (e) {
      // executePayload reports payload errors; this catch covers runner failures.
      say(`payload could not be started: ${e && e.message ? e.message : e}`, "error");
      outcome = { failed: true };
    } finally {
      active = false;
    }

    if (outcome === "overran" || (outcome && outcome.failed)) {
      failed++;
    } else {
      run++;
    }

    if (stopped) {
      const skipped = queue.length - i - 1;
      say(``, "info");
      say(`=== queue stopped: ${stopReason}; ${skipped} payload(s) skipped ===`,
        failed === 0 ? "info" : "error");
      return { run, failed, total: queue.length, skipped, stopped: true,
        reason: stopReason, ok: failed === 0, state };
    }

    if (state.krw) {
      say(`kernel R/W carried into the next payload`, "info");
    }
  }

  say(``, "info");
  say(`=== queue finished: ${run}/${queue.length} completed, ${failed} failed ===`,
    failed === 0 ? "success" : "error");
  say(`krw ${state.krw ? "established" : "not established"}`, "info");

  return { run, failed, total: queue.length, ok: failed === 0, state };
}
