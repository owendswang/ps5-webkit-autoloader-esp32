SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
.NOTPARALLEL:
.DEFAULT_GOAL := all

PROJECT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME := esp32-arduino
SOURCE_DATA_DIR := $(PROJECT_DIR)/henloader
MINIFIED_DATA_DIR := $(PROJECT_DIR)/henloader.mini
DATA_DIR := $(PROJECT_DIR)/data
BUILD_DIR := $(PROJECT_DIR)/build
SERVER_CERT := $(PROJECT_DIR)/server_x509.crt
SERVER_KEY := $(PROJECT_DIR)/server_rsa.key
SERVER_HEADER := $(PROJECT_DIR)/server_certs.h
CERT_EMBEDDER := $(PROJECT_DIR)/embed_cert.py
DATA_PREPARER := $(PROJECT_DIR)/prepare-data.sh
COMMON_BUILD_DIR := $(BUILD_DIR)/common
PICO_BUILD_DIR := $(BUILD_DIR)/pico
S2_BUILD_DIR := $(BUILD_DIR)/s2
S3_BUILD_DIR := $(BUILD_DIR)/s3
C3_BUILD_DIR := $(BUILD_DIR)/c3
ESP8266_BUILD_DIR := $(BUILD_DIR)/8266
ESP8266_SKETCH_DIR := $(ESP8266_BUILD_DIR)/sketch/esp8266-arduino
PICO_SKETCH_DIR := $(PICO_BUILD_DIR)/sketch/$(PROJECT_NAME)
S2_SKETCH_DIR := $(S2_BUILD_DIR)/sketch/$(PROJECT_NAME)
S3_SKETCH_DIR := $(S3_BUILD_DIR)/sketch/$(PROJECT_NAME)
C3_SKETCH_DIR := $(C3_BUILD_DIR)/sketch/$(PROJECT_NAME)
PICO_8M_BUILD_DIR := $(BUILD_DIR)/pico-8m
PICO_8M_SKETCH_DIR := $(PICO_8M_BUILD_DIR)/sketch/$(PROJECT_NAME)
PICO_8M_OUTPUT_DIR := $(PICO_8M_BUILD_DIR)/output

ARDUINO_ROOT ?= $(HOME)/.arduino15/packages/esp32
ESP8266_ROOT ?= $(abspath $(ARDUINO_ROOT)/../esp8266)
CORE_VERSION := 2.0.11
CORE_DIR := $(ARDUINO_ROOT)/hardware/esp32/$(CORE_VERSION)
ESP8266_CORE_VERSION ?= 3.1.2
ESP8266_CORE_DIR := $(ESP8266_ROOT)/hardware/esp8266/$(ESP8266_CORE_VERSION)
ESPTOOL := $(ARDUINO_ROOT)/tools/esptool_py/4.5.1/esptool.py
ESP8266_ESPTOOL := $(ESPTOOL)
ESP8266_MKLITTLEFS := $(ESP8266_ROOT)/tools/mklittlefs/3.1.0-gcc10.3-e5f9fec/mklittlefs
PARTITION_TOOL := $(CORE_DIR)/tools/gen_esp32part.py
#LITTLEFS_TOOL := $(shell find "$(ARDUINO_ROOT)/tools" -name mklittlefs -type f 2>/dev/null | head -n1)
LITTLEFS_TOOL := $(PROJECT_DIR)/mklittlefs/mklittlefs

