# ESP32 PS4 Exploit Host

Offline PS4 exploit host for ESP32 and ESP8266 boards. Web files are stored in LittleFS, minimized and served with gzip compression. No PSRAM is required.

The web interface is based on [ps4-psx8-pulse](https://github.com/owendswang/ps4-psx8-pulse) and [raw-game](https://raw-game.com/zrm/).

## Supported Firmware Version

- 11.50 - 13.00 except 11.52
- 6.00 - 11.02
- 9.00 - 9.60
- 7.00 - 8.52
- 6.72
- 5.05

## Usage

1. Flash the merged image for your board.
2. Connect the PS4 to Wi-Fi:
   - SSID: `ESP32_PORTAL`
   - Password: `12345678`
3. Open the PS4 browser or User's Guide and visit `http://192.168.4.1/`.
4. Select the PS4 firmware version and wait for offline caching to complete.

## Build

Install the required tools and Arduino cores:

```sh
./install-deps.sh
```

Build all ESP32 targets:

```sh
make
```

The default ESP32-S2/S3/C3 firmware leaves native USB disconnected, so the board only draws power from its USB connection. Build the separate debug variant to enable USB CDC/Serial-JTAG output:

```sh
make debug
```

Debug firmware is written to `build/debug/`.

Build only the ESP32-S2 debug firmware with USB CDC output:

```sh
make debug-s2
```

The merged image is written to `build/debug/s2/esp32-arduino.s2.merged.bin`.

Build an individual target:

```sh
make pico
make pico-8m
make s2
make s3
make c3
```

Generated firmware is written to `build/`.

## Manifest updates

ESP32 serves each AppCache manifest with a fresh random `# VERSION` comment and HTTP no-cache headers. The resource list is preserved; LittleFS manifests remain uncompressed so the server can edit the response without writing flash. Rebuild and flash both the firmware and LittleFS image when applying this change (the merged images include both).

This requests an update on each online manifest check. Browsers that fetch the manifest again before committing an update can reject the changing version; verify caching on the target PS4 firmware. Offline visits keep using the existing cache, and an already open page may keep using its old cache until navigation.

## License

Firmware and build code are MIT licensed. Web content, payloads and other third-party files retain their upstream licenses.
