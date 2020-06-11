include .bingo/Variables.mk

WEB_DIR           ?= web
WEBSITE_BASE_URL  ?= https://bwplotka.dev

.PHONY: all
all: web-serve

.PHONY: web
web: $(HUGO)
	@echo ">> building documentation website"
	# TODO(bwplotka): Make it --gc
	@cd $(WEB_DIR) && HUGO_ENV=production $(HUGO) --minify -v --config config.yaml -b $(WEBSITE_BASE_URL)

.PHONY: web-serve
web-serve: $(HUGO)
	@echo ">> serving documentation website"
	@cd $(WEB_DIR) && $(HUGO) --config config.yaml -v server

.PHONY: pitch-desktop
gitpitch-desktop:
	@echo ">> starting gitpitch desktop"
	@docker run -it --rm -v $(shell pwd):/repo -p 9000:9000 gitpitch/desktop:pro

