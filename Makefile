SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
.NOTPARALLEL:
.DEFAULT_GOAL := all

PROJECT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME := esp32-arduino
SOURCE_DATA_DIR := $(PROJECT_DIR)/autoloader
DATA_DIR := $(PROJECT_DIR)/data
BUILD_DIR := $(PROJECT_DIR)/build
SERVER_CERT := $(PROJECT_DIR)/server.crt
SERVER_KEY := $(PROJECT_DIR)/server.key
SERVER_HEADER := $(PROJECT_DIR)/server_certs.h
CERT_EMBEDDER := $(PROJECT_DIR)/embed_cert.py
COMMON_BUILD_DIR := $(BUILD_DIR)/common
PICO_BUILD_DIR := $(BUILD_DIR)/pico
S2_BUILD_DIR := $(BUILD_DIR)/s2
C3_BUILD_DIR := $(BUILD_DIR)/c3
PICO_8M_BUILD_DIR := $(BUILD_DIR)/pico-8m
PICO_8M_SKETCH_DIR := $(PICO_8M_BUILD_DIR)/sketch/$(PROJECT_NAME)
PICO_8M_OUTPUT_DIR := $(PICO_8M_BUILD_DIR)/output

ARDUINO_ROOT ?= $(HOME)/.arduino15/packages/esp32
CORE_VERSION := 2.0.11
CORE_DIR := $(ARDUINO_ROOT)/hardware/esp32/$(CORE_VERSION)
ESPTOOL := $(ARDUINO_ROOT)/tools/esptool_py/4.5.1/esptool.py
PARTITION_TOOL := $(CORE_DIR)/tools/gen_esp32part.py
LITTLEFS_TOOL := $(shell find "$(ARDUINO_ROOT)/tools" -name mklittlefs -type f 2>/dev/null | head -n1)

PICO_FQBN := esp32:esp32:esp32:CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose,PSRAM=disabled
S2_FQBN := esp32:esp32:esp32s2:CDCOnBoot=cdc,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose,PSRAM=disabled
PICO_8M_FQBN := esp32:esp32:esp32:CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=8M,DebugLevel=verbose,PSRAM=disabled
C3_FQBN := esp32:esp32:esp32c3:CDCOnBoot=cdc,CPUFreq=160,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose

FLASH_SIZE := 4194304
APP_PARTITION_SIZE := 1048576
LITTLEFS_SIZE := 0x2F0000
LITTLEFS_OFFSET := 0x110000
PICO_8M_FLASH_SIZE := 8388608
PICO_8M_APP_PARTITION_SIZE := 1572864
PICO_8M_LITTLEFS_SIZE := 0x660000
PICO_8M_LITTLEFS_OFFSET := 0x190000

LITTLEFS_IMAGE := $(COMMON_BUILD_DIR)/$(PROJECT_NAME).littlefs.bin
PICO_APP := $(PICO_BUILD_DIR)/$(PROJECT_NAME).ino.bin
PICO_BOOTLOADER := $(PICO_BUILD_DIR)/$(PROJECT_NAME).ino.bootloader.bin
PICO_PARTITIONS := $(PICO_BUILD_DIR)/$(PROJECT_NAME).ino.partitions.bin
PICO_MERGED := $(PICO_BUILD_DIR)/$(PROJECT_NAME).pico.merged.bin
S2_APP := $(S2_BUILD_DIR)/$(PROJECT_NAME).ino.bin
S2_BOOTLOADER := $(S2_BUILD_DIR)/$(PROJECT_NAME).ino.bootloader.bin
S2_PARTITIONS := $(S2_BUILD_DIR)/$(PROJECT_NAME).ino.partitions.bin
S2_MERGED := $(S2_BUILD_DIR)/$(PROJECT_NAME).s2.merged.bin
PICO_8M_LITTLEFS_IMAGE := $(PICO_8M_BUILD_DIR)/$(PROJECT_NAME).littlefs.bin
PICO_8M_APP := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.bin
PICO_8M_BOOTLOADER := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.bootloader.bin
PICO_8M_PARTITIONS := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.partitions.bin
PICO_8M_MERGED := $(PICO_8M_BUILD_DIR)/$(PROJECT_NAME).pico-8m.merged.bin
C3_APP := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.bin
C3_BOOTLOADER := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.bootloader.bin
C3_PARTITIONS := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.partitions.bin
C3_MERGED := $(C3_BUILD_DIR)/$(PROJECT_NAME).c3.merged.bin

.PHONY: all pico pico-8m s2 c3 check clean FORCE

all: check $(PICO_MERGED) $(S2_MERGED)
	@echo
	echo "Build complete:"
	ls -lh "$(PICO_MERGED)" "$(S2_MERGED)" "$(LITTLEFS_IMAGE)"

pico: check $(PICO_MERGED)
	@ls -lh "$(PICO_MERGED)"

pico-8m: check $(PICO_8M_MERGED)
	@ls -lh "$(PICO_8M_MERGED)" "$(PICO_8M_LITTLEFS_IMAGE)"

s2: check $(S2_MERGED)
	@ls -lh "$(S2_MERGED)"

