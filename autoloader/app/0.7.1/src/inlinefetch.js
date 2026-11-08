// Serve embedded binaries through fetch; unmatched paths use the original fetch.

import { DEFAULT_BINARIES } from "./binaries.js";

const NO_NETWORK_MESSAGE =
  "this page has no network access, and %s is not embedded in it. " +
  "Serve the repository with host.py and run this payload with tools/send.py.";

export function base64ToBytes(b64) {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  const lookup = {};
  for (let i = 0; i < alphabet.length; i++) lookup[alphabet.charAt(i)] = i;

  const clean = String(b64).replace(/[\s=]+$/g, "");
  const out = new Uint8Array(Math.floor((clean.length * 3) / 4));
  let at = 0;

  for (let i = 0; i < clean.length; i += 4) {
    const c0 = lookup[clean.charAt(i)];
    const c1 = lookup[clean.charAt(i + 1)];
    const c2 = lookup[clean.charAt(i + 2)];
    const c3 = lookup[clean.charAt(i + 3)];
    if (c0 === undefined || c1 === undefined) {
      throw new Error(`embedded binary is corrupt (bad base64 at offset ${i})`);
    }
    let bits = (c0 << 18) | (c1 << 12);
    out[at++] = (bits >>> 16) & 0xff;
    if (c2 !== undefined) {
      bits |= c2 << 6;
      out[at++] = (bits >>> 8) & 0xff;
      if (c3 !== undefined) {
        bits |= c3;
        out[at++] = bits & 0xff;
      }
    }
  }
  return out.subarray(0, at);
}

// Match repo-relative binary paths by URL suffix. Return installation metadata.
export function installInlineFetch(binaries) {
  const table = binaries || {};
  const realFetch = typeof window !== "undefined" && typeof window.fetch === "function"
    ? window.fetch.bind(window)
    : null;

  window.fetch = function (input, init) {
    const url = typeof input === "string" ? input : ((input && input.url) || "");
    const hit = matchEmbedded(url, table);

    if (!hit) {
      if (!realFetch) {
        return Promise.reject(new Error(NO_NETWORK_MESSAGE.replace("%s", url || "(no url)")));
      }
      return realFetch(input, init);
    }

    let view;
    try {
      view = base64ToBytes(table[hit]);
    } catch (e) {
      return Promise.reject(new Error(`${hit} is embedded in this page but could not be ` +
        `decoded: ${e && e.message ? e.message : e}`));
    }

    return Promise.resolve({
      ok: true,
      status: 200,
      url,
      headers: { get: () => "application/octet-stream" },
      // A copy, not a view: kexp.js keeps this buffer, and handing back a view onto a
      // shared decode result would alias every later decode onto the same memory.
      arrayBuffer: function () {
        const copy = new ArrayBuffer(view.length);
        new Uint8Array(copy).set(view);
        return Promise.resolve(copy);
      },
      text: function () {
        return Promise.resolve(new TextDecoder().decode(view));
      },
    });
  };

  return Object.keys(table);
}

function matchEmbedded(url, table) {
  if (!url) return null;
  for (const path of Object.keys(table)) {
    if (url === path || url.indexOf("/" + path) !== -1) return path;
  }
  return null;
}

// The paths this page is expected to carry, from the one place they are written down.
// Used by the build tool to decide what to embed and by the page to report what it has.
export { DEFAULT_BINARIES };