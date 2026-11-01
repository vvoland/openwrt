OPENWRT_REF ?= v25.12.6
JOBS ?= 12
IMAGE ?= openwrt-builder
CACHE_PREFIX ?= openwrt
ROUTER_CONFIG ?= $(HOME)/src/routers
REVISION := $(shell git rev-parse --short HEAD)
ifeq ($(REVISION),)
$(error Cannot determine the Git revision)
endif

ifneq ($(wildcard patches),)
PATCHES_MOUNT := --mount "type=bind,src=$(CURDIR)/patches,dst=/custom/patches,readonly"
endif

.PHONY: build

build:
	docker build -t "$(IMAGE)" .
	mkdir -p bin
	docker run --rm \
		-e "OPENWRT_REF=$(OPENWRT_REF)" \
		-e "JOBS=$(JOBS)" \
		-e "REVISION=$(REVISION)" \
		-e "HOST_UID=$(shell id -u)" \
		-e "HOST_GID=$(shell id -g)" \
		--mount "type=volume,src=$(CACHE_PREFIX)-dl,dst=/build/dl" \
		--mount "type=volume,src=$(CACHE_PREFIX)-feeds,dst=/build/feeds" \
		--mount "type=bind,src=$(CURDIR)/build.sh,dst=/usr/local/bin/build-openwrt,readonly" \
		--mount "type=bind,src=$(CURDIR)/config.seed,dst=/custom/config.seed,readonly" \
		$(PATCHES_MOUNT) \
		--mount "type=bind,src=$(CURDIR)/files,dst=/overlay,readonly" \
		--mount "type=bind,src=$(ROUTER_CONFIG),dst=/router-config,readonly" \
		--mount "type=bind,src=$(CURDIR)/bin,dst=/out" \
		"$(IMAGE)" /bin/sh /usr/local/bin/build-openwrt
