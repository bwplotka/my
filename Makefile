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

.PHONY: web-deploy-prod
web-deploy-prod:
	$(MAKE) web-deploy-branch DEPLOY_BRANCH=docs-prod

.PHONY: web-deploy
web-deploy:
	$(MAKE) web-deploy-branch DEPLOY_BRANCH=docs-preview

web-deploy-branch:
	$(call require_clean_work_tree,"deploy website")
	@rm -rf $(PUBLIC_DIR)
	@mkdir $(PUBLIC_DIR)
	@git worktree prune
	@rm -rf .git/worktrees/$(PUBLIC_DIR)/
	@git fetch origin
	@git worktree add -B $(DEPLOY_BRANCH) $(PUBLIC_DIR) origin/$(DEPLOY_BRANCH)
	@rm -rf $(PUBLIC_DIR)/*
	@make web
	@cp $(WEB_DIR)/netlify.toml $(PUBLIC_DIR)/netlify.toml
	@cd $(PUBLIC_DIR) && git add --all && git commit -m "Publishing to $(DEPLOY_BRANCH) as $(ME)" && cd ..
	@git push origin $(DEPLOY_BRANCH)

# non-phony targets

$(HUGO):
	@echo "Install hugo, preferably in v0.54.0 version: https://gohugo.io/getting-started/installing/"

