NAME := hexstr
VERBOSE := $(if $(VERBOSE),-v)
VERSION := $(shell git describe --tags --abbrev=0)
REVISION := $(shell git rev-parse --short HEAD)
BUILD_FLAGS := -ldflags "-X 'main.version=$(VERSION)' -X 'main.revision=$(REVISION)'"

## Setup
setup:
	go get github.com/golang/lint/golint
	go get github.com/Songmu/make2help/cmd/make2help
	go get github.com/mitchellh/gox
	go get github.com/tcnksm/ghr

# Build binaries
build: setup deps
	go build $(VERBOSE) $(BUILD_FLAGS)

# Cross-build
cross-build: deps setup
	rm -rf ./out
	gox $(BUILD_FLAGS) -output "./out/${NAME}${VERSION}_{{.OS}}_{{.Arch}}/{{.Dir}}"


## Lint
lint: setup deps
	go vet .
	golint -set_exit_status . || exit $$?

## download dependencies
deps:
	go get -d $(VERBOSE)

## install binaries
install:
	go install $(VERBOSE) $(BUILD_FLAGS)

## Release
release: setup

## Show help
help:
	@make2help $(MAKEFILE_LIST)

## Clean executables
clean:
	@rm -f hexstr*

.PHONY: build setup link deps install help
