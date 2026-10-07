# ESP32 PS5 WebKit Autoloader

A compact HTTP/HTTPS host for the PS5 WebKit Autoloader, packaged as 4 MB flash images for ESP32-PICO, ESP32-S2, ESP32-S3 and ESP32-C3 boards. All targets use LittleFS and do not require PSRAM.

The web content in `autoloader/` is based on a modified version of the [`ps5-webkit-autoloader`](https://github.com/itsPLK/ps5-webkit-autoloader) frontend. Its bundled [`slopkit`](https://github.com/itsPLK/slopkit), [`umtx2`](https://github.com/idlesauce/umtx2) and [`ps5-unified-autoloader`](https://github.com/owendswang/ps5-unified-autoloader/tree/feat/install-webkit-shortcut) components also contain project-specific modifications and therefore do not exactly match upstream.

## Firmware Version Supports

- ~~umtx2        1.00 -  5.50~~ NOT SUPPORTED (`System out of memory` Error)
- poops        7.00 - 12.00
- relapse        7.00 - 13.60   (except 9.05 and 11.40)

You could choose to use poops or relapse if your FW supports both methods while caching. It would use Poops by default if you don't choose.

## Usage

1. Plug the ESP32 into the PS5 and turn on the console.
2. Connect the PS5 to the `ESP32_PORTAL` Wi-Fi network using the password `12345678`.
3. Open **Settings → Guide & Tips ... → Guide & Tips → User's Guide**.
4. Wait for the installation and caching process to finish. Do not disconnect the ESP32 while it is still running.
5. On success, Payload Manager opens automatically and a **WebKit Autoloader** shortcut appears in the **Media** section of the home screen.

After a successful installation, the web content is cached on the PS5. On subsequent boots, launch **WebKit Autoloader** directly from the Media section.

A network connection is still **REQUIRED** to complete the exploit process, as the exploit method relies on the PS5 having an active network interface and IP address. Internet access itself is not required.

If an attempt fails, follow the on-screen instruction to reboot and try again. If the console freezes, crashes, or powers off, turn it back on and retry. Use this project at your own risk.

## Requirements

- Arduino CLI
- Arduino ESP32 core 2.0.11
- ~~Arduino ESP8266 core 3.1.2 (required for `make 8266`)~~

Install the Arduino CLI and required core:

```sh
./install-deps.sh
```

## Build

```sh
make
```

The default ESP32-S2/S3/C3/PICO firmware leaves native USB disconnected, so the board only draws power from its USB connection. Build the separate debug variant to enable USB CDC/Serial-JTAG output:

```sh
make debug
```

Debug firmware is written to `build/debug/`. For the ESP32-S2 alone, use `make debug-s2`. To timestamp every serial line from 00:00:00, run `python serial_timestamp.py COM4 115200` (requires pyserial).

DNS resolves `manuals.playstation.net`, `ena.net.playstation.net` and `www.msftconnecttest.com` to the ESP32; other names receive NXDOMAIN. The build creates a modified copy of Arduino ESP32 2.0.11's DNSServer under ignored `build/` using `prepare-dns-library.py`. That library retains its [upstream LGPL-2.1 license](https://github.com/espressif/arduino-esp32/blob/2.0.11/LICENSE.md).

The build copies `autoloader/` to a temporary `data/` directory, compresses the web assets, and creates:

- `build/pico/esp32-arduino.pico.merged.bin`: Intended to support generic ESP32-PICO series boards.
- `build/s2/esp32-arduino.s2.merged.bin`: Intended to support ESP32-S2 series boards.
- `build/s3/esp32-arduino.s3.merged.bin`: Intended to support ESP32-S3 series boards.
- `build/c3/esp32-arduino.c3.merged.bin`: Intended to support ESP32-C3 series boards.

Use `make pico`, `make s2`, `make s3`, `make c3`~~, `make 8266`~~, or `make clean` to build an individual target or clean generated files. ~~The ESP-12F target uses the Generic ESP8266 4 MB / 3 MB LittleFS layout and produces `build/8266/esp8266-arduino.esp12f.merged.bin`.~~

## Manifest updates

ESP32 serves `.appcache`, `.manifest`, and `.cache` files over HTTP and HTTPS
with a random 16-digit hexadecimal `# VERSION` comment generated once per boot
and HTTP no-cache headers. Resource lists are preserved; the generated version
is not written to flash. Manifests remain uncompressed in LittleFS.

Rebuild and flash the merged image so both firmware and LittleFS are updated.
The version stays the same across HTTP and HTTPS requests until ESP32 restarts,
so a browser's final manifest consistency check receives identical content.
After a restart, the new version triggers an update on the next online cache
check. Repeated visits during the same boot do not force another update;
offline visits keep the existing cache.

## Credits

- [itsPLK/ps5-webkit-autoloader](https://github.com/itsPLK/ps5-webkit-autoloader)
- [itsPLK/ps5-unified-autoloader](https://github.com/itsPLK/ps5-unified-autoloader)
- [jordyidk/slopkit](https://github.com/jordyidk/slopkit)

Credit also belongs to all projects, researchers, and developers referenced by these upstream projects.

## License

Original ESP32 firmware and build code in this repository is MIT licensed. Modified upstream code, bundled payloads, and other third-party material retain their respective upstream terms; see [LICENSE](LICENSE).