PICO_FQBN := esp32:esp32:esp32:CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose,PSRAM=disabled
S2_FQBN := esp32:esp32:esp32s2:CDCOnBoot=cdc,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose,PSRAM=disabled
S3_FQBN := esp32:esp32:esp32s3:USBMode=hwcdc,CDCOnBoot=cdc,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=240,FlashMode=dio,FlashSize=4M,DebugLevel=verbose,PSRAM=disabled
PICO_8M_FQBN := esp32:esp32:esp32:CPUFreq=240,FlashFreq=40,FlashMode=dio,FlashSize=8M,DebugLevel=verbose,PSRAM=disabled
C3_FQBN := esp32:esp32:esp32c3:CDCOnBoot=cdc,CPUFreq=160,FlashFreq=40,FlashMode=dio,FlashSize=4M,DebugLevel=verbose
ESP8266_FQBN := esp8266:esp8266:generic:eesz=4M3M,FlashMode=dout,FlashFreq=40,xtal=80,CrystalFreq=26,baud=921600,ssl=all,mmu=3232,non32xfer=fast,vt=flash,exception=disabled,stacksmash=disabled,ip=lm2f,sdk=nonosdk_190703,lvl=None____,dbg=Disabled,wipe=none,led=2

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
S3_APP := $(S3_BUILD_DIR)/$(PROJECT_NAME).ino.bin
S3_BOOTLOADER := $(S3_BUILD_DIR)/$(PROJECT_NAME).ino.bootloader.bin
S3_PARTITIONS := $(S3_BUILD_DIR)/$(PROJECT_NAME).ino.partitions.bin
S3_MERGED := $(S3_BUILD_DIR)/$(PROJECT_NAME).s3.merged.bin
PICO_8M_LITTLEFS_IMAGE := $(PICO_8M_BUILD_DIR)/$(PROJECT_NAME).littlefs.bin
PICO_8M_APP := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.bin
PICO_8M_BOOTLOADER := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.bootloader.bin
PICO_8M_PARTITIONS := $(PICO_8M_OUTPUT_DIR)/$(PROJECT_NAME).ino.partitions.bin
PICO_8M_MERGED := $(PICO_8M_BUILD_DIR)/$(PROJECT_NAME).pico-8m.merged.bin
C3_APP := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.bin
C3_BOOTLOADER := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.bootloader.bin
C3_PARTITIONS := $(C3_BUILD_DIR)/$(PROJECT_NAME).ino.partitions.bin
C3_MERGED := $(C3_BUILD_DIR)/$(PROJECT_NAME).c3.merged.bin
ESP8266_APP := $(ESP8266_BUILD_DIR)/output/esp8266-arduino.ino.bin
ESP8266_LITTLEFS_IMAGE := $(ESP8266_BUILD_DIR)/esp8266-arduino.littlefs.bin
ESP8266_MERGED := $(ESP8266_BUILD_DIR)/esp8266-arduino.esp12f.merged.bin
ESP8266_FLASH_SIZE := 4194304
ESP8266_LITTLEFS_SIZE := 0x2FA000
ESP8266_LITTLEFS_OFFSET := 0x100000

.PHONY: all pico pico-8m s2 s3 c3 8266 littlefs datadir minimize check check-minimize check-data check-littlefs check-8266 clean FORCE

all: check $(PICO_MERGED) $(S2_MERGED) $(S3_MERGED) $(C3_MERGED)
	@echo
	echo "Build complete:"
	ls -lh "$(PICO_MERGED)" "$(S2_MERGED)" $(S3_MERGED) $(C3_MERGED) "$(LITTLEFS_IMAGE)"

pico: check $(PICO_MERGED)
	@ls -lh "$(PICO_MERGED)"

pico-8m: check $(PICO_8M_MERGED)
	@ls -lh "$(PICO_8M_MERGED)" "$(PICO_8M_LITTLEFS_IMAGE)"

s2: check $(S2_MERGED)
	@ls -lh "$(S2_MERGED)"

s3: check $(S3_MERGED)
	@ls -lh "$(S3_MERGED)"

c3: check $(C3_MERGED)
	@ls -lh "$(C3_MERGED)"

8266: check-8266 $(ESP8266_MERGED)
	@ls -lh "$(ESP8266_MERGED)" "$(ESP8266_LITTLEFS_IMAGE)"

littlefs: check-littlefs $(LITTLEFS_IMAGE)
	@ls -lh "$(LITTLEFS_IMAGE)"

minimize: check-minimize FORCE
	@"$(DATA_PREPARER)" minimize "$(SOURCE_DATA_DIR)" "$(MINIFIED_DATA_DIR)"
	du -sh "$(MINIFIED_DATA_DIR)"

datadir: check-data minimize FORCE
	@"$(DATA_PREPARER)" datadir "$(MINIFIED_DATA_DIR)" "$(DATA_DIR)"
	du -sh "$(DATA_DIR)"

check-minimize:
	@missing=0
	for tool in terser cleancss html-minifier-terser jq svgo; do
		if ! command -v "$$tool" >/dev/null 2>&1; then
			echo "Error: $$tool is required (run ./install-deps.sh)" >&2
			missing=1
		fi
	done
	test "$$missing" -eq 0
	test -x "$(DATA_PREPARER)" || { echo "Error: $(DATA_PREPARER) is not executable" >&2; exit 1; }
	test -d "$(SOURCE_DATA_DIR)" || { echo "Error: $(SOURCE_DATA_DIR) was not found" >&2; exit 1; }

check-data:
	@command -v gzip >/dev/null 2>&1 || { echo "Error: gzip is required (run ./install-deps.sh)" >&2; exit 1; }
	test -x "$(DATA_PREPARER)" || { echo "Error: $(DATA_PREPARER) is not executable" >&2; exit 1; }

check-littlefs: check-data
	@test -x "$(LITTLEFS_TOOL)" || { echo "Error: mklittlefs was not found" >&2; exit 1; }

