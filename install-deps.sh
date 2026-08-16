#!/usr/bin/env bash

set -euo pipefail

CORE_VERSION="2.0.11"
ARDUINO_INDEX="https://espressif.github.io/arduino-esp32/package_esp32_index.json"
ESP8266_INDEX="https://arduino.esp8266.com/stable/package_esp8266com_index.json"
ESP8266_CORE_VERSION="3.1.2"

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

$SUDO apt-get update
$SUDO apt-get install -y \
    ca-certificates \
    curl \
    git \
    jq \
    nodejs \
    npm \
    openssl \
    python3 \
    unzip \
    xz-utils

$SUDO npm install --global \
    clean-css-cli \
    html-minifier-terser \
    svgo \
    terser

if ! command -v arduino-cli >/dev/null 2>&1; then
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    curl -fsSL \
        https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
        -o "$TMP_DIR/install.sh"

    BINDIR="$TMP_DIR/bin" sh "$TMP_DIR/install.sh"

    $SUDO install -m 755 \
        "$TMP_DIR/bin/arduino-cli" \
        /usr/local/bin/arduino-cli
fi

if [ ! -f "$HOME/.arduino15/arduino-cli.yaml" ]; then
    arduino-cli config init
fi

if ! arduino-cli config dump | grep -Fq "$ARDUINO_INDEX"; then
    arduino-cli config add \
        board_manager.additional_urls \
        "$ARDUINO_INDEX"
fi

if ! arduino-cli config dump | grep -Fq "$ESP8266_INDEX"; then
    arduino-cli config add \
        board_manager.additional_urls \
        "$ESP8266_INDEX"
fi

arduino-cli core update-index

INSTALLED_VERSION="$(
    arduino-cli core list |
    awk '$1 == "esp32:esp32" {print $2}'
)"

if [ "$INSTALLED_VERSION" != "$CORE_VERSION" ]; then
    arduino-cli core install "esp32:esp32@$CORE_VERSION"
fi

INSTALLED_ESP8266_VERSION="$(
    arduino-cli core list |
    awk '$1 == "esp8266:esp8266" {print $2}'
)"

if [ "$INSTALLED_ESP8266_VERSION" != "$ESP8266_CORE_VERSION" ]; then
    arduino-cli core install "esp8266:esp8266@$ESP8266_CORE_VERSION"
fi

echo
arduino-cli version
arduino-cli core list
