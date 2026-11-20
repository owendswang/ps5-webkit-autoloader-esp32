// Bundled paths, resolved against document.baseURI and overridable via LOADER_CONFIG.
"use strict";

export const DEFAULT_BINARIES = {
  // Kernel payload shellcode (v0.8): https://github.com/itsPLK/ps5-kexp
  KEXP_BIN: "shared/kexp-v0.8-24cf6e5.bin",
  // PS5 ELF Loader daemon (v0.26): https://github.com/ps5-payload-dev/elfldr
  ELFLDR_ELF: "shared/elfldr-ps5-v0.26.elf",
};
