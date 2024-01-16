include .bingo/Variables.mk

WEB_DIR           ?= web
WEBSITE_BASE_URL  ?= https://bwplotka.dev

# 0.55.3
ME				  ?= $(shell whoami)

.PHONY: all
all: web

.PHONY: web
web: $(HUGO)
	@echo ">> building documentation website"
	# TODO(bwplotka): Make it --gc
	@cd $(WEB_DIR) && HUGO_ENV=production $(HUGO) --minify -v --config config.yaml -b $(WEBSITE_BASE_URL)

web-serve: $(HUGO)
	@echo ">> serving documentation website"
	@cd $(WEB_DIR) && $(HUGO) --config config.yaml -v server