c3: check $(C3_MERGED)
	@ls -lh "$(C3_MERGED)"

check:
	@command -v arduino-cli >/dev/null
	command -v gzip >/dev/null
	command -v openssl >/dev/null
	command -v python3 >/dev/null
	test -d "$(CORE_DIR)" || { echo "Error: esp32:esp32@$(CORE_VERSION) is not installed" >&2; exit 1; }
	test -f "$(ESPTOOL)" || { echo "Error: $(ESPTOOL) was not found" >&2; exit 1; }
	test -f "$(PARTITION_TOOL)" || { echo "Error: $(PARTITION_TOOL) was not found" >&2; exit 1; }
	test -x "$(LITTLEFS_TOOL)" || { echo "Error: mklittlefs was not found" >&2; exit 1; }
	test -f "$(PROJECT_DIR)/$(PROJECT_NAME).ino"
	test -d "$(SOURCE_DATA_DIR)"

$(SERVER_CERT) $(SERVER_KEY) &:
	@echo "Generating a self-signed HTTPS certificate..."
	openssl ecparam -name prime256v1 \
		-genkey \
		-noout \
		-out "$(SERVER_KEY)"
	openssl req -new -x509 \
		-sha256 \
		-days 3650 \
		-key "$(SERVER_KEY)" \
		-out "$(SERVER_CERT)" \
		-subj "/CN=manuals.playstation.net" \
		-addext "subjectAltName=DNS:manuals.playstation.net,IP:192.168.4.1"
	chmod 600 "$(SERVER_KEY)"

$(SERVER_HEADER): $(SERVER_CERT) $(SERVER_KEY) $(CERT_EMBEDDER)
	@python3 "$(CERT_EMBEDDER)" "$(SERVER_CERT)" "$(SERVER_KEY)" "$(SERVER_HEADER)"

