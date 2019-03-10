TMP_GOPATH        ?= /tmp/my-go
BIN_DIR           ?= bin
WEB_DIR           ?= web

HUGO_VERSION      ?= b1a82c61aba067952fdae2f73b826fe7d0f3fc2f
HUGO              ?= $(BIN_DIR)/hugo-$(HUGO_VERSION)

# fetch_go_bin_version downloads (go gets) the binary from specific version and installs it in $(BIN_DIR)/<bin>-<version>
# arguments:
# $(1): Install path. (e.g github.com/golang/dep/cmd/dep)
# $(2): Tag or revision for checkout.
define fetch_go_bin_version
	@mkdir -p $(BIN_DIR)
	@echo ">> fetching $(1)@$(2) revision/version"
	@if [ ! -d '$(TMP_GOPATH)/src/$(1)' ]; then \
    GOPATH='$(TMP_GOPATH)' go get -d -u '$(1)'; \
  else \
    CDPATH='' cd -- '$(TMP_GOPATH)/src/$(1)' && git fetch; \
  fi
	@CDPATH='' cd -- '$(TMP_GOPATH)/src/$(1)' && git checkout -f -q '$(2)'
	@echo ">> installing $(1)@$(2)"
	@GOBIN='$(TMP_GOPATH)/bin' GOPATH='$(TMP_GOPATH)' go install --tags extended '$(1)'
	@mv -- '$(TMP_GOPATH)/bin/$(shell basename $(1))' '$(BIN_DIR)/$(shell basename $(1))-$(2)'
	@echo ">> produced $(BIN_DIR)/$(shell basename $(1))-$(2)"
endef

.PHONY: all
all: web

.PHONY: web
web: $(HUGO)
	@echo ">> building documentation website"
	@cd $(WEB_DIR) && $(HUGO) -v

.PHONY: web-serve
web-serve: $(HUGO)
	@echo ">> serving documentation website"
	@cd $(WEB_DIR) && $(HUGO) -v server

# non-phony targets

$(HUGO):
	$(call fetch_go_bin_version,github.com/gohugoio/hugo,$(HUGO_VERSION))