import { establishPrimitive } from "./webkit.js";
import { installWindowP } from "./utils/mem.js";
import { DEFAULT_BINARIES } from "./binaries.js";
import { installInlineFetch } from "./inlinefetch.js";
import { runPayloadQueue } from "./standalone.js";
import { LOADER_VERSION } from "./loader.js";

// Seed the binary configuration for session overrides.
window.LOADER_CONFIG = { ...DEFAULT_BINARIES, ...((typeof window !== "undefined" && window.LOADER_CONFIG) || {}) };

const output = document.getElementById("console");
const hudAddr = document.getElementById("hud-addr");
const hudFw = document.getElementById("hud-fw");

let hudState = {
  ip: "127.0.0.1",
  port: 9027,
  fw: (typeof window !== "undefined" && window.fw_str) || "--",
};

let sessionActive = false;

window.loaderHud = {
  setTarget(ip, port, fw) {
    if (ip !== undefined) hudState.ip = ip;
    if (port !== undefined) hudState.port = port;
    if (fw !== undefined) hudState.fw = fw;
    if (hudAddr) {
      if (!hudState.ip) {
        hudAddr.style.display = "none";
      } else {
        hudAddr.style.display = "";
        hudAddr.textContent = hudState.port ? `${hudState.ip}:${hudState.port}` : `${hudState.ip}`;
      }
    }
    if (hudFw) hudFw.textContent = `FW ${hudState.fw}`;
  },
  setWaiting() {},
  setRunning(info = {}) {
    sessionActive = true;
  },
  setPayload(info = {}) {
    sessionActive = true;
  },
  setDone(info = {}) {},
  setError(err) {}
};

let activeBox = null;

function startLogBox({ id, label, className } = {}) {
  if (!output) return null;
  if (activeBox) endLogBox();

  const box = document.createElement("div");
  box.className = className || "luak1t-box";

  const header = document.createElement("div");
  header.className = "luak1t-header";

  const badge = document.createElement("span");
  badge.className = "luak1t-badge";
  badge.textContent = label || "Lua";
  header.appendChild(badge);
  box.appendChild(header);

  const content = document.createElement("div");
  content.className = "luak1t-content";
  box.appendChild(content);

  output.appendChild(box);
  activeBox = { box, header, content };

  output.scrollTop = output.scrollHeight;
  if (document.body && typeof window.scrollTo === "function") {
    window.scrollTo(0, document.body.scrollHeight);
  }
  return box;
}

function endLogBox() {
  activeBox = null;
  if (output) {
    output.scrollTop = output.scrollHeight;
    if (document.body && typeof window.scrollTo === "function") {
    window.scrollTo(0, document.body.scrollHeight);
  }
  }
}

function writeLog(message, type = "log", replace = false) {
  if (!output) return;
  if (message == null) message = "";

  const container = (activeBox && activeBox.content) ? activeBox.content : output;

  const lines = String(message).split("\n");
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    let line = (replace && i === 0) ? container.lastElementChild : null;
    if (!line) {
      line = document.createElement("div");
      container.appendChild(line);
    }

    if (raw.trim() === "") {
      line.className = "log-line";
      line.textContent = "";
      continue;
    }

    let lineType = type;
    let marker = "*";
    let text = raw;

    if (raw.startsWith("[+] ")) {
      lineType = "success";
      marker = "+";
      text = raw.slice(4);
    } else if (raw.startsWith("[-] ")) {
      lineType = "error";
      marker = "-";
      text = raw.slice(4);
    } else if (raw.startsWith("[*] ")) {
      lineType = sessionActive ? "star" : "setup";
      marker = "*";
      text = raw.slice(4);
    } else if (raw.startsWith("[!] ")) {
      lineType = "warn";
      marker = "!";
      text = raw.slice(4);
    } else {
      if (!sessionActive) {
        if (type === "error") {
          lineType = "error";
          marker = "-";
        } else {
          lineType = "setup";
          marker = "*";
        }
      } else {
        if (type === "error") {
          lineType = "error";
          marker = "-";
        } else if (type === "info" || type === "success") {
          lineType = "success";
          marker = "+";
        } else if (type === "warn") {
          lineType = "warn";
          marker = "!";
        } else {
          lineType = "star";
          marker = "*";
        }
      }
    }

    line.className = `log-line log-${lineType}`;
    line.textContent = `[${marker}] ${text}`;
  }

  // Cap DOM history to prevent out-of-memory in WebKit process
  if (container !== output && container.childNodes.length > 1000) {
    while (container.childNodes.length > 800) {
      container.removeChild(container.firstChild);
    }
  }
  if (output.childNodes.length > 1200) {
    while (output.childNodes.length > 1000) {
      output.removeChild(output.firstChild);
    }
  }

  output.scrollTop = output.scrollHeight;
  if (document.body && typeof window.scrollTo === "function") {
    window.scrollTo(0, document.body.scrollHeight);
  }
}

