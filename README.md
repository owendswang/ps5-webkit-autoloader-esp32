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

Build an individual target:

```sh
make pico
make pico-8m
make s2
make s3
make c3
```

Generated firmware is written to `build/`.

## License

Firmware and build code are MIT licensed. Web content, payloads and other third-party files retain their upstream licenses.