check: check-littlefs
	@command -v arduino-cli >/dev/null
	command -v openssl >/dev/null
	command -v python3 >/dev/null
	test -d "$(CORE_DIR)" || { echo "Error: esp32:esp32@$(CORE_VERSION) is not installed" >&2; exit 1; }
	test -f "$(ESPTOOL)" || { echo "Error: $(ESPTOOL) was not found" >&2; exit 1; }
	test -f "$(PARTITION_TOOL)" || { echo "Error: $(PARTITION_TOOL) was not found" >&2; exit 1; }
	test -f "$(PROJECT_DIR)/$(PROJECT_NAME).ino"

check-8266: check-data
	@command -v arduino-cli >/dev/null
	command -v python3 >/dev/null
	test -d "$(ESP8266_CORE_DIR)" || { echo "Error: esp8266:esp8266@$(ESP8266_CORE_VERSION) is not installed" >&2; exit 1; }
	test -f "$(ESP8266_ESPTOOL)" || { echo "Error: ESP8266 esptool was not found" >&2; exit 1; }
	test -x "$(ESP8266_MKLITTLEFS)" || { echo "Error: ESP8266 mklittlefs was not found" >&2; exit 1; }
	test -f "$(PROJECT_DIR)/esp8266-arduino.ino"
	test -f "$(PROJECT_DIR)/server_certs.h"

$(SERVER_CERT) $(SERVER_KEY) &:
	@echo "Generating a self-signed HTTPS certificate..."
	openssl req -new -x509 \
		-newkey rsa:2048 \
		-sha256 \
		-days 3650 \
		-nodes \
		-keyout "$(SERVER_KEY)" \
		-out "$(SERVER_CERT)" \
		-subj "/CN=manuals.playstation.net" \
		-addext "subjectAltName=DNS:manuals.playstation.net,IP:192.168.4.1"
	chmod 600 "$(SERVER_KEY)"

#$(SERVER_CERT) $(SERVER_KEY) &:
#	@echo "Generating a self-signed HTTPS certificate..."
#	openssl req -x509 -newkey rsa:2048 -nodes \
#		-keyout "$(SERVER_KEY)" \
#		-out "$(SERVER_CERT)" \
#  	-days 3650 \
#  	-subj "/CN=manuals.playstation.net" \
#  	-addext "subjectAltName=DNS:manuals.playstation.net,IP:192.168.4.1"
#	chmod 600 "$(SERVER_KEY)"

$(SERVER_HEADER): $(SERVER_CERT) $(SERVER_KEY) $(CERT_EMBEDDER)
	@python3 "$(CERT_EMBEDDER)" "$(SERVER_CERT)" "$(SERVER_KEY)" "$(SERVER_HEADER)"

