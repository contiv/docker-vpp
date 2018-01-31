#!/usr/bin/env make

IMAGE_PATH ?= contiv/vpp-base

build:
	DOCKER_REPO=$(IMAGE_PATH) hooks/build

.PHONY: build
