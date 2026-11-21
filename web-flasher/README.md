# PS5 / PS4 ESP32 Firmware Installer

A static installer for this repository’s PS5 WebKit Autoloader and PS4 host firmware. Vite builds the TypeScript UI and bundles Espressif `esptool-js`. Project firmware writes at `0x0`. The local firmware tab accepts a `.bin` and a hexadecimal write address aligned to 4 KiB. Web Serial verifies data after writing.

## Local development

Use Node.js 22.12 or later. From the repository root:

```sh
cd web-flasher
npm ci
npm run sync:releases
npm run dev
```

Open the loopback URL Vite prints in desktop Chrome or Edge. PS5 defaults to GitHub’s latest release. Select PS4 for PS4 releases, then choose the version and one of the four hardware models. Selecting S2 or PICO shows a larger hardware photograph. S3 and C3 use a question mark until photographs are provided.

**Flash firmware** stays available before the selection is complete. Clicking it marks missing or invalid fields with red borders, red labels and asterisks, explains the requirements above the status area, and focuses the first field to fix. A short shake draws attention to the fields when reduced motion is off. Each corrected field clears immediately. The serial port picker opens only after validation succeeds.

The flasher checks the connected board before writing. Board and firmware controls remain locked from port selection through download, writing and verification. **Serial log** opens by default and keeps download, connection and verification messages in a scrolling area.

PS4 version labels omit the `PS4-` prefix while retaining the original release tag internally. Firmware downloads start after serial port selection and show received bytes and a percentage, with progress entries in the log. The progress bar resets for flashing, then the installer verifies the written data. A green **Success** or red **Failure** block replaces the status row when finished. Detailed results remain in the log, with errors also shown above the status area.

The browser reads `releases/catalog.json` from the deployed site when opened. The catalog contains the four most recently published firmware releases for each platform. After serial port selection, project firmware downloads from the same site into browser memory, with download progress and a SHA-256 check. Local firmware is read directly from the chosen file and stays in the browser. Both modes check the board and flash capacity before writing, then verify the result with MD5.

The sync command downloads release metadata and firmware into the ignored `public/releases/` directory. Run it again to refresh local releases. Files are stored as `files/<asset-id>.bin` and reused when their size and checksum match GitHub’s metadata. After successfully publishing the reduced catalog, synchronization removes old generated firmware files outside the retained four releases per platform. Synchronization uses Undici to honor `HTTP_PROXY`, `HTTPS_PROXY` and `NO_PROXY`, and retries transient failures. `GITHUB_TOKEN` can authenticate API calls during synchronization and stays in the build environment.

PS4 tags and asset names identify historical releases whose prerelease flags differ from the current convention. Other version tags starting with `v` belong to PS5. Remaining releases use the prerelease flag to select PS4 or PS5.

`npm run build` type-checks the source and copies the static site and synchronized firmware to `dist/`. `npm run preview` serves that production build locally.

## GitHub Pages

In the repository’s **Settings → Pages**, select **GitHub Actions** as the publishing source. The workflow synchronizes releases and builds from the default branch on release events, on changes to the flasher on `main`, or when manually dispatched. A six-hour refresh picks up attachments uploaded after publication. The Pages upload includes `catalog.json` and `files/*.bin`. A successful deployment deletes its temporary Actions upload artifact. Artifacts from failed deployments expire after one day. Firmware files remain outside Git history.

## Credits and licensing

The page footer lists installer dependencies, PS5 and PS4 firmware sources, and the applicable licensing notices. Original installer code uses the [MIT license](LICENSE). Vite generates `third-party-licenses.txt` for bundled browser dependencies during production builds. Firmware components retain their upstream licenses and notices, as described in the repository’s root license and release sources.
