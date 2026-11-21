"use strict";

// Host glue for the vendored Wobkot runtime.  Wobkot intentionally uses classic
// scripts and a shared global lexical environment; keep this file classic too.
const logger = {
  verbose: true,
  info(message) { this.log("[+]", message); },
  error(message) { this.log("[-]", message); },
  debug(message) { if (this.verbose) this.log("[*]", message); },
  log(prefix, message) {
    const text = `${prefix} ${String(message)}`;
    if (typeof window.writeLog === "function") window.writeLog(text);
    else console.log(text);
  },
};

const WOBKOT_SCRIPT_MAP = {
  "src/kernel.js": "vendor/wobkot/src/kernel.js",
  "src/ps5/relapse.js": "vendor/wobkot/src/ps5/relapse.js",
};

function load_script(source) {
  const mapped = WOBKOT_SCRIPT_MAP[source] || source;
  return new Promise((resolve, reject) => {
    const script = document.createElement("script");
    const inline = window.__wobkotScripts && typeof window.__wobkotScripts[mapped] === "string";
    if (inline)
      script.text = window.__wobkotScripts[mapped];
    else
      script.src = new URL(mapped, document.baseURI).href;
    script.onload = resolve;
    script.onerror = () => reject(new Error(`Failed to load script: ${mapped}`));
    document.head.appendChild(script);
    if (inline) resolve();
  });
}
async function load_file(source) {
  let mapped = source;
  const config = window.LOADER_CONFIG || {};
  if (source === "src/ps5/kexp.bin") mapped = config.KEXP_BIN || "shared/kexp-v0.8-24cf6e5.bin";
  if (source === "src/ps5/elfldr.elf") mapped = config.ELFLDR_ELF || "shared/elfldr-ps5-v0.26.elf";

  const response = await fetch(new URL(mapped, document.baseURI).href);
  if (!response.ok) throw new Error(`HTTP ${response.status}: ${mapped}`);
  return new Uint8Array(await response.arrayBuffer());
}
