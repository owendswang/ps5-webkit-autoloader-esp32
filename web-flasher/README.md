# PS5 / PS4 ESP32 Firmware Installer

## Introduction

Install this project's PS5 WebKit Autoloader or PS4 web host firmware on an ESP32-S2, ESP32-PICO, ESP32-S3 or ESP32-C3 USB dongle directly from your browser.

[Open the web flasher](https://owendswang.github.io/ps5-webkit-autoloader-esp32/)

The page uses Chinese when it is your browser's first preferred language, and English otherwise. Appearance follows your system. Use the header controls to override either preference; your choices are saved in this browser.

## Usage

1. Open the web flasher in a desktop browser with Web Serial support.
2. Select your board model. Use the hardware preview to identify it.
3. Under **Project firmware**, select **PS5** or **PS4** and a firmware version. The latest PS5 release is selected by default.
4. Plug the dongle directly into your computer's USB port. For **ESP32-S2**, hold **RST** while inserting, then release it. For **ESP32-PICO**, simply plug it into your computer's USB port.
5. Click **Flash firmware**, select the board's serial port, and keep it plugged in until **Success** appears. Errors and retry instructions appear above the progress area, with details in **Serial log**.

To use your own image, choose **Local firmware**, select a `.bin` for your board and enter its write address. The default is `0x0`, and addresses must be aligned to 4 KiB. Project releases always write at `0x0`. Local files stay in your browser.

## Credits

- Firmware flashing: [Espressif esptool-js](https://github.com/espressif/esptool-js).
- Public success counts: [Count API](https://countapi.mileshilliard.com/).
- Checksums and compression: [noble-hashes](https://github.com/paulmillr/noble-hashes) and [pako](https://github.com/nodeca/pako).
- Typeface: [Chivo by Omnibus-Type](https://github.com/Omnibus-Type/Chivo), distributed by [Fontsource](https://fontsource.org/fonts/chivo).
- PS5 firmware sources: [ps5-webkit-autoloader](https://github.com/itsPLK/ps5-webkit-autoloader) and [ps5-unified-autoloader](https://github.com/owendswang/ps5-unified-autoloader).
- PS4 firmware source: [ps4-psx8-pulse](https://github.com/owendswang/ps4-psx8-pulse).
- Interface design and motion: design-taste-frontend. Hardware photographs supplied by the project maintainer. Further upstream credits appear in the page's **Credits** section.

## Licenses

- Original web installer code: [MIT](LICENSE).
- Dependencies: esptool-js uses Apache-2.0, noble-hashes uses MIT, pako uses MIT/Zlib, and Chivo uses SIL OFL-1.1. See the [bundled dependency notices](https://owendswang.github.io/ps5-webkit-autoloader-esp32/third-party-licenses.txt).
- Firmware: see the [project licensing notice](../LICENSE). Third-party firmware, web content and payloads retain their upstream terms. Interface assets and photographs retain their authors' rights. Further notices appear in the page's **License** section.
