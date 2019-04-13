WEB_DIR           ?= web
PUBLIC_DIR		  ?= public
HUGO              ?= $(shell which hugo)
ME				  ?= $(shell whoami)

.PHONY: all
all: web

define require_clean_work_tree
	@git update-index -q --ignore-submodules --refresh

    @if ! git diff-files --quiet --ignore-submodules --; then \
        echo >&2 "cannot $1: you have unstaged changes."; \
        git diff-files --name-status -r --ignore-submodules -- >&2; \
        echo >&2 "Please commit or stash them."; \
        exit 1; \
    fi

    @if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then \
        echo >&2 "cannot $1: your index contains uncommitted changes."; \
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2; \
        echo >&2 "Please commit or stash them."; \
        exit 1; \
    fi

endef

.PHONY: web
web: $(HUGO)
	@echo ">> building documentation website"
	# TODO(bwplotka): Make it --gc
	@sed -e "s/<<GOOGLE_ANALYTICS_TOKEN>>/${GOOGLE_ANALYTICS_TOKEN}/" $(WEB_DIR)/config.yaml > $(WEB_DIR)/config-generated.yaml
	@cd $(WEB_DIR) && HUGO_ENV=production $(HUGO) --minify -v --config config-generated.yaml

.PHONY: web-dbg
web-dbg: $(HUGO)
	@echo ">> building documentation website"
	@cd $(WEB_DIR) && $(HUGO) -v

.PHONY: web-serve
web-serve: $(HUGO)
	@echo ">> serving documentation website"
	@cd $(WEB_DIR) && $(HUGO) -v server

.PHONY: web-deploy
web-deploy:
	$(call require_clean_work_tree,"deploy website")
	@rm -rf $(PUBLIC_DIR)
	@mkdir $(PUBLIC_DIR)
	@git worktree prune
	@rm -rf .git/worktrees/$(PUBLIC_DIR)/
	@git fetch origin
	@git worktree add -B gh-pages $(PUBLIC_DIR) origin/gh-pages
	@rm -rf $(PUBLIC_DIR)/*
	@make web
	@cd $(PUBLIC_DIR) && git add --all && git commit -m "Publishing to gh-pages as $(ME)" && cd ..
	@git push origin gh-pages

# non-phony targets

$(HUGO):
	@echo "Install hugo, preferably in v0.54.0 version: https://gohugo.io/getting-started/installing/"