$(PICO_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@rm -rf "$(PICO_SKETCH_DIR)"
	mkdir -p "$(PICO_SKETCH_DIR)"
	cp "$(PROJECT_DIR)/$(PROJECT_NAME).ino" "$(SERVER_HEADER)" "$(PICO_SKETCH_DIR)/"
	cp "$(PROJECT_DIR)/partitions.csv" "$(PICO_SKETCH_DIR)/"
	arduino-cli compile \
	    --fqbn "$(PICO_FQBN)" \
	    --output-dir "$(PICO_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(PICO_SKETCH_DIR)"
	size=$$(stat -c %s "$(PICO_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: Pico application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(S2_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@rm -rf "$(S2_SKETCH_DIR)"
	mkdir -p "$(S2_SKETCH_DIR)"
	cp "$(PROJECT_DIR)/$(PROJECT_NAME).ino" "$(SERVER_HEADER)" "$(S2_SKETCH_DIR)/"
	cp "$(PROJECT_DIR)/partitions.csv" "$(S2_SKETCH_DIR)/"
	arduino-cli compile \
	    --fqbn "$(S2_FQBN)" \
	    --output-dir "$(S2_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(S2_SKETCH_DIR)"
	size=$$(stat -c %s "$(S2_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: S2 application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(S3_APP): $(PROJECT_DIR)/$(PROJECT_NAME).ino $(SERVER_HEADER) $(PROJECT_DIR)/partitions.csv Makefile
	@rm -rf "$(S3_SKETCH_DIR)"
	mkdir -p "$(S3_SKETCH_DIR)"
	cp "$(PROJECT_DIR)/$(PROJECT_NAME).ino" "$(SERVER_HEADER)" "$(S3_SKETCH_DIR)/"
	cp "$(PROJECT_DIR)/partitions.csv" "$(S3_SKETCH_DIR)/"
	arduino-cli compile \
	    --fqbn "$(S3_FQBN)" \
	    --output-dir "$(S3_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(S3_SKETCH_DIR)"
	size=$$(stat -c %s "$(S3_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: S3 application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

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
	@rm -rf "$(C3_SKETCH_DIR)"
	mkdir -p "$(C3_SKETCH_DIR)"
	cp "$(PROJECT_DIR)/$(PROJECT_NAME).ino" "$(SERVER_HEADER)" "$(C3_SKETCH_DIR)/"
	cp "$(PROJECT_DIR)/partitions.csv" "$(C3_SKETCH_DIR)/"
	arduino-cli compile \
	    --fqbn "$(C3_FQBN)" \
	    --output-dir "$(C3_BUILD_DIR)" \
	    --build-property "build.partitions=partitions" \
	    --build-property "build.filesystem=littlefs" \
	    "$(C3_SKETCH_DIR)"
	size=$$(stat -c %s "$(C3_APP)")
	test "$$size" -le "$(APP_PARTITION_SIZE)" || { echo "Error: C3 application exceeds the 1 MB partition: $$size bytes" >&2; exit 1; }

$(ESP8266_APP): $(PROJECT_DIR)/esp8266-arduino.ino $(SERVER_HEADER) Makefile
	@rm -rf "$(ESP8266_SKETCH_DIR)" "$(ESP8266_BUILD_DIR)/output"
	mkdir -p "$(ESP8266_SKETCH_DIR)" "$(ESP8266_BUILD_DIR)/output"
	cp "$(PROJECT_DIR)/esp8266-arduino.ino" "$(PROJECT_DIR)/server_certs.h" "$(ESP8266_SKETCH_DIR)/"
	arduino-cli compile --fqbn "$(ESP8266_FQBN)" --output-dir "$(ESP8266_BUILD_DIR)/output" "$(ESP8266_SKETCH_DIR)"
	size=$$(stat -c %s "$(ESP8266_APP)")
	test "$$size" -le 1044464 || { echo "Error: ESP8266 application exceeds the 4M3M sketch area: $$size bytes" >&2; exit 1; }

$(ESP8266_LITTLEFS_IMAGE): datadir
	@mkdir -p "$(ESP8266_BUILD_DIR)"
	"$(ESP8266_MKLITTLEFS)" -c "$(DATA_DIR)" -p 256 -b 8192 -s "$(ESP8266_LITTLEFS_SIZE)" "$(ESP8266_LITTLEFS_IMAGE)"

$(ESP8266_MERGED): $(ESP8266_APP) $(ESP8266_LITTLEFS_IMAGE)
	@python3 "$(ESP8266_ESPTOOL)" --chip esp8266 merge_bin -o "$(ESP8266_MERGED)" --flash_mode dout --flash_freq 40m --flash_size 4MB 0x0000 "$(ESP8266_APP)" "$(ESP8266_LITTLEFS_OFFSET)" "$(ESP8266_LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(ESP8266_MERGED)")
	test "$$size" -le "$(ESP8266_FLASH_SIZE)" || { echo "Error: ESP8266 image exceeds 4 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(ESP8266_FLASH_SIZE)" ]; then
		padding=$$(($(ESP8266_FLASH_SIZE) - size))
		head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(ESP8266_MERGED)"
	fi
	test "$$(stat -c %s "$(ESP8266_MERGED)")" -eq "$(ESP8266_FLASH_SIZE)"

$(LITTLEFS_IMAGE): datadir
	@echo
	echo "Creating shared LittleFS image..."
	mkdir -p "$(COMMON_BUILD_DIR)"
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

$(S3_MERGED): $(S3_APP) $(LITTLEFS_IMAGE)
	@python3 "$(ESPTOOL)" \
	    --chip esp32s3 \
	    merge_bin \
	    -o "$(S3_MERGED)" \
	    --flash_mode dio \
	    --flash_freq 80m \
	    --flash_size 4MB \
	    0x0 "$(S3_BOOTLOADER)" \
	    0x8000 "$(S3_PARTITIONS)" \
	    0x10000 "$(S3_APP)" \
	    "$(LITTLEFS_OFFSET)" "$(LITTLEFS_IMAGE)"
	size=$$(stat -c %s "$(S3_MERGED)")
	test "$$size" -le "$(FLASH_SIZE)" || { echo "Error: S3 image exceeds 4 MB: $$size bytes" >&2; exit 1; }
	if [ "$$size" -lt "$(FLASH_SIZE)" ]; then
	    padding=$$(($(FLASH_SIZE) - size))
	    head -c "$$padding" /dev/zero | tr '\000' '\377' >> "$(S3_MERGED)"
	fi
	test "$$(stat -c %s "$(S3_MERGED)")" -eq "$(FLASH_SIZE)"

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

$(PICO_8M_LITTLEFS_IMAGE): datadir
	@echo
	echo "Creating Pico 8 MB LittleFS image..."
	mkdir -p "$(PICO_8M_BUILD_DIR)"
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
	@rm -rf "$(BUILD_DIR)" "$(DATA_DIR)" "$(MINIFIED_DATA_DIR)"

FORCE:
