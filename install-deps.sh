#!/usr/bin/env bash

set -euo pipefail

CORE_VERSION="2.0.11"
ARDUINO_INDEX="https://espressif.github.io/arduino-esp32/package_esp32_index.json"

ESP8266_INDEX="https://arduino.esp8266.com/stable/package_esp8266com_index.json"
ESP8266_CORE_VERSION="3.1.2"

ARDUINO_DATA_DIR="$HOME/.arduino15-esp32-2"
ARDUINO_STAGING_DIR="$HOME/.arduino15/staging"
ARDUINO_CONFIG="$HOME/.arduino15/arduino-cli-esp32-2.yaml"

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

mkdir -p "$ARDUINO_DATA_DIR"
mkdir -p "$ARDUINO_STAGING_DIR"

cat > "$ARDUINO_CONFIG" <<EOF
directories:
  data: $ARDUINO_DATA_DIR
  downloads: $ARDUINO_STAGING_DIR
board_manager:
  additional_urls:
    - $ARDUINO_INDEX
    - $ESP8266_INDEX
EOF

ARDUINO_CLI=(
    arduino-cli
    --config-file "$ARDUINO_CONFIG"
)

"${ARDUINO_CLI[@]}" core update-index

INSTALLED_VERSION="$(
    "${ARDUINO_CLI[@]}" core list |
    awk '$1 == "esp32:esp32" {print $2}'
)"

if [ "$INSTALLED_VERSION" != "$CORE_VERSION" ]; then
    "${ARDUINO_CLI[@]}" core install "esp32:esp32@$CORE_VERSION"
fi

DNS_SERVER_CPP="$ARDUINO_DATA_DIR/packages/esp32/hardware/esp32/$CORE_VERSION/libraries/DNSServer/src/DNSServer.cpp"

if [ -f "$DNS_SERVER_CPP" ]; then
    sed -i \
        's|^[[:space:]]*//[[:space:]]*#define DEBUG_ESP_DNS|#define DEBUG_ESP_DNS|' \
        "$DNS_SERVER_CPP"
fi

INSTALLED_ESP8266_VERSION="$(
    "${ARDUINO_CLI[@]}" core list |
    awk '$1 == "esp8266:esp8266" {print $2}'
)"

if [ "$INSTALLED_ESP8266_VERSION" != "$ESP8266_CORE_VERSION" ]; then
    "${ARDUINO_CLI[@]}" core install "esp8266:esp8266@$ESP8266_CORE_VERSION"
fi

echo
"${ARDUINO_CLI[@]}" version
"${ARDUINO_CLI[@]}" core list