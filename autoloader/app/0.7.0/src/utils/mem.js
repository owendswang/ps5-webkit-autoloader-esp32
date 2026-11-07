import { int64 } from "./int64.js";

let memory = null;

function asInt64(value) {
  if (value instanceof int64) {
    return value;
  }

  if (typeof value === "number") {
    if (!Number.isInteger(value) || value < 0) {
      throw new TypeError(`mem: invalid address ${value}`);
    }

    const high = Math.floor(value / 0x100000000);
    return new int64(value - high * 0x100000000, high);
  }

  if (value && typeof value === "object" && "low" in value) {
    return new int64(value.low, "hi" in value ? value.hi : value.high);
  }

  throw new TypeError("mem: invalid address");
}

function asAddress(value) {
  const address = asInt64(value);
  if (address.hi > 0xffff) {
    throw new RangeError(`mem: non-canonical address 0x${address.toString()}`);
  }
  return address.hi * 0x100000000 + address.low;
}

function asLow32(value, operation) {
  if (typeof value === "number") {
    if (!Number.isInteger(value)) {
      throw new TypeError(`${operation}: value must be an integer`);
    }
    return value >>> 0;
  }

  if (value instanceof int64) {
    return value.low >>> 0;
  }

  if (value && typeof value === "object" && "low" in value) {
    return value.low >>> 0;
  }

  throw new TypeError(`${operation}: invalid value`);
}

function asWords(value) {
  if (value instanceof int64) {
    return [value.low >>> 0, value.hi >>> 0];
  }

  if (value && typeof value === "object" && "low" in value) {
    const high = "hi" in value ? value.hi : value.high;
    return [value.low >>> 0, high >>> 0];
  }

  if (!Number.isInteger(value)) {
    throw new TypeError("mem.write8: invalid value");
  }

  if (value < -0x80000000 || value > 0xffffffff) {
    throw new RangeError("mem.write8: use int64 outside the 32-bit range");
  }

  return value < 0 ? [value >>> 0, 0xffffffff] : [value >>> 0, 0];
}

function readU32(bytes, offset = 0) {
  return (
    bytes[offset] |
    (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) |
    (bytes[offset + 3] << 24)
  ) >>> 0;
}

function writeU32(bytes, offset, value) {
  bytes[offset] = value & 0xff;
  bytes[offset + 1] = (value >>> 8) & 0xff;
  bytes[offset + 2] = (value >>> 16) & 0xff;
  bytes[offset + 3] = (value >>> 24) & 0xff;
}

function selectAddress(address, size) {
  if (!memory) {
    throw new Error("mem: memory window not installed");
  }
  if (size > memory.size) {
    throw new RangeError("mem: access exceeds the memory window");
  }
  memory.setAddress(asAddress(address));
}

function read1(address) {
  selectAddress(address, 1);
  try {
    return memory.bytes[0];
  } finally {
    memory.resetAddress();
  }
}

function read2(address) {
  selectAddress(address, 2);
  try {
    const view = memory.bytes;
    return view[0] | (view[1] << 8);
  } finally {
    memory.resetAddress();
  }
}

function read4(address) {
  selectAddress(address, 4);
  try {
    return readU32(memory.bytes);
  } finally {
    memory.resetAddress();
  }
}

function read8(address) {
  selectAddress(address, 8);
  try {
    return new int64(readU32(memory.bytes), readU32(memory.bytes, 4));
  } finally {
    memory.resetAddress();
  }
}

function write1(address, value) {
  selectAddress(address, 1);
  try {
    memory.bytes[0] = asLow32(value, "mem.write1") & 0xff;
  } finally {
    memory.resetAddress();
  }
}

function write2(address, value) {
  const word = asLow32(value, "mem.write2") & 0xffff;
  selectAddress(address, 2);
  try {
    memory.bytes[0] = word & 0xff;
    memory.bytes[1] = word >>> 8;
  } finally {
    memory.resetAddress();
  }
}

