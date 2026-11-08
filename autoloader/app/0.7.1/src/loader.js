// loader.js — remote payload loader over WebKit userland ARW + ROP.
// Accepts JavaScript payloads over TCP, runs them in the page realm, and streams logs back.

import { int64 } from "./utils/int64.js";
import {
  CALL, openListener, acceptOnce, readBytes, writeBytes, closeFd,
  pushBytes, pullBytes, isFailure, isUnexpected, describe,
} from "./net.js";
import { DEFAULT_BINARIES } from "./binaries.js";

const DEFAULT_PORT = 9027;
const ACCEPT_TIMEOUT_MS = 300 * 1000;
export const PAYLOAD_TIMEOUT_MS = 10 * 60 * 1000;
export const LOADER_VERSION = "0.2.2";

// Race a promise against a deadline, resolving "overran" if exceeded.
export function withDeadline(work, ms, onOverrun, configure) {
  let timer;
  let fired = false;
  let finished = false;
  let reset;
  const deadline = new Promise((resolve) => {
    reset = (duration) => {
      if (!Number.isInteger(duration) || duration < 0 || duration > 0x7fffffff)
        throw new RangeError("payload timeout must be an integer from 0 to 2147483647 ms");
      if (finished || fired) throw new Error("payload deadline is no longer active");
      clearTimeout(timer);
      if (duration === 0) return; // Explicitly long-running payload.
      timer = setTimeout(() => {
        fired = true;
        if (onOverrun) onOverrun(duration);
        resolve("overran");
      }, duration);
    };
    reset(ms);
  });
  if (configure) configure(reset);
  return Promise.race([
    work.then(
      (v) => (fired ? "overran" : v),
      (e) => (fired ? "overran" : Promise.reject(e)),
    ),
    deadline,
  ]).finally(() => { finished = true; clearTimeout(timer); });
}

const CMD_MAGIC = 0xffffffff;
const ARGV_MAGIC = 0xfffffffe;

const READ_BUF = 32 * 1024;
const WRITE_BUF = 8 * 1024;
const MAX_PAYLOAD = 512 * 1024;
const MALLOC_LIMIT = 1024 * 1024;

// 1 MiB window per system library (mapped execute-only)
const XOTEXT_WINDOW = 0x100000;

function xotextRanges(p) {
  const out = [];
  for (const [name, base] of [
    ["libSceNKWebKit", p.libSceNKWebKitBase],
    ["libSceLibcInternal", p.libSceLibcInternalBase],
    ["libkernel", p.libKernelBase],
  ]) {
    if (!base) continue;
    const start = base.low >>> 0;
    out.push({ name, start, end: (start + XOTEXT_WINDOW) >>> 0 });
  }
  return out;
}

const COMMANDS = {
  0: "disconnect",
  1: "status",
  2: "list",
};

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const SYS_NETGETIFLIST = 0x07d;

async function getConsoleIp(p, chain) {
  try {
    if (p.syscalls && p.syscalls[SYS_NETGETIFLIST]) {
      const countRes = await chain.syscall(SYS_NETGETIFLIST, 0, 10);
      const count = (countRes && typeof countRes.low === "number") ? (countRes.low | 0) : 0;
      if (count > 0 && count <= 32) {
        const list = p.malloc(0x3c0 * count, 1);
        const rv = await chain.syscall(SYS_NETGETIFLIST, list, count);
        if (rv && rv.low >= 0) {
          for (let i = 0; i < count; i++) {
            const base = list.add32(0x3c0 * i);
            const flags = p.read4(base.add32(0x20));
            const isUp = (flags & 1) !== 0;
            if (!isUp) continue;
            const ipBytes = [0, 1, 2, 3].map(b => p.read1(base.add32(40 + b)));
            const ip = ipBytes.join(".");
            if (ip !== "0.0.0.0" && !ip.startsWith("127.")) {
              return ip;
            }
          }
        }
      }
    }
  } catch (e) {}
  if (typeof window !== "undefined" && window.location && window.location.hostname) {
    const host = window.location.hostname;
    if (host && host !== "localhost" && !host.startsWith("127.")) {
      return host;
    }
  }
  return "127.0.0.1";
}