$(PICO_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@mkdir -p "$(PICO_BUILD_DIR)"
	arduino-cli compile \
	    --fqbn "$(PICO_FQBN)" \
	    --output-dir "$(PICO_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(PROJECT_DIR)"
	size=$$(stat -c %s "$(PICO_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: Pico application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(S2_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@mkdir -p "$(S2_BUILD_DIR)"
	arduino-cli compile \
	    --fqbn "$(S2_FQBN)" \
	    --output-dir "$(S2_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(PROJECT_DIR)"
	size=$$(stat -c %s "$(S2_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: S2 application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(PICO_8M_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions-8m.csv Makefile
	@rm -rf "$(PICO_8M_SKETCH_DIR)" "$(PICO_8M_OUTPUT_DIR)"
	mkdir -p "$(PICO_8M_SKETCH_DIR)" "$(PICO_8M_OUTPUT_DIR)"
	cp "$(PROJECT_DIR)/$(PROJECT_NAME).ino" "$(SERVER_HEADER)" "$(PICO_8M_SKETCH_DIR)/"
	cp "$(PROJECT_DIR)/partitions-8m.csv" "$(PICO_8M_SKETCH_DIR)/partitions.csv"
	arduino-cli compile \
	    --fqbn "$(PICO_8M_FQBN)" \
	    --output-dir "$(PICO_8M_OUTPUT_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(PICO_8M_SKETCH_DIR)"
	size=$$(stat -c %s "$(PICO_8M_APP)")
	test "$$size" -le "$(PICO_8M_APP_PARTITION_SIZE)" || { echo "Error: Pico 8 MB application exceeds the 1.5 MB partition: $$size bytes" >&2; exit 1; }

$(C3_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@mkdir -p "$(C3_BUILD_DIR)"
	arduino-cli compile \
	    --fqbn "$(C3_FQBN)" \
	    --output-dir "$(C3_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(PROJECT_DIR)"
	size=$$(stat -c %s "$(C3_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: C3 application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(LITTLEFS_IMAGE): FORCE
	@echo
	echo "Preparing shared LittleFS data..."
	rm -rf "$(DATA_DIR)" "$(COMMON_BUILD_DIR)"
	mkdir -p "$(DATA_DIR)" "$(COMMON_BUILD_DIR)"
	cp -a "$(SOURCE_DATA_DIR)/." "$(DATA_DIR)/"
	find "$(DATA_DIR)" -type f -name '*.gz' -delete
	find "$(DATA_DIR)" -type f \( \
	    -name '*.html' -o \
	    -name '*.js' -o \
	    -name '*.elf' -o \
	    -name '*.bin' -o \
      -name 'cache.appcache' -o \
      -name '*.svg' -o \
      -name '*.css' \
	\) -print0 | while IFS= read -r -d '' file; do
	    gzip -k -9 -n "$$file"
	    rm -f "$$file"
	done
	"$(LITTLEFS_TOOL)" \
	    -c "$(DATA_DIR)" \
	    -p 256 \
	    -b 4096 \
	    -s "$(LITTLEFS_SIZE)" \
	    "$(LITTLEFS_IMAGE)"

$(PICO_MERGED): $(PICO_APP) $(LITTLEFS_IMAGE)
	@python3 "$(ESPTOOL)" \
	    --chip esp32 \
	    merge_bin \
	    -o "$(PICO_MERGED)" \
	    --flash_mode dio \
	    --flash_freq 40m \
	    --flash_size 4MB \
	    0x1000 "$(PICO_BOOTLOADER)" \
	    0x8000 "$(PICO_PARTITIONS)" \
	    0x10000 "$(PICO_APP)" \
	    "$(LITTLEFS_OFFSET)" "$(LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(PICO_MERGED)")
	test "$$size" -le "$(FLASH_SIZE)" || { echo "Error: Pico image exceeds 4 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(FLASH_SIZE)" ]; then
	    padding=$$(($(FLASH_SIZE) - size))
	    head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(PICO_MERGED)"
	fi
	test "$$(stat -c %s "$(PICO_MERGED)")" -eq "$(FLASH_SIZE)"

$(S2_MERGED): $(S2_APP) $(LITTLEFS_IMAGE)
	@python3 "$(ESPTOOL)" \
	    --chip esp32s2 \
	    merge_bin \
	    -o "$(S2_MERGED)" \
	    --flash_mode dio \
	    --flash_freq 40m \
	    --flash_size 4MB \
	    0x1000 "$(S2_BOOTLOADER)" \
	    0x8000 "$(S2_PARTITIONS)" \
	    0x10000 "$(S2_APP)" \
	    "$(LITTLEFS_OFFSET)" "$(LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(S2_MERGED)")
	test "$$size" -le "$(FLASH_SIZE)" || { echo "Error: S2 image exceeds 4 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(FLASH_SIZE)" ]; then
	    padding=$$(($(FLASH_SIZE) - size))
	    head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(S2_MERGED)"
	fi
	test "$$(stat -c %s "$(S2_MERGED)")" -eq "$(FLASH_SIZE)"

$(C3_MERGED): $(C3_APP) $(LITTLEFS_IMAGE)
	@python3 "$(ESPTOOL)" \
	    --chip esp32c3 \
	    merge_bin \
	    -o "$(C3_MERGED)" \
	    --flash_mode dio \
	    --flash_freq 40m \
	    --flash_size 4MB \
	    0x0 "$(C3_BOOTLOADER)" \
	    0x8000 "$(C3_PARTITIONS)" \
	    0x10000 "$(C3_APP)" \
	    "$(LITTLEFS_OFFSET)" "$(LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(C3_MERGED)")
	test "$$size" -le "$(FLASH_SIZE)" || { echo "Error: C3 image exceeds 4 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(FLASH_SIZE)" ]; then
	    padding=$$(($(FLASH_SIZE) - size))
	    head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(C3_MERGED)"
	fi
	test "$$(stat -c %s "$(C3_MERGED)")" -eq "$(FLASH_SIZE)"

$(PICO_8M_LITTLEFS_IMAGE): FORCE
	@echo
	echo "Preparing Pico 8 MB LittleFS data..."
	rm -rf "$(DATA_DIR)"
	mkdir -p "$(DATA_DIR)" "$(PICO_8M_BUILD_DIR)"
	cp -a "$(SOURCE_DATA_DIR)/." "$(DATA_DIR)/"
	find "$(DATA_DIR)" -type f -name '*.gz' -delete
	find "$(DATA_DIR)" -type f \( \
	    -name '*.html' -o \
	    -name '*.js' -o \
	    -name '*.elf' -o \
	    -name '*.bin' \
	\) -print0 | while IFS= read -r -d '' file; do
	    gzip -k -9 -n "$$file"
	    rm -f "$$file"
	done
	"$(LITTLEFS_TOOL)" \
	    -c "$(DATA_DIR)" \
	    -p 256 \
	    -b 4096 \
	    -s "$(PICO_8M_LITTLEFS_SIZE)" \
	    "$(PICO_8M_LITTLEFS_IMAGE)"

$(PICO_8M_MERGED): $(PICO_8M_APP) $(PICO_8M_LITTLEFS_IMAGE)
	@python3 "$(ESPTOOL)" \
	    --chip esp32 \
	    merge_bin \
	    -o "$(PICO_8M_MERGED)" \
	    --flash_mode dio \
	    --flash_freq 40m \
	    --flash_size 8MB \
	    0x1000 "$(PICO_8M_BOOTLOADER)" \
	    0x8000 "$(PICO_8M_PARTITIONS)" \
	    0x10000 "$(PICO_8M_APP)" \
	    "$(PICO_8M_LITTLEFS_OFFSET)" "$(PICO_8M_LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(PICO_8M_MERGED)")
	test "$$size" -le "$(PICO_8M_FLASH_SIZE)" || { echo "Error: Pico image exceeds 8 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(PICO_8M_FLASH_SIZE)" ]; then
	    padding=$$(($(PICO_8M_FLASH_SIZE) - size))
	    head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(PICO_8M_MERGED)"
	fi
	test "$$(stat -c %s "$(PICO_8M_MERGED)")" -eq "$(PICO_8M_FLASH_SIZE)"

clean:
	@rm -rf "$(BUILD_DIR)" "$(DATA_DIR)"

FORCE:
