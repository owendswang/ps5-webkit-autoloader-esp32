# ESP32 PS5 WebKit Autoloader

A compact HTTP/HTTPS host for the PS5 WebKit Autoloader, packaged as 4 MB flash images for ESP32-PICO, ESP32-S2, and ESP-12F (ESP8266) boards. All targets use LittleFS and do not require PSRAM.

The web content in `autoloader/` is based on a modified version of the [`ps5-webkit-autoloader`](https://github.com/itsPLK/ps5-webkit-autoloader) frontend. Its bundled [`slopkit`](https://github.com/jordyidk/slopkit) and [`ps5-unified-autoloader`](https://github.com/itsPLK/ps5-unified-autoloader) components also contain project-specific modifications and therefore do not exactly match upstream.

## Usage

1. Plug the ESP32 into the PS5 and turn on the console.
2. Connect the PS5 to the `ESP32_PORTAL` Wi-Fi network using the password `12345678`.
3. Open **Settings → Guide & Tips ... → Guide & Tips → User's Guide**.
4. Wait for the installation and caching process to finish. Do not disconnect the ESP32 while it is still running.
5. On success, Payload Manager opens automatically and a **WebKit Autoloader** shortcut appears in the **Media** section of the home screen.

After a successful installation, the web content is cached on the PS5 and the ESP32 is no longer required. On subsequent boots, launch **WebKit Autoloader** directly from the Media section.

If an attempt fails, follow the on-screen instruction to reboot and try again. If the console freezes, crashes, or powers off, turn it back on and retry. Use this project at your own risk.

## Requirements

- Arduino CLI
- Arduino ESP32 core 2.0.11
- Arduino ESP8266 core 3.1.2 (required for `make 8266`)

Install the Arduino CLI and required core:

```sh
./install-deps.sh
```

## Build

```sh
make
```

The build copies `autoloader/` to a temporary `data/` directory, compresses the web assets, and creates:

- `build/pico/esp32-arduino.pico.merged.bin`: Intended to support generic ESP32-PICO series boards.
- `build/s2/esp32-arduino.s2.merged.bin`: Intended to support ESP32-S2 series boards.

Use `make pico`, `make s2`, `make 8266`, or `make clean` to build an individual target or clean generated files. The ESP-12F target uses the Generic ESP8266 4 MB / 3 MB LittleFS layout and produces `build/8266/esp8266-arduino.esp12f.merged.bin`.

## Credits

- [itsPLK/ps5-webkit-autoloader](https://github.com/itsPLK/ps5-webkit-autoloader)
- [itsPLK/ps5-unified-autoloader](https://github.com/itsPLK/ps5-unified-autoloader)
- [jordyidk/slopkit](https://github.com/jordyidk/slopkit)

Credit also belongs to all projects, researchers, and developers referenced by these upstream projects.

## License

Original ESP32 firmware and build code in this repository is MIT licensed. Modified upstream code, bundled payloads, and other third-party material retain their respective upstream terms; see [LICENSE](LICENSE).
