// socket_test.js — standalone diagnostic for listening sockets over userland WebKit ROP.

const AF_INET = 2;
const SOCK_STREAM = 1;
const SOL_SOCKET = 0xffff;
const SO_REUSEADDR = 4;

const ERRNO = {
  0x04: "EINTR",
  0x20: "EAGAIN",
  0x22: "EINVAL",
  0x30: "EADDRINUSE",
  0x36: "EAFNOSUPPORT",
  0x38: "EADDRNOTAVAIL",
  0x42: "EPERM",
  0x60: "ENOTSOCK",
  0x78: "ENOSPC",
};

const TEST_PORT = 9027;
const READ_MAX = 64 * 1024;
const ACCEPT_WAIT_MS = 150 * 1000;

function hex32(v) {
  return "0x" + (v >>> 0).toString(16).padStart(8, "0");
}

function htons(port) {
  return ((port & 0xff) << 8) | ((port >> 8) & 0xff);
}

function ntohs(word) {
  return ((word & 0xff) << 8) | ((word >> 8) & 0xff);
}

function describe(v) {
  const low = v.low >>> 0;
  if (low === 0xffffffff && v.hi === 0xffffffff) return "-1 (failure)";
  if (low === 0xffffffff) return "0xFFFFFFFF (-1)";
  const name = ERRNO[low];
  return name ? `${low} (${name})` : String(low);
}

function isMinusOne(v) {
  const low = v.low >>> 0;
  return (low === 0xffffffff && v.hi === 0) || (low === 0xffffffff && v.hi === 0xffffffff);
}

function isFailure(v) {
  return isMinusOne(v) || (v.hi === 0 && ERRNO[v.low >>> 0] !== undefined);
}

// Inlined syscall numbers verified against syscalls.js in main.js
const CALL = {
  SOCKET: 0x061,
  SETSOCKOPT: 0x069,
  BIND: 0x068,
  LISTEN: 0x06a,
  GETSOCKNAME: 0x020,
  ACCEPT: 0x01e,
  READ: 0x003,
  CLOSE: 0x006,
};

async function sys(chain, name, ...args) {
  const nr = CALL[name];
  if (nr === undefined) throw new Error(`socket_test: unknown syscall ${name}`);
  return await chain.syscall(nr, ...args);
}

export { CALL };

