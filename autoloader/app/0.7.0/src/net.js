// net.js — BSD socket syscall wrappers using ROP chain operations.

const AF_INET = 2;
const SOCK_STREAM = 1;
const SOL_SOCKET = 0xffff;
const SO_REUSEADDR = 4;

const CALL = {
  SOCKET: 0x061,
  SETSOCKOPT: 0x069,
  BIND: 0x068,
  LISTEN: 0x06a,
  GETSOCKNAME: 0x020,
  ACCEPT: 0x01e,
  READ: 0x003,
  WRITE: 0x004,
  CLOSE: 0x006,
  GETPID: 0x014,
};

const ERRNO = {
  0x04: "EINTR",
  0x0c: "ENOMEM",
  0x12: "ENODEV",
  0x20: "EAGAIN",
  0x22: "EINVAL",
  0x30: "EADDRINUSE",
  0x36: "EAFNOSUPPORT",
  0x38: "EADDRNOTAVAIL",
  0x42: "EPERM",
  0x60: "ENOTSOCK",
  0x78: "ENOSPC",
};

function describe(v) {
  const low = v.low >>> 0;
  if (low === 0xffffffff) return "0xFFFFFFFF (-1)";
  const name = ERRNO[low];
  return name ? `${low} (${name})` : String(low);
}

// libkernel syscall stubs return -1 (0xFFFFFFFF) on error via the carry flag.
function isFailure(v) {
  return (v.low >>> 0) === 0xffffffff || v.hi !== 0;
}

function isUnexpected(v, expected = 0) {
  return !isFailure(v) && (v.low >>> 0) !== expected;
}

function htons(port) {
  return ((port & 0xff) << 8) | ((port >> 8) & 0xff);
}

function ntohs(word) {
  return ((word & 0xff) << 8) | ((word >> 8) & 0xff);
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function sys(chain, name, ...args) {
  const nr = CALL[name];
  if (nr === undefined) throw new Error(`net: unknown syscall ${name}`);
  return await chain.syscall(nr, ...args);
}

export { CALL, describe, isFailure, isUnexpected, sleep, sys, htons, ntohs };

// Create, bind, and listen on an IPv4 TCP socket.
export async function openListener(p, chain, log, port) {
  const say = log || (() => {});
  const sockaddr = p.malloc(16);
  const addrlen = p.malloc(8);
  const optval = p.malloc(4);

  const sock = await sys(chain, "SOCKET", AF_INET, SOCK_STREAM, 0);
  if (isFailure(sock)) throw new Error(`socket() failed: ${describe(sock)}`);
  say(`socket() = fd ${sock.low}`, "success");

  p.write4(optval, 1);
  const so = await sys(chain, "SETSOCKOPT", sock, SOL_SOCKET, SO_REUSEADDR, optval, 4);
  say(isUnexpected(so)
    ? `setsockopt(SO_REUSEADDR) = ${describe(so)} (non-fatal, continuing)`
    : `setsockopt(SO_REUSEADDR) ok`, "info");

  // struct sockaddr_in (16 bytes)
  p.write1(sockaddr.add32(0), 0);
  p.write1(sockaddr.add32(1), AF_INET);
  p.write2(sockaddr.add32(2), htons(port));
  p.write4(sockaddr.add32(4), 0); // INADDR_ANY
  for (let i = 8; i < 16; i++) p.write1(sockaddr.add32(i), 0);

  p.write4(addrlen, 16);
  const bindr = await sys(chain, "BIND", sock, sockaddr, 16);
  if (isUnexpected(bindr)) {
    const hint = (bindr.low >>> 0) === 0x30
      ? ` — EADDRINUSE, something already holds ${port}`
      : "";
    throw new Error(`bind(${port}) failed: ${describe(bindr)}${hint}`);
  }
  say(`bind(${port}) ok`, "success");

  const lis = await sys(chain, "LISTEN", sock, 3);
  if (isUnexpected(lis)) throw new Error(`listen() failed: ${describe(lis)}`);
  say(`listen(backlog=3) ok`, "success");

  p.write4(addrlen, 16);
  await sys(chain, "GETSOCKNAME", sock, sockaddr, addrlen);
  const boundPort = ntohs(p.read2(sockaddr.add32(2)));
  say(`getsockname() reports port ${boundPort}`, "info");

  return { sock, boundPort, sockaddr, peer: p.malloc(16), addrlen };
}

// Poll for completion of a detached syscall in `slot`, then sync with worker.
async function waitDetached(p, chain, log, slot, timeoutMs) {
  const say = log || (() => {});
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const v = p.read8(slot);
    if (v.low !== 0 || v.hi !== 0) {
      if (isFailure(v)) throw new Error(describe(v));

      chain.clear();

      // Drain worker epilogue and confirm responsiveness
      const pid = await chain.syscall(CALL.GETPID);
      if (pid.low === 0) throw new Error("worker did not come back after accept");
      return v;
    }
    await sleep(250);
  }
  throw new Error(`timed out after ${Math.round(timeoutMs / 1000)}s`);
}

// Accept a single inbound connection on the listener socket.
export async function acceptOnce(p, chain, log, listener, timeoutMs) {
  const slot = p.malloc(8);
  p.write8(slot, 0);
  p.write4(listener.addrlen, 16);

  chain.clear();
  chain.add_syscall_ret(slot, CALL.ACCEPT, listener.sock, listener.peer, listener.addrlen);
  // The launch is async now: it gates on the worker being parked before arming.
  await p.launch_chain_detached(chain);

  return await waitDetached(p, chain, log, slot, timeoutMs);
}

export async function readBytes(p, chain, fd, buf, max) {
  const n = await sys(chain, "READ", fd, buf, max);
  if (isFailure(n)) throw new Error(`read() failed: ${describe(n)}`);
  return n.low >>> 0;
}

export async function writeBytes(p, chain, fd, buf, len) {
  const n = await sys(chain, "WRITE", fd, buf, len);
  if (isFailure(n)) throw new Error(`write() failed: ${describe(n)}`);
  return n.low >>> 0;
}

export async function closeFd(p, chain, fd) {
  return await sys(chain, "CLOSE", fd);
}

// Copy a byte array into an ARW buffer (4 bytes at a time)
export function pushBytes(p, buf, data) {
  const n = data.length;
  const dwords = n >> 2;
  for (let i = 0; i < dwords; i++) {
    const o = i * 4;
    p.write4(buf.add32(o),
      (data[o] | (data[o + 1] << 8) | (data[o + 2] << 16) | (data[o + 3] << 24)) >>> 0);
  }
  for (let i = dwords * 4; i < n; i++) p.write1(buf.add32(i), data[i]);
  return n;
}

// Read bytes from an ARW buffer into a Uint8Array
export function pullBytes(p, buf, len) {
  const out = new Uint8Array(len);
  const dwords = len >> 2;
  for (let i = 0; i < dwords; i++) {
    const v = p.read4(buf.add32(i * 4)) >>> 0;
    const o = i * 4;
    out[o] = v & 0xff;
    out[o + 1] = (v >>> 8) & 0xff;
    out[o + 2] = (v >>> 16) & 0xff;
    out[o + 3] = (v >>> 24) & 0xff;
  }
  for (let i = dwords * 4; i < len; i++) out[i] = p.read1(buf.add32(i));
  return out;
}
