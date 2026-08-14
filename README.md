# ESP32 PS5 WebKit Autoloader

A compact HTTP/HTTPS host for the PS5 WebKit Autoloader, packaged as 4 MB flash images for ESP32-PICO and ESP32-S2 boards. Both targets use the same LittleFS image and do not require PSRAM.

The web content in `autoloader/` is based on a modified version of the [`ps5-webkit-autoloader`](https://github.com/itsPLK/ps5-webkit-autoloader) frontend. Its bundled [`slopkit`](https://github.com/jordyidk/slopkit) and [`ps5-unified-autoloader`](https://github.com/itsPLK/ps5-unified-autoloader) components also contain project-specific modifications and therefore do not exactly match upstream.

## Requirements

- Arduino CLI
- Arduino ESP32 core 2.0.11

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

Use `make pico`, `make s2`, or `make clean` to build an individual target or clean generated files.

## Credits

- [itsPLK/ps5-webkit-autoloader](https://github.com/itsPLK/ps5-webkit-autoloader)
- [itsPLK/ps5-unified-autoloader](https://github.com/itsPLK/ps5-unified-autoloader)
- [jordyidk/slopkit](https://github.com/jordyidk/slopkit)

Credit also belongs to all projects, researchers, and developers referenced by these upstream projects.

## License

Original ESP32 firmware and build code in this repository is MIT licensed. Modified upstream code, bundled payloads, and other third-party material retain their respective upstream terms; see [LICENSE](LICENSE).