export async function runSocketTest(p, chain, log) {
  const say = typeof log === "function" ? log : () => {};

  say(`starting socket probe on port ${TEST_PORT}`, "info");

  const sockaddr = p.malloc(16);
  const peer = p.malloc(16);
  const addrlen = p.malloc(8);
  const optval = p.malloc(4);
  const buf = p.malloc(READ_MAX);

  // struct sockaddr_in (16 bytes)
  function buildSockaddr(port) {
    p.write1(sockaddr.add32(0), 0);
    p.write1(sockaddr.add32(1), AF_INET);
    p.write2(sockaddr.add32(2), htons(port));
    p.write4(sockaddr.add32(4), 0); // INADDR_ANY
    for (let i = 8; i < 16; i++) p.write1(sockaddr.add32(i), 0);
  }

  // 1. socket
  const sock = await sys(chain, "SOCKET", AF_INET, SOCK_STREAM, 0);
  if (isFailure(sock) || sock.hi !== 0) {
    say(`socket() failed: ${describe(sock)}`, "error");
    return { done: false, stage: "socket" };
  }
  say(`socket() = fd ${sock.low}`, "success");

  // 2. SO_REUSEADDR
  p.write4(optval, 1);
  const so = await sys(chain, "SETSOCKOPT", sock, SOL_SOCKET, SO_REUSEADDR, optval, 4);
  if (isFailure(so)) {
    say(`setsockopt(SO_REUSEADDR) = ${describe(so)} (non-fatal, continuing)`, "info");
  } else {
    say(`setsockopt(SO_REUSEADDR) ok`, "info");
  }

  // 3. bind
  buildSockaddr(TEST_PORT);
  p.write4(addrlen, 16);
  const bindr = await sys(chain, "BIND", sock, sockaddr, 16);
  if (isFailure(bindr)) {
    say(`bind(${TEST_PORT}) failed: ${describe(bindr)}`, "error");
    say(`if this is EADDRINUSE, something already holds the port`, "info");
    return { done: false, stage: "bind" };
  }
  say(`bind(${TEST_PORT}) ok`, "success");

  // 4. listen
  const lis = await sys(chain, "LISTEN", sock, 3);
  if (isFailure(lis)) {
    say(`listen() failed: ${describe(lis)}`, "error");
    return { done: false, stage: "listen" };
  }
  say(`listen(backlog=3) ok`, "success");

  // 5. getsockname
  p.write4(addrlen, 16);
  await sys(chain, "GETSOCKNAME", sock, sockaddr, addrlen);
  const boundPort = ntohs(p.read2(sockaddr.add32(2)));
  say(`getsockname() reports port ${boundPort}`, "info");

  // 6. accept() running detached in worker
  const accSlot = p.malloc(8);
  p.write8(accSlot, 0);

  say(`now connect to port ${boundPort} from the PC:`, "info");
  say(`  nc ${location.hostname || "<ps5-ip>"} ${boundPort}`, "info");
  say(`waiting for a connection (worker is parked in accept)`, "info");

  p.write4(addrlen, 16);
  chain.clear();
  chain.add_syscall_ret(accSlot, CALL.ACCEPT, sock, peer, addrlen);
  // The launch is async now: it gates on the worker being parked before arming.
  await p.launch_chain_detached(chain);

  const deadline = Date.now() + ACCEPT_WAIT_MS;
  let client = null;
  let lastTick = 0;
  while (Date.now() < deadline) {
    const v = p.read8(accSlot);
    if (v.low !== 0 || v.hi !== 0) {
      client = v;
      break;
    }
    if (Date.now() - lastTick > 5000) {
      lastTick = Date.now();
      say(`still listening...`, "info");
    }
    await new Promise((r) => setTimeout(r, 250));
  }

  if (client === null) {
    say(`no connection within ${ACCEPT_WAIT_MS / 1000}s`, "error");
    return { done: false, stage: "timeout" };
  }

  if (isFailure(client)) {
    say(`accept() failed: ${describe(client)}`, "error");
    return { done: false, stage: "accept" };
  }
  say(`accept() = client fd ${client.low}`, "success");

  // 7. read payload
  await new Promise((r) => setTimeout(r, 1000));
  chain.clear();

  const n = await sys(chain, "READ", client, buf, READ_MAX);
  if (isFailure(n) || n.hi !== 0) {
    say(`read() failed: ${describe(n)}`, "error");
    return { done: false, stage: "read" };
  }
  const got = n.low >>> 0;

  say(`read() = ${got} bytes`, "success");
  say(`SOCKET TEST PASSED -- userland listening socket works, no kernel exploit`, "success");

  try {
    say(`--- payload preview (${Math.min(got, 256)} bytes) ---`, "info");
    const previewLen = Math.min(got, 256);
    let hex = "";
    let text = "";
    for (let i = 0; i < previewLen; i++) {
      const b = p.read1(buf.add32(i));
      hex += b.toString(16).padStart(2, "0");
      text += b >= 0x20 && b < 0x7f ? String.fromCharCode(b) : ".";
    }
    for (let i = 0; i < hex.length; i += 32)
      say(`| ${hex.slice(i, i + 32)}  ${text.slice(i / 2, i / 2 + 16)}`, "info");
  } catch (e) {
    say(`(preview failed: ${e && e.message ? e.message : e} -- result above stands)`, "info");
  }

  try {
    await sys(chain, "CLOSE", client);
    say(`client fd closed`, "info");
  } catch (e) {
    say(`(close failed: ${e && e.message ? e.message : e})`, "info");
  }

  return { done: true, stage: "complete", port: boundPort, bytes: got };
}
