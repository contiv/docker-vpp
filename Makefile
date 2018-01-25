include build.env

IMAGE_PATH ?= contiv/vpp-base
IMAGE_TAG := $(shell echo $(VPP_COMMIT) | head -c 8)

build:
	echo $(IMAGE_TAG)
	docker build -t "$(IMAGE_PATH):$(IMAGE_TAG)" .
	docker tag "$(IMAGE_PATH):$(IMAGE_TAG)" "$(IMAGE_PATH):latest"

.PHONY: build