function write4(address, value) {
  selectAddress(address, 4);
  try {
    writeU32(memory.bytes, 0, asLow32(value, "mem.write4"));
  } finally {
    memory.resetAddress();
  }
}

function write8(address, value) {
  const [low, high] = asWords(value);
  selectAddress(address, 8);
  try {
    writeU32(memory.bytes, 0, low);
    writeU32(memory.bytes, 4, high);
  } finally {
    memory.resetAddress();
  }
}

function copyBytes(address, buffer, writing) {
  if (!ArrayBuffer.isView(buffer) || buffer.BYTES_PER_ELEMENT !== 1) {
    throw new TypeError("mem: bulk copy requires a byte typed array");
  }
  const start = asAddress(address);
  if (start + buffer.length > 0x1000000000000) {
    throw new RangeError("mem: bulk copy exceeds canonical address range");
  }
  if (!memory || !Number.isInteger(memory.size) || memory.size <= 0) {
    throw new Error("mem: invalid memory window");
  }
  const bytes = memory.bytes;
  if (bytes.length !== memory.size) throw new Error("mem: memory window size mismatch");
  for (let offset = 0; offset < buffer.length;) {
    const count = Math.min(memory.size, buffer.length - offset);
    // Only slice ordinary source storage, before redirecting. A subview of the
    // native window would capture its backing address and must never escape.
    const source = writing
      ? (offset === 0 && count === buffer.length ? buffer : buffer.subarray(offset, offset + count))
      : null;
    try {
      memory.setAddress(start + offset);
      if (writing) {
        bytes.set(source);
      } else if (count === memory.size) {
        buffer.set(bytes, offset);
      } else {
        // A full-window set would overread a short tail. Keep its exact bounds.
        for (let i = 0; i < count; i++) buffer[offset + i] = bytes[i];
      }
    } finally {
      memory.resetAddress();
    }
    offset += count;
  }
}

function readInto(address, buffer) { copyBytes(address, buffer, false); }
function writeBytes(address, buffer) { copyBytes(address, buffer, true); }

// Diagnostic only: repeat the bulk path's window selection/restoration without
// accessing bytes. No timers or counters are added to the normal copy path.
function probeMemoryWindow(address, length, passes) {
  const start = asAddress(address);
  if (!Number.isInteger(length) || length < 1 || length > 65536 ||
      !Number.isInteger(passes) || passes < 1 || passes > 65536) {
    throw new RangeError("mem: invalid window probe workload");
  }
  if (start + length > 0x1000000000000) throw new RangeError("mem: probe range wraps");
  if (!memory || !Number.isInteger(memory.size) || memory.size <= 0)
    throw new Error("mem: invalid memory window");
  for (let pass = 0; pass < passes; pass++) {
    for (let offset = 0; offset < length; offset += memory.size) {
      try { memory.setAddress(start + offset); }
      finally { memory.resetAddress(); }
    }
  }
  return passes * Math.ceil(length / memory.size);
}

function leakval(object) {
  const type = typeof object;
  if (object === null || (type !== "object" && type !== "function")) {
    throw new TypeError("mem.leakval: expected an object");
  }

  memory.setLeakObject(object);
  try {
    const address = read8(memory.leakAddress);
    if (
      address.hi > 0xffff ||
      (address.low === 0 && address.hi === 0) ||
      (address.low & 7) !== 0
    ) {
      throw new Error(`mem.leakval: invalid cell 0x${address.toString()}`);
    }
    return address;
  } finally {
    memory.clearLeakObject();
  }
}

export function installWindowP(value) {
  if (!value || typeof value.setAddress !== "function") {
    throw new TypeError("mem: invalid memory window");
  }

  memory = value;
  const primitive = {
    read1,
    read2,
    read4,
    read8,
    write1,
    write2,
    write4,
    write8,
    readInto,
    writeBytes,
    probeMemoryWindow,
    memoryWindowSize: memory.size,
    leakval,
  };

  globalThis.p = primitive;
  return primitive;
}
