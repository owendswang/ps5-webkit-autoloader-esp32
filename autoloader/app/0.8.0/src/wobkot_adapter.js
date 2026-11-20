"use strict";

// Compatibility surface for the existing remote protocol and JavaScript
// payload API. Native execution, memory access, offsets and ROP all come from
// Wobkot; this adapter only translates value shapes and records simple batches.
(function () {
  let initialized = false;
  let kernelLoaded = false;
  let relapseAttempted = false;

  function toBInt(value) {
    if (value instanceof BInt) return value;
    if (typeof value === "number" || typeof value === "boolean") return new BInt(value);
    if (value && typeof value === "object" && typeof value.low === "number") {
      const high = value.hi !== undefined ? value.hi :
        (value.high !== undefined ? value.high : 0);
      return new BInt(high >>> 0, value.low >>> 0);
    }
    throw new TypeError(`unsupported native value: ${value}`);
  }

  function toInt64(value) {
    if (!(value instanceof BInt)) value = new BInt(value ?? 0);
    return new globalThis.int64(value.lo, value.hi);
  }

  function firmwareSupported() {
    if (version.console !== 5) return false;
    if (version.major < 6 || version.major > 13) return false;
    return version.major < 13 || version.minor <= 0x60;
  }

  function makeMemoryApi() {
    const allocations = [];
    const address = (value) => toBInt(value);
    const view = (value) => arw.view(address(value));

    const p = {
      allocations,
      libSceNKWebKitBase: toInt64(webkit_base),
      libSceLibcInternalBase: toInt64(libc_base),
      libKernelBase: toInt64(libkernel_base),
      gadgets: {},
      syscalls: new Proxy({}, { get: (_target, key) => {
        const id = Number(key);
        return Number.isInteger(id) ? toInt64(get_syscall(id)) : undefined;
      }}),
      malloc(size) {
        const pointer = mem.alloc(size);
        allocations.push(pointer);
        return toInt64(pointer);
      },
      stringify(value) { return toInt64(String(value).cstr()); },
      leakval(value) { return toInt64(arw.addrof(value)); },
      writestr(value, text) {
        const bytes = new TextEncoder().encode(String(text));
        const target = new Uint8Array(ArrayBuffer.from(address(value), bytes.length + 1));
        target.set(bytes);
        target[bytes.length] = 0;
      },
      read1(value) { return view(value).getUint8(0); },
      read2(value) { return view(value).getUint16(0, true); },
      read4(value) { return view(value).getUint32(0, true); },
      read8(value) { return toInt64(view(value).getBInt(0, true)); },
      write1(value, data) { view(value).setUint8(0, Number(toBInt(data).lo) & 0xff); },
      write2(value, data) { view(value).setUint16(0, Number(toBInt(data).lo) & 0xffff, true); },
      write4(value, data) { view(value).setUint32(0, toBInt(data).lo, true); },
      write8(value, data) { view(value).setBInt(0, toBInt(data), true); },
      readInto(value, target) {
        const source = new Uint8Array(ArrayBuffer.from(address(value), target.byteLength));
        target.set(source);
        return target;
      },
      writeBytes(value, source) {
        const target = new Uint8Array(ArrayBuffer.from(address(value), source.byteLength));
        target.set(source);
      },
      memoryWindowSize: 0x10000,
    };

    const gadgetNames = {
      "ret": "wk_RET", "pop rax": "wk_POP_RAX_RET", "pop rbx": "wk_POP_RBX_RET",
      "pop rcx": "wk_POP_RCX_RET", "pop rdx": "wk_POP_RDX_RET", "pop rdi": "wk_POP_RDI_RET",
      "pop rsi": "wk_POP_RSI_RET", "pop rbp": "wk_POP_RBP_RET", "pop rsp": "wk_POP_RSP_RET",
      "pop r8": "wk_POP_R8_RET", "pop r9": "wk_POP_R9_RET", "pop r11": "wk_POP_R11_RET",
      "pop r12": "wk_POP_R12_RET", "pop r13": "wk_POP_R13_RET", "pop r14": "wk_POP_R14_RET",
      "pop r15": "wk_POP_R15_RET", "mov [rdi], rax": "wk_MOV_QWORD_PTR_RDI_RAX_RET",
      "mov rax, [rdi]": "wk_MOV_RAX_QWORD_PTR_RDI_RET",
    };
    for (const [name, property] of Object.entries(gadgetNames)) {
      try { p.gadgets[name] = toInt64(impl[property]); } catch (_) {}
    }
    return p;
  }

  function makeChain(p) {
    let batch = [];
    const invoke = (target, args) => {
      const native = typeof target === "number"
        ? new NativeFunction(target, "bint")
        : new NativeFunction(toBInt(target), "bint");
      const nativeArgs = args.map((value) => typeof value === "string" ? value : toBInt(value));
      return toInt64(native.invoke(...nativeArgs));
    };
    return {
      p,
      clear() { batch = []; },
      async syscall(number, ...args) { return invoke(number, args); },
      async call(target, ...args) { return invoke(target, args); },
      add_syscall_ret(destination, number, ...args) {
        batch.push({ destination, number, args });
      },
      async run() {
        for (const item of batch) p.write8(item.destination, invoke(item.number, item.args));
        batch = [];
        return new globalThis.int64(0, 0);
      },
    };
  }

  async function initialize() {
    if (initialized) return window.wobkot.runtime;
    version.init();
    if (!firmwareSupported()) throw new Error(`Wobkot does not support PS5 firmware ${version}`);
    window.fw_str = version.toString();
    await userland_main();
    const p = makeMemoryApi();
    const chain = makeChain(p);
    initialized = true;
    window.wobkot.runtime = { p, chain };
    return window.wobkot.runtime;
  }

  async function runRelapse() {
    await initialize();
    if (relapseAttempted)
      throw new Error("Wobkot Relapse has already been attempted in this page; reload after a clean reboot");
    relapseAttempted = true;
    if (!kernelLoaded) {
      await load_script("src/kernel.js");
      kernelLoaded = true;
    }
    // Wobkot emits its own "Jailbroken !!" system toast after patching the
    // process. The loader already reports completion in its UI, so suppress
    // that one redundant notification without modifying the upstream
    // submodule or swallowing any other notification Wobkot may add.
    const upstreamNotify = globalThis.notify;
    if (typeof upstreamNotify === "function") {
      globalThis.notify = (message, ...args) => {
        if (String(message) === "Jailbroken !!") return;
        return upstreamNotify(message, ...args);
      };
    }
    try {
      await kernel_main();
    } finally {
      if (typeof upstreamNotify === "function") globalThis.notify = upstreamNotify;
    }
  }

  window.wobkot = { initialize, runRelapse, runtime: null };
})();