function findPayloadLocation(e, code) {
  if (!code) return null;
  const codeLines = code.split("\n");
  const stack = String((e && e.stack) || "");
  const stackLines = stack.split("\n");

  // 1. Scan stack frames for explicit payload.js references
  const rePayload = /(?:at |@)?(?:.*[ (])?(?:payload\.js):(\d+)(?::(\d+))?/;
  for (const rawLine of stackLines) {
    if (/loader\.js|site\.js|rop\.js|kexp\.js/i.test(rawLine)) continue;
    const m = rawLine.match(rePayload);
    if (m) {
      const evalLine = parseInt(m[1], 10);
      const col = m[2] ? parseInt(m[2], 10) : undefined;
      // runner wraps in `(async function () {\n${code}\n//# sourceURL=payload.js\n})`
      // Line 1 is the wrapper header, so line L in eval is line L - 1 in code.
      const payloadLine = evalLine > 1 ? evalLine - 1 : evalLine;
      const snippet = (payloadLine >= 1 && payloadLine <= codeLines.length)
        ? codeLines[payloadLine - 1]
        : "";
      return { line: payloadLine, col, snippet };
    }
  }

  // 2. Check e.line and e.column (JavaScriptCore native properties on Error)
  if (typeof e?.line === "number" && e.line > 0) {
    const srcUrl = String(e.sourceURL || "");
    if (/(?:^|\/)payload\.js$/.test(srcUrl)) {
      const evalLine = e.line;
      const payloadLine = evalLine > 1 ? evalLine - 1 : evalLine;
      const snippet = (payloadLine >= 1 && payloadLine <= codeLines.length)
        ? codeLines[payloadLine - 1]
        : "";
      return { line: payloadLine, col: e.column, snippet };
    }
  }

  // 3. Fallback: inspect function names in stack frames (e.g. JSC eval frames without file:line)
  for (const rawLine of stackLines) {
    if (/loader\.js|site\.js|rop\.js|kexp\.js|lua-vm\.js/i.test(rawLine)) continue;
    const fnMatch = rawLine.match(/^\s*(?:at\s+)?([a-zA-Z0-9_$]+)@/);
    if (fnMatch) {
      const fnName = fnMatch[1];
      if (fnName === "payload" || fnName === "eval" || fnName === "anonymous") continue;
      for (let i = 0; i < codeLines.length; i++) {
        const lineText = codeLines[i];
        if (lineText.includes(`function ${fnName}`) || lineText.includes(`${fnName} =`) || lineText.includes(`${fnName}(`)) {
          return { line: i + 1, snippet: lineText };
        }
      }
    }
  }

  return null;
}

function formatStackFrames(stack) {
  if (!stack) return [];
  const rawLines = String(stack).split("\n");
  const cleaned = [];

  for (let line of rawLines) {
    line = line.trim();
    if (!line) continue;
    if (/^(?:[a-zA-Z]*Error|Exception):/.test(line)) continue;
    if (/node:internal|runScriptIn|evalScript|evalFunction|\[eval\]-wrapper/i.test(line)) continue;
    if (/runner\b/i.test(line)) continue;
    cleaned.push(line);
    if (cleaned.length >= 8) break;
  }
  return cleaned;
}

// Compile and run a payload with shared error reporting for both transports.
export async function executePayload({ code, size, api, log, say, servedCount }) {
  if (typeof window !== "undefined" && window.loaderHud) {
    window.loaderHud.setPayload({ size, args: api.args });
  }
  await log(`--- payload: ${size} bytes ---`, "info");

  const runner = (0, eval);
  const startTime = Date.now();
  let failure = null;
  const argsList = Array.isArray(api.args) ? api.args : [];
  const isLua = /^(?:\uFEFF)?--(?:!lua|lua)(?:\r?\n|$)/.test(code) ||
    argsList.includes("compat=remote_lua_loader") ||
    argsList.includes("lua=1");
  const boxOpener = (say && typeof say.startBox === "function") ? say.startBox
    : (typeof window !== "undefined" && (window.startLogBox || (window.writeLog && window.writeLog.startBox)));
  const boxCloser = (say && typeof say.endBox === "function") ? say.endBox
    : (typeof window !== "undefined" && (window.endLogBox || (window.writeLog && window.writeLog.endBox)));
  let boxOpened = false;

  try {
    let entry;
    if (isLua) {
      const { run } = await import("./lua-vm.js");
      entry = () => run(api, code.replace(/^\uFEFF/, ""), "=payload.lua");
    } else {
      entry = runner(`(async function () {\n${code}\n//# sourceURL=payload.js\n})`);
    }
    await log("");

    if (isLua && typeof boxOpener === "function") {
      boxOpener({ id: "luak1t", label: "Lua" });
      boxOpened = true;
    }

    let result = await entry();
    if (typeof result === "function") result = await result(api);
    if (result !== undefined) {
      await log(`payload returned ${typeof result}`, "info");
    }
  } catch (e) {
    failure = e;
    await log("");
    const errMsg = e && e.message ? e.message : String(e);
    await log(`payload threw: ${errMsg}`, "error");

    const loc = findPayloadLocation(e, code);
    if (loc) {
      const colStr = loc.col !== undefined ? `:${loc.col}` : "";
      await log(`  at payload.js:${loc.line}${colStr}`, "error");
      if (loc.snippet !== undefined && loc.snippet !== "") {
        await log(`  > ${loc.line} | ${loc.snippet.trim()}`, "error");
      }
    }

    if (e && e.stack) {
      const frames = formatStackFrames(e.stack);
      if (frames.length > 0) {
        await log(`  stack trace:`, "error");
        for (const frame of frames) {
          await log(`    ${frame}`, "error");
        }
      }
    }
  } finally {
    if (boxOpened && typeof boxCloser === "function") {
      boxCloser();
    }
    const duration = ((Date.now() - startTime) / 1000).toFixed(1);
    if (typeof window !== "undefined" && window.loaderHud) {
      window.loaderHud.setDone({ duration, servedCount });
    }
  }

  await log(`--- payload done ---`, "info");

  return {
    failed: failure !== null,
    error: failure,
    seconds: (Date.now() - startTime) / 1000,
  };
}

function concat(parts, total) {
  const out = new Uint8Array(total);
  let at = 0;
  for (const p of parts) {
    out.set(p, at);
    at += p.length;
  }
  return out;
}

// State shared across payloads, including krw and prefetched binaries.
export function createSessionState(p, chain) {
  return {
    p,
    chain,
    version: LOADER_VERSION,
    krw: null,
    // kexp's binaries, fetched before any kernel exploit starts. See prefetchKexp().
    prefetched: null,
    fw: (typeof window !== "undefined" && typeof window.fw_str === "string")
      ? window.fw_str : "unknown",
    libKernelBase: p.libKernelBase,
    libSceNKWebKitBase: p.libSceNKWebKitBase,
    libSceLibcInternalBase: p.libSceLibcInternalBase,
    gadgets: p.gadgets,
    syscalls: p.syscalls,
    int64,
    toI64: (v) => (v && typeof v.low !== "undefined" ? v : new int64(v >>> 0, 0)),
    sendBlob: null,
    args: [],
  };
}

export async function runLoader(p, chain, log, options = {}) {
  const say = typeof log === "function" ? log : () => {};

  const state = createSessionState(p, chain);

  say(`remote loader v${LOADER_VERSION}: ARW + hijacked worker + ROP chain, no kernel exploit`, "success");
  say(`ABI: p, chain, krw, fw, bases, gadgets, syscalls, int64, log, sendBlob`, "info");

  const listener = await openListener(p, chain, say, DEFAULT_PORT);
  const inBuf = p.malloc(READ_BUF);
  const outBuf = p.malloc(WRITE_BUF);

  const consoleIp = await getConsoleIp(p, chain);
  if (typeof window !== "undefined" && window.loaderHud) {
    window.loaderHud.setTarget(consoleIp, listener.boundPort, state.fw);
    window.loaderHud.setWaiting();
  }

  say(``, "info");
  say(`now send a payload from the PC:`, "success");
  say(`  python3 tools/send.py ${consoleIp} ${listener.boundPort} payloads/<payload.js>`, "info");
  say(`waiting for a connection...`, "info");

  let served = 0;

  for (;;) {
    if (served > 0) {
      say(`waiting for a connection...`, "info");
    }

    let client;
    try {
      client = await acceptOnce(p, chain, say, listener, ACCEPT_TIMEOUT_MS);
    } catch (e) {
      if (/timed out/.test(e.message)) {
        say(`no connection in ${ACCEPT_TIMEOUT_MS / 1000}s, still listening`, "info");
        continue;
      }
      say(`accept failed: ${e.message}`, "error");
      return { done: false, stage: "accept", served };
    }

    servedCount = served + 1;

    let clientInfo = "";
    try {
      if (listener && listener.peer) {
        const port = (p.read1(listener.peer.add32(2)) << 8) | p.read1(listener.peer.add32(3));
        const ip = [0, 1, 2, 3].map((i) => p.read1(listener.peer.add32(4 + i))).join(".");
        if (ip !== "0.0.0.0") {
          clientInfo = `${ip}:${port}`;
        }
      }
    } catch {}

    if (typeof window !== "undefined" && window.loaderHud) {
      window.loaderHud.setRunning({ clientInfo, servedCount });
    }

    say(``, "info");
    say(`[+] connection on fd ${client.low}${clientInfo ? " from " + clientInfo : ""} (#${servedCount})`, "success");

    const deadlineControl = { reset: null };
    try {
      await withDeadline(
        serveConnection(p, chain, say, state, client, inBuf, outBuf, state.args, deadlineControl, clientInfo),
        PAYLOAD_TIMEOUT_MS,
        (ms) => say(`payload has run for ${ms / 1000}s and has not returned`, "error"),
        (reset) => { deadlineControl.reset = reset; },
      );
      served++;
    } catch (e) {
      say(`connection error: ${e && e.message ? e.message : e}`, "error");
    } finally {
      if (typeof window !== "undefined" && window.loaderHud) {
        window.loaderHud.setWaiting();
      }
      deadlineControl.reset = null;
      try {
        if (typeof state.drain === "function") await state.drain();
      } catch {}
      state.drain = null;
      try {
        await closeFd(p, chain, client);
      } catch {}
    }
  }
}

// Build a per-payload API around shared session state.

export function createPayloadSession({
  p, chain, say, state, deadlineControl, log, sendBlob, args, serialise, stopQueue,
}) {
  // Record batches and serialise execution with socket log writes on the shared worker.
  const enqueueOn = typeof serialise === "function" ? serialise : (fn) => fn();

  function gatedChain() {
    let ops = null;

    function checkChainValue(value, method, argName) {
      if (value instanceof int64 || (value && typeof value === "object" && typeof value.low === "number" && typeof value.hi === "number")) {
        return;
      }
      if (typeof value === "number") {
        if (value > 0xffffffff) {
          throw new Error(
            `you're trying to write a value exceeding 32-bits without using an int64 instance (0x${value.toString(16)})`);
        }
        return;
      }
      const desc = value === undefined ? "undefined"
        : value === null ? "null"
        : typeof value === "object" ? (value.constructor ? value.constructor.name : typeof value)
        : typeof value + " (" + String(value) + ")";
      throw new Error(`You're trying to write a non number/non int64 value? (${desc})`);
    }

    function enqueue(fn) {
      return enqueueOn(fn);
    }

    function replay() {
      // Resolve rather than return undefined: payloads measure the fixed cost of an
      // empty chain with run(), and the socket path always hands back a promise
      // (enqueueOn = serialise). Without serialise -- the standalone runner -- an
      // undefined return breaks `gated.run().then(...)` in poops' ps0_preflight.
      if (!ops) return Promise.resolve();
      const batch = ops;
      ops = null;
      // A leading recorded clear already performs the mandatory full reset.
      if (!batch.length || batch[0][0] !== "clear") chain.clear();
      for (const [name, args] of batch) chain[name](...args);
      return chain.run();
    }

    function record(name) {
      return (...args) => {
        if (!ops) ops = [];
        ops.push([name, args]);
      };
    }

    const api = {
      get count() { return ops ? ops.length : chain.count; },
      // Expose chain geometry so payloads can account for slots and fcall alignment.
      get stack_entry_point() { return chain.stack_entry_point; },
      get stack_size() { return chain.stack_size; },
      get reserved_stack() { return chain.reserved_stack; },
      get initial_count() { return chain.initial_count || 0; },
      get return_value() { return chain.return_value; },
      clear: record("clear"),
      push: (value) => {
        checkChainValue(value, "push", "value");
        if (!ops) ops = [];
        ops.push(["push", [value]]);
      },
      push_write8: (dest, value) => {
        checkChainValue(dest, "push_write8", "dest");
        checkChainValue(value, "push_write8", "value");
        if (!ops) ops = [];
        ops.push(["push_write8", [dest, value]]);
      },
      write_result: (dest) => {
        checkChainValue(dest, "write_result", "dest");
        if (!ops) ops = [];
        ops.push(["write_result", [dest]]);
      },
      fcall: (rip, ...args) => {
        checkChainValue(rip, "fcall", "rip");
        for (let i = 0; i < args.length; i++) {
          if (args[i] !== undefined) checkChainValue(args[i], "fcall", `arg${i + 1}`);
        }
        if (!ops) ops = [];
        ops.push(["fcall", [rip, ...args]]);
      },
      add_syscall: (sysc, ...args) => {
        for (let i = 0; i < args.length; i++) {
          if (args[i] !== undefined) checkChainValue(args[i], "add_syscall", `arg${i + 1}`);
        }
        if (!ops) ops = [];
        ops.push(["add_syscall", [sysc, ...args]]);
      },
      add_syscall_ret: (retstore, sysc, ...args) => {
        checkChainValue(retstore, "add_syscall_ret", "retstore");
        for (let i = 0; i < args.length; i++) {
          if (args[i] !== undefined) checkChainValue(args[i], "add_syscall_ret", `arg${i + 1}`);
        }
        if (!ops) ops = [];
        ops.push(["add_syscall_ret", [retstore, sysc, ...args]]);
      },
      run: () => enqueue(replay),
      syscall: (sysc, ...a) => {
        for (let i = 0; i < a.length; i++) {
          if (a[i] !== undefined) checkChainValue(a[i], "syscall", `arg${i + 1}`);
        }
        return enqueue(async () => {
          if (ops) {
            throw new Error(
              `api.chain.syscall(0x${(sysc >>> 0).toString(16)}) was called with ` +
              `${ops.length} unrun chain op(s) pending. Build a batch with ` +
              `clear()/add_syscall*() and execute it with run(); syscall() runs ` +
              `the chain by itself and would discard them.`);
          }
          traceLaunch(`syscall 0x${(sysc >>> 0).toString(16)}`);
          return chain.syscall(sysc, ...a);
        });
      },
      call: (rip, ...a) => {
        checkChainValue(rip, "call", "rip");
        for (let i = 0; i < a.length; i++) {
          if (a[i] !== undefined) checkChainValue(a[i], "call", `arg${i + 1}`);
        }
        return enqueue(() => {
          traceLaunch(`fcall 0x${(rip.low >>> 0).toString(16)}`);
          return chain.call(rip, ...a);
        });
      },
    };
    return api;
  }

  // Optional per-launch chain trace (payload arg `roptrace=1`): maps a klog
  // crash RIP on the worker thread back to the syscall number that was in
  // flight via the offsets/<fw>.js syscall map.
  const roptrace = Array.isArray(args) && args.includes("roptrace=1");
  const traceLaunch = roptrace ? (desc) => { log(`[rop] ${desc} launch`); } : () => {};

  state.gatedChain = gatedChain();

  // Track allocations per payload so earlier buffers do not widen this read guard.
  const xotext = xotextRanges(state.p);
  const flags = { allowXotextReads: false };
  const owned = [];

  function isOwned(address) {
    const a = address.low >>> 0;
    for (const r of owned) {
      if (a >= r.start && a < r.end) return true;
    }
    return false;
  }

  function guardRead(name, address) {
    if (flags.allowXotextReads || !address) return;
    if (isOwned(address)) return;

    if ((address.hi >>> 0) !== 0) return;

    const a = address.low >>> 0;
    for (const r of xotext) {
      if (a >= r.start && a < r.end) {
        throw new Error(
          `p.${name} at 0x${a.toString(16)} lands inside ${r.name} ` +
          `(0x${r.start.toString(16)}-0x${r.end.toString(16)}), which is mapped ` +
          `execute-only. Reading it FAULTS and kills the renderer with no log ` +
          `line. Print the base as a number instead, or set ` +
          `api.allowXotextReads = true if you really mean it.`);
      }
    }
  }

  function guardReadRange(address, length) {
    if (flags.allowXotextReads || !length) return;
    const pointer = typeof address === "number"
      ? new state.int64(address >>> 0, Math.floor(address / 0x100000000)) : address;
    if ((pointer.hi >>> 0) !== 0) return;
    const start = pointer.low >>> 0;
    for (const r of xotext) {
      let cursor = Math.max(start, r.start);
      const end = Math.min(start + length, r.end);
      while (cursor < end) {
        const allocation = owned.find(o => cursor >= o.start && cursor < o.end);
        if (!allocation) guardRead("readInto", new state.int64(cursor, 0));
        else cursor = allocation.end;
      }
    }
  }

  const api = {
    p: Object.assign(Object.create(null), state.p, {
      malloc(size, type) {
        const words = type === 1 ? 1000 + (size | 0) : 0x10000 + (size | 0);
        if (words * 4 > MALLOC_LIMIT) {
          throw new Error(
            `p.malloc(${size}) would allocate ${(words * 4 / 1024).toFixed(0)} KB; ` +
            `this payload is limited to ${MALLOC_LIMIT / 1024} KB. The WebProcess ` +
            `heap is nearly full from the exploit's carrier.`);
        }
        const ptr = state.p.malloc(size, type);
        owned.push({ start: ptr.low >>> 0, end: (ptr.low + words * 4) >>> 0 });
        return ptr;
      },
      read1: (a) => { guardRead("read1", a); return state.p.read1(a); },
      read2: (a) => { guardRead("read2", a); return state.p.read2(a); },
      read4: (a) => { guardRead("read4", a); return state.p.read4(a); },
      read8: (a) => { guardRead("read8", a); return state.p.read8(a); },
      readInto: typeof state.p.readInto === "function" ? (a, buffer) => {
        guardReadRange(a, buffer.length);
        return state.p.readInto(a, buffer);
      } : null,
    }),
    allowXotextReads: false,
    set allowXotextReads(v) { flags.allowXotextReads = !!v; },
    chain: state.gatedChain,
    get krw() { return state.krw; },
    set krw(v) { state.krw = v; },
    version: LOADER_VERSION,
    fw: state.fw,
    krwLayout: (typeof window !== "undefined" && window.KRW) ? window.KRW : null,
    libKernelBase: state.libKernelBase,
    libSceNKWebKitBase: state.libSceNKWebKitBase,
    libSceLibcInternalBase: state.libSceLibcInternalBase,
    gadgets: state.gadgets,
    syscalls: state.syscalls,
    int64: state.int64,
    toI64: state.toI64,
    isFailure,
    isUnexpected,
    describe,
    args: args || [],
    log,
    enableSyncGates: () => { if (p.enableSyncGates) p.enableSyncGates(); },
    disableSyncGates: () => { if (p.disableSyncGates) p.disableSyncGates(); },
    stopQueue: (reason) => {
      if (typeof stopQueue !== "function") {
        throw new Error("api.stopQueue() is only available in a standalone payload queue");
      }
      return stopQueue(reason);
    },
    setPayloadTimeout: (ms) => {
      if (!deadlineControl.reset) throw new Error("payload deadline is no longer active");
      deadlineControl.reset(ms);
    },
    sendBlob,
    config: {
      ...DEFAULT_BINARIES,
      ...((typeof window !== "undefined" && window.LOADER_CONFIG) || {}),
    },
    // Prefetch before kernel work; launchKexp consumes the cached bytes.
    prefetchKexp: async (options = {}) => {
      if (state.prefetched) return state.prefetched;
      const { prefetchBinaries, setPrefetchLog } = await import("./kexp.js");
      // Reset the module-level log sink after prefetching.
      setPrefetchLog(log);
      try {
        state.prefetched = await prefetchBinaries(options);
        return state.prefetched;
      } finally {
        setPrefetchLog(null);
      }
    },
    launchKexp: async (options = {}) => {
      const { runKexp } = await import("./kexp.js");
      const krwHandle = options.krw || state.krw;
      if (!krwHandle) {
        throw new Error("launchKexp requires an active kernel R/W handle (krw)");
      }
      const pre = options.prefetched || state.prefetched;
      if (!pre || !(pre.kexpBytes instanceof Uint8Array) || !(pre.elfldrBytes instanceof Uint8Array)) {
        throw new Error(
          "launchKexp has no prefetched binaries. Call api.prefetchKexp() BEFORE running " +
          "the kernel exploit: this page's network stack does not recover once the " +
          "hijacked worker has run a kernel exploit, so a fetch() issued from here never " +
          "completes and the session goes silent rather than failing.");
      }
      const merged = { ...options, ...pre };
      // Use the gated chain: kexp logs can schedule socket writes between worker calls.
      return await runKexp(krwHandle, p, state.gatedChain, log, merged);
    },
    module: async (path) => {
      const url = new URL(path, document.baseURI).href;

      // Resolve embedded helpers before attempting HTTP.
      const inline = inlineModule(path);
      if (inline) return inline;

      let response;
      try {
        response = await fetch(url, { cache: "no-store" });
      } catch (e) {
        throw new Error(
          `could not fetch ${url}: ${e && e.message ? e.message : e}. ` +
          `This is a NETWORK failure, not a bad module. Check that host.py is ` +
          `still running and that the PS5 DNS still points at this PC -- a hard ` +
          `power-off can drop the console's DNS settings.`);
      }
      if (!response.ok)
        throw new Error(`fetch of ${url} returned HTTP ${response.status}`);

      const type = response.headers.get("content-type") || "(none)";
      const body = await response.text();
      if (body.length === 0)
        throw new Error(`${url} was served empty (${response.status}, ${type})`);

      try {
        return await import(url);
      } catch (e) {
        throw new Error(
          `${url} was fetched (${body.length} bytes, ${type}) but would not ` +
          `load: ${e && e.message ? e.message : e}`);
      }
    },
    executePayload: async (code, payloadArgs = []) => {
      const subApi = createPayloadSession({
        p, chain, say, state, deadlineControl,
        log: async (msg, type) => { await say(msg, type); },
        sendBlob,
        args: Array.isArray(payloadArgs) ? payloadArgs : [payloadArgs],
      });
      return await executePayload({
        code,
        size: typeof code === "string" ? new TextEncoder().encode(code).length : code.length,
        api: subApi,
        log: subApi.log,
        say,
        servedCount: (state.servedCount || 0) + 1,
      });
    },
  };

  return api;
}

// Resolve a module from the inline registry; return null if no entry exists.
function inlineModule(path) {
  const registry = (typeof window !== "undefined" && window.INLINE_MODULES) || null;
  if (!registry) return null;

  const keys = Object.keys(registry);
  let factory = null;
  let matched = null;
  if (Object.prototype.hasOwnProperty.call(registry, path)) {
    matched = path;
    factory = registry[path];
  } else {
    // Resolve against the page and compare endings, so a relative specifier
    // matches regardless of which directory the build tool rooted it at.
    const resolved = (() => {
      try { return new URL(path, document.baseURI).pathname; } catch { return path; }
    })();
    for (const key of keys) {
      if (key === path || key.endsWith("/" + path.replace(/^\.\//, ""))) {
        matched = key;
        factory = registry[key];
        break;
      }
    }
    if (!factory && resolved) {
      for (const key of keys) {
        if (key.endsWith(resolved) || key === resolved) {
          matched = key;
          factory = registry[key];
          break;
        }
      }
    }
  }
  if (!factory) return null;

  try {
    return Promise.resolve(factory());
  } catch (e) {
    throw new Error(
      `${matched} is embedded in this page but would not evaluate: ` +
      `${e && e.message ? e.message : e}`);
  }
}

async function serveConnection(p, chain, say, state, client, inBuf, outBuf, initialArgs, deadlineControl, clientInfo) {
  let pending = [];
  let pendingBytes = 0;
  let writeChain = Promise.resolve();

  state.drain = () => writeChain;

  function flush() {
    if (pendingBytes === 0) return writeChain;
    return serialise(async () => {
      if (pendingBytes === 0) return;
      const chunk = pending.join("");
      pending = [];
      pendingBytes = 0;
      const data = encoder.encode(chunk);
      for (let off = 0; off < data.length; off += WRITE_BUF) {
        const slice = data.subarray(off, Math.min(off + WRITE_BUF, data.length));
        const n = pushBytes(p, outBuf, slice);
        await writeBytes(p, chain, client, outBuf, n);
      }
    }).catch((e) => {
      pending = [];
      pendingBytes = 0;
      say(`log write failed: ${e && e.message ? e.message : e}`, "error");
    });
  }

  function log(message, type = "log") {
    say(message, type);
    const marker = type === "error" ? "-" : type === "info" || type === "success" ? "+" : "*";
    pending.push(`[${marker}] ${message}\n`);
    pendingBytes += message.length + 6;
    return flush();
  }
  log.startBox = (opts) => { if (say && typeof say.startBox === "function") return say.startBox(opts); };
  log.endBox = () => { if (say && typeof say.endBox === "function") return say.endBox(); };

  async function sendBlob(bytes) {
    const data = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
    const framed = new Uint8Array(8 + data.length);
    framed[0] = 0x13; framed[1] = 0x37; framed[2] = 0x13; framed[3] = 0x37;
    new DataView(framed.buffer).setUint32(4, data.length, true);
    framed.set(data, 8);

    await serialise(async () => {
      if (pendingBytes > 0) {
        const chunk = pending.join("");
        pending = [];
        pendingBytes = 0;
        const d = encoder.encode(chunk);
        for (let off = 0; off < d.length; off += WRITE_BUF) {
          const s = d.subarray(off, Math.min(off + WRITE_BUF, d.length));
          await writeBytes(p, chain, client, outBuf, pushBytes(p, outBuf, s));
        }
      }
      for (let off = 0; off < framed.length; off += WRITE_BUF) {
        const slice = framed.subarray(off, Math.min(off + WRITE_BUF, framed.length));
        const n = pushBytes(p, outBuf, slice);
        await writeBytes(p, chain, client, outBuf, n);
      }
    });
    return data.length;
  }

  function serialise(fn) {
    const out = writeChain.then(fn);
    writeChain = out.catch((e) => {
      say(`write failed: ${e && e.message ? e.message : e}`, "error");
    });
    return out;
  }

  async function readExactly(n, what) {
    const buf = new Uint8Array(n);
    let at = 0;
    while (at < n) {
      const got = await readBytes(p, chain, client, inBuf, Math.min(READ_BUF, n - at));
      if (got <= 0) {
        await log(`truncated while reading ${what} (${at}/${n} bytes)`, "error");
        return null;
      }
      pullBytes(p, inBuf, got).forEach((b, i) => { buf[at + i] = b; });
      at += got;
    }
    return buf;
  }

  // 1. Read size/magic header
  const head = await readExactly(8, "the size header");
  if (head === null) return;
  const view = new DataView(head.buffer);
  const lo = view.getUint32(0, true);
  const hi = view.getUint32(4, true);
  let size = lo + hi * 0x100000000;

  // 2. Command frame
  if (size === CMD_MAGIC) {
    const gotCmd = await readBytes(p, chain, client, inBuf, 1);
    if (gotCmd < 1) return;
    const cmd = pullBytes(p, inBuf, 1)[0];
    const name = COMMANDS[cmd] || `unknown(${cmd})`;
    if (cmd === 0) {
      await log("command: disconnect requested", "info");
    } else if (cmd === 1) {
      await log(`up: fd ${client.low}, v${LOADER_VERSION}, served ${servedCount} payload(s), ` +
        `krw ${state.krw ? "established" : "not established"}`, "info");
    } else {
      await log(`command: ${name} (no handler yet)`, "info");
    }
    await flush();
    return;
  }

  // 2b. Argument frame
  const args = [];
  if (size === ARGV_MAGIC) {
    const argcBuf = await readExactly(4, "the argument count");
    if (argcBuf === null) return;
    const argc = new DataView(argcBuf.buffer).getUint32(0, true);
    if (argc > 64) {
      await log(`refusing ${argc} arguments (max 64)`, "error");
      return;
    }
    for (let i = 0; i < argc; i++) {
      const lenBuf = await readExactly(4, `argument ${i} length`);
      if (lenBuf === null) return;
      const len = new DataView(lenBuf.buffer).getUint32(0, true);
      if (len > 4096) {
        await log(`argument ${i} is ${len} bytes (max 4096)`, "error");
        return;
      }
      const raw = await readExactly(len, `argument ${i}`);
      if (raw === null) return;
      args.push(decoder.decode(raw));
    }
    const srcLenBuf = await readExactly(8, "the source length");
    if (srcLenBuf === null) return;
    const sv = new DataView(srcLenBuf.buffer);
    size = sv.getUint32(0, true) + sv.getUint32(4, true) * 0x100000000;
    await log(`args: ${args.length ? args.join(" ") : "(none)"}`, "info");
  }

  if (size === 0 || size > MAX_PAYLOAD) {
    await log(`bad payload size ${size} (max ${MAX_PAYLOAD}), dropping connection`, "error");
    return;
  }

  // 3. Read payload source in chunks
  const parts = [];
  let filled = 0;
  while (filled < size) {
    const want = Math.min(READ_BUF, size - filled);
    const n = await readBytes(p, chain, client, inBuf, want);
    if (n <= 0) {
      await log(`payload truncated at ${filled}/${size} bytes`, "error");
      return;
    }
    parts.push(pullBytes(p, inBuf, n));
    filled += n;
  }

  let code;
  try {
    code = decoder.decode(concat(parts, filled));
  } catch (e) {
    await log(`could not decode the payload: ${e && e.message ? e.message : e}`, "error");
    return;
  }

  const api = createPayloadSession({
    p, chain, say, state, deadlineControl,
    log, sendBlob, args, serialise,
  });

  // Flush the banner before a payload can fault.
  await flush();
  await executePayload({ code, size, api, log, say, servedCount: ++servedCount });
}

let servedCount = 0;
