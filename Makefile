REVISION := $(shell git rev-parse --short HEAD)
ifeq ($(REVISION),)
$(error Cannot determine the Git revision)
endif

.PHONY: build

build:
	REVISION="$(REVISION)" docker buildx bake $(BAKE_ARGS)
