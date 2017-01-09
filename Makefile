NAME := hexstr
VERBOSE := $(if $(VERBOSE),-v)
VERSION := $(shell git describe --tags --abbrev=0)
REVISION := $(shell git rev-parse --short HEAD)
BUILD_FLAGS := -ldflags "-X 'main.version=$(VERSION)' -X 'main.revision=$(REVISION)'"

# Build binaries
build: setup deps
	go build $(VERBOSE) $(BUILD_FLAGS)

## Setup
setup:
	go get github.com/golang/lint/golint
	go get github.com/Songmu/make2help/cmd/make2help
	go get github.com/mitchellh/gox
	go get github.com/tcnksm/ghr

# Cross-build
cross-build: deps setup
	rm -rf ./out
	gox $(BUILD_FLAGS) -output "./out/${NAME}_${VERSION}_{{.OS}}_{{.Arch}}"

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

package: cross-build
	rm -rf pkg \
		&& mkdir pkg \
		&& pushd out \
		&& cp -p * ../pkg/ \
		&& popd

## Release
release: setup package
	ghr $(VERSION) pkg/

## Show help
help:
	@make2help $(MAKEFILE_LIST)

## Clean executables
clean:
	@rm -rf hexstr* out

.PHONY: build setup link deps install help