function writeEvent(name, detail, type) {
  writeLog(detail == null || detail === "" ? name : `${name}: ${detail}`,
    type || (name === "Failed" ? "error" : "log"));
}

writeLog.startBox = startLogBox;
writeLog.endBox = endLogBox;

window.writeLog = writeLog;
window.startLogBox = startLogBox;
window.endLogBox = endLogBox;
window.jb = { mark: writeEvent };

// Route window.alert to writeLog so rogue alerts never freeze the console
window.alert = function (msg) {
  writeLog(`alert: ${msg}`, "warn");
};

// Global error handlers to surface any unhandled exceptions to the on-screen log
window.addEventListener("error", (event) => {
  const loc = event.filename ? ` at ${event.filename}:${event.lineno}:${event.colno}` : "";
  writeLog(`unhandled error: ${event.message}${loc}`, "error");
});
window.addEventListener("unhandledrejection", (event) => {
  const reason = event.reason;
  const msg = reason instanceof Error ? (reason.stack || reason.message) : String(reason);
  writeLog(`unhandled rejection: ${msg}`, "error");
});

async function getPrimitive() {
  writeLog("Starting WebKit exploit");
  const primitive = installWindowP(await establishPrimitive(writeEvent));
  if (!primitive || typeof primitive.read8 !== "function")
    throw new Error("Memory primitive unavailable");

  writeLog("ARW ready", "success");
  return primitive;
}

function getWebKitBase() {
  const ctor = globalThis.__ps5NativeCtor;
  if (typeof ctor !== "number" || typeof OFFSET_wk_host_constructor_candidates === "undefined")
    throw new Error("WebKit base inputs are unavailable");

  for (const offset of OFFSET_wk_host_constructor_candidates) {
    const base = ctor - offset;
    if (base >= 0x800000000 && base < 0x900000000 && base % 0x4000 === 0)
      return base;
  }

  throw new Error("WebKit base not found");
}

async function run() {
  const rejection = window.firmware.rejection();
  if (rejection)
    throw new Error(rejection);

  // A single-file page (tools/build_standalone.py) carries its own name, its own
  // payload list and no socket, so it says so instead of claiming to be the
  // remote loader -- the operator's first question when the guide opens is
  // whether they are looking at the wrong thing.
  const standalone = (typeof window !== "undefined" && window.STANDALONE) || null;

  if (standalone) {
    if (standalone.title) {
      writeLog(standalone.title, "info");
    } else {
      writeLog(
        `PS5 WebKit Loader: ${(standalone.payloadNames && standalone.payloadNames.join(", ")) || "payloads"}`,
        "info",
      );
    }
    if (standalone.payloadCount != null) {
      writeLog(
        `${standalone.payloadCount} payload(s) baked in: ${standalone.payloadNames.join(", ")}`,
        "info",
      );
    }
    if (!standalone.modular) {
      writeLog("no socket: this file is the whole session", "info");
    }
  } else {
    writeLog(`PS5 WebKit Remote Loader v${LOADER_VERSION}`, "info");
  }
  writeLog(`Agent: ${navigator.userAgent}`, "info");
  writeLog(`Firmware: ${window.fw_str}`, "info");

  if (window.loaderHud) {
    // A standalone page never opens a port, so hide the IP/port and display the FW.
    window.loaderHud.setTarget(standalone ? null : "127.0.0.1", standalone ? null : 9027, window.fw_str);
  }

  // A single-file page carries embedded binaries as data; install the fetch that serves
  // them before anything can ask for one. window.EMBEDDED_BINARIES is undefined on a
  // served page, so that path is untouched and its real fetch stays in place.
  if (typeof window !== "undefined" && window.EMBEDDED_BINARIES) {
    const served = installInlineFetch(window.EMBEDDED_BINARIES);
    writeLog(`embedded binaries: ${served.join(", ")}`, "info");
  } else if (standalone && !standalone.modular) {
    writeLog(`no embedded binaries in this file: api.launchKexp() will refuse`, "warn");
  }

  const primitive = await getPrimitive();
  if (window.offsetsLoaded) {
    await window.offsetsLoaded;
  }
  writeLog(`WebKit base: 0x${getWebKitBase().toString(16)}`, "info");

  // serve:false, because this page runs its own queue. Everything above it --
  // the exploit, the offsets, the cross-check -- is the same work either way.
  const { p, chain } = await main(primitive, { serve: !standalone });

  if (standalone) {
    // Straight to the queue. runLoader() is not called: it would open a listener
    // and wait for a connection that this page has no way to receive.
    await runPayloadQueue({ p, chain, payloads: window.STANDALONE.payloads || [] });
  }
}

run().catch((error) => {
  writeLog(error instanceof Error ? error.message : String(error), "error");
  if (window.loaderHud) window.loaderHud.setError(error);
});