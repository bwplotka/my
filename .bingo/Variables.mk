# Auto generated binary variables helper managed by https://github.com/bwplotka/bingo v0.2.5. DO NOT EDIT.
# All tools are designed to be build inside $GOBIN.
BINGO_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GOPATH ?= $(shell go env GOPATH)
GOBIN  ?= $(firstword $(subst :, ,${GOPATH}))/bin
GO     ?= $(shell which go)

# Bellow generated variables ensure that every time a tool under each variable is invoked, the correct version
# will be used; reinstalling only if needed.
# For example for mdox variable:
#
# In your main Makefile (for non array binaries):
#
#include .bingo/Variables.mk # Assuming -dir was set to .bingo .
#
#command: $(MDOX)
#	@echo "Running mdox"
#	@$(MDOX) <flags/args..>
#
MDOX := $(GOBIN)/mdox-v0.2.0
$(MDOX): $(BINGO_DIR)/mdox.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/mdox-v0.2.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=mdox.mod -o=$(GOBIN)/mdox-v0.2.0 "github.com/bwplotka/mdox"

