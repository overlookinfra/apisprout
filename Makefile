#
# Commands
#

export DOCKER ?= docker
export GIT ?= git
export GO ?= go
export GOVVV ?= $(GO) run github.com/ahmetb/govvv
export MKDIR_P ?= mkdir -p
export RM ?= rm -f
export SHA256SUM ?= shasum -a 256
export TAR ?= tar
export ZIP_M ?= zip -m

#
# Variables
#

GOFLAGS ?=

CLI_DIST_TARGETS ?= $(addprefix dist-bin-,linux-amd64 linux-386 linux-arm64 linux-ppc64le linux-s390x windows-amd64 darwin-amd64)

#
#
#

export CLI_DIST_NAME := apisprout
export CLI_DIST_BRANCH ?= $(shell $(GIT) symbolic-ref --short HEAD)
export CLI_DIST_VERSION ?= $(shell $(GIT) describe --tags --always --dirty)

DOCKER_TAG_master := latest

DOCKER_DIST_NAME := gcr.io/nebula-contrib/$(CLI_DIST_NAME)
DOCKER_DIST_TAG := $(DOCKER_TAG_$(CLI_DIST_BRANCH))

export ARTIFACTS_DIR := artifacts
export BIN_DIR := bin

#
# Targets
#

.PHONY: all
all: build

$(ARTIFACTS_DIR) $(BIN_DIR):
	$(MKDIR_P) $@

.PHONY: generate
generate:
	$(GO) generate ./...

.PHONY: build
build: generate $(BIN_DIR)
	$(GOVVV) build $(GOFLAGS) -o $(BIN_DIR)/$(CLI_DIST_NAME) .

.PHONY: test
test: generate
	$(GO) test $(GOFLAGS) ./...

.PHONY: dist
dist: dist-bin dist-container

.PHONY: dist-bin
dist-bin: $(CLI_DIST_TARGETS)

.PHONY: dist-container
dist-container: dist-container-version

.PHONY: dist-container-version
dist-container-version:
	$(DOCKER) build -t "$(DOCKER_DIST_NAME):$(CLI_DIST_VERSION)" .

ifneq ($(DOCKER_DIST_TAG),)
dist-container: dist-container-named

.PHONY: dist-container-named
dist-container-named: dist-container-version
	$(DOCKER) tag "$(DOCKER_DIST_NAME):$(CLI_DIST_VERSION)" "$(DOCKER_DIST_NAME):$(DOCKER_DIST_TAG)"
endif

.PHONY: release
release: release-container

.PHONY: release-container
release-container: release-container-version

.PHONY: release-container-version
release-container-version: dist-container-version
	$(DOCKER) push "$(DOCKER_DIST_NAME):$(CLI_DIST_VERSION)"

ifneq ($(DOCKER_DIST_TAG),)
release-container: release-container-named

.PHONY: release-container-named
release-container-named: dist-container-named
	$(DOCKER) push "$(DOCKER_DIST_NAME):$(DOCKER_DIST_TAG)"
endif

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACTS_DIR)/
	$(RM) -r $(BIN_DIR)/

.PHONY: $(CLI_DIST_TARGETS)
$(CLI_DIST_TARGETS): export CGO_ENABLED = 0
$(CLI_DIST_TARGETS): export GOFLAGS += -a
$(CLI_DIST_TARGETS): export GOOS = $(word 1,$(subst -, ,$*))
$(CLI_DIST_TARGETS): export GOARCH = $(subst $(CLI_EXT_$(GOOS)),,$(word 2,$(subst -, ,$*)))
$(CLI_DIST_TARGETS): export LDFLAGS += -extldflags "-static"
$(CLI_DIST_TARGETS): export LDFLAGS += $(shell $(GOVVV) -flags)
$(CLI_DIST_TARGETS): dist-bin-%: $(ARTIFACTS_DIR)
	@scripts/dist
