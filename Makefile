# MAKEFLAGS += --no-print-directory

####################
# Global Variables
####################

SHELL := bash
UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

####################
# Standard
####################

.PHONY: help
help: ## Show this help.
	@printf "\033[1;4m%s\033[0m\n" "Usage"
	@printf "(%s)\n" "Use \`make help' to show this message"
	@printf "\033[1m%s\033[0m\n" "Please use \`make <target>' where <target> is one of:"
	@grep '^[a-zA-Z]' $(MAKEFILE_LIST) | \
    sort | \
    awk -F ':.*?## ' 'NF==2 {printf "\033[36m  %-26s\033[0m %s\n", $$1, $$2}'

.PHONY: list
list: PUBLIC_TARGETS ?= $(shell LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort)
list: LIST_TARGETS ?= $(shell LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$')
list: ## List public targets
	@echo $(PUBLIC_TARGETS) | xargs -n3 printf "%-26s%-26s%-26s%s\n"

.PHONY: clean
clean: DIST_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/dist" -type f -name ".*" -mindepth 1 -maxdepth 1 -exec echo {} \;)
clean: SKEL_BASE_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name '.*' -exec sh -c ' \
	for file do \
		basename $$file; \
	done' sh {} +)
clean: HOME_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name '.*' -exec sh -c ' \
	for file do \
		! test -r "$(HOME)/$$(basename $$file)" || echo "$(HOME)/$$(basename $$file)"; \
	done' sh {} +)
clean: TAR_FILE ?= "$$(realpath $(SCRIPT_DIR))/Backup/$(USER)-$$(date +%m%d%y%H%M%S).tar.gz"
clean: git-commit-home ## Clean 'dist/' and $HOME; Removes any files added by the installer
	@echo "$(SKEL_BASE_FILES)" | xargs tar -C "$(HOME)" -czvf "$(TAR_FILE)" -T -
	$(RM) $(HOME_FILES)

.PHONY: permissions
permissions: DIRS ?= $$(realpath $(SCRIPT_DIR)/Data) $$(realpath $(SCRIPT_DIR)/Tools)
permissions: ## Reset correct permissions on handled directories
	@for d in $(DIRS) ; do \
		if test -d "$$d" ; then \
			[ "$$(uname -s)" != "Darwin" ] || \
				( set -x; sudo chown -R :staff "$$d"; sudo chown root:staff "$$d" ); \
			( set -x; sudo chmod -R 0775 "$$d"; sudo chmod 1775 "$$d" ); \
		fi; \
	done

.PHONY: configure
configure: ## Run configuration script
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/configure.sh

.PHONY: test-configure
test-configure: DEBUG=true
test-configure: configure ## Test configuration script

####################
# Helpers
####################

.PHONY: .install-full
.install-full:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh

.PHONY: .install-bashrc
.install-bashrc:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --install bash

.PHONY: .install-skel
.install-skel: .install-bashrc
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --install env
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --install git

.PHONY: .update-bashrc
.update-bashrc:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update bash

.PHONY: .update-skel
.update-skel: .update-bashrc
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update env
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update git

.PHONY: .update-all
.update-all:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update all

.PHONY: .update-dist
.update-dist: DIST_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/dist" -type f -name ".*" -mindepth 1 -maxdepth 1 -exec echo {} \;)
.update-dist:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update dist $(DIST_FILES)

.PHONY: .home-commit
.home-commit: SKEL_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name ".*" -exec echo {} \;)
.home-commit:
	@set -x; BASE_DIR=$(SCRIPT_DIR) DEBUG=$(DEBUG) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --git commit $(SKEL_FILES)

.PHONY: .home-status
.home-status:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --git status

.PHONY: .commit-nag
.commit-nag:
	@printf "Some files may have been changed during update ...\nTo check the status of those changes, run \`\033[1m%s\033[0m\`.\nIf you approve of those changes, run \`\033[1m%s\033[0m\` to commit them.\n" "make -C $(SCRIPT_DIR) git-status-home" "make -C $(SCRIPT_DIR) git-commit-home"

.PHONY: .build
.build:
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --build

.PHONY: .deploy
.deploy: .update-dist

.PHONY: .clean-dist
.clean-dist: DIST_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/dist" -type f -name ".*" -mindepth 1 -maxdepth 1 -exec echo {} \;)
.clean-dist:
	$(RM) $(DIST_FILES)

.PHONY: .clean-home
.clean-home: SKEL_BASE_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name '.*' -exec sh -c ' \
	for file do \
		basename $$file; \
	done' sh {} +)
.clean-home: HOME_FILES ?= $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name '.*' -exec sh -c ' \
	for file do \
		! test -r "$(HOME)/$$(basename $$file)" || echo "$(HOME)/$$(basename $$file)"; \
	done' sh {} +)
.clean-home: TAR_FILE ?= "$$(realpath $(SCRIPT_DIR))/Backup/$(USER)-$$(date +%m%d%y%H%M%S).tar.gz"
.clean-home:
	@echo "$(SKEL_BASE_FILES)" | xargs tar -C "$(HOME)" -czvf "$(TAR_FILE)" -T -
	$(RM) $(HOME_FILES)

####################
# Common
####################

.PHONY: install
install: .install-full ## Full install

.PHONY: test
test: DEBUG = true
test: install

.PHONY: update
update: update-bashrc ## Basic update

.PHONY: test-update
test-update: DEBUG = true
test-update: .update

.PHONY: build
build: FILE_NAME ?= dist/home/.bashrc
build: .build combined-profile ## Build files 'dist/.*'

.PHONY: test-build
test-build: DEBUG = true
test-build: build

.PHONY: deploy
deploy: git-commit-home .deploy .commit-nag ## Copy files 'dist/.*' to $HOME; $HOME will get backed up with git

.PHONY: test-deploy
test-deploy: DEBUG = true
test-deploy: .deploy

####################
# Misc
####################

.PHONY: combined-profile
combined-profile: FILE_NAME ?= dist/.bashrc
combined-profile: ## Build combined profile in 'dist/home/.bashrc'
	@set -x; DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/profile/generate.sh "$(FILE_NAME)"

.PHONY: bbedit-default-editor
bbedit-default-editor: ## Run script to set bbedit as the default editor on macos
	@set -x; '$(SCRIPT_DIR)/setup/bbedit/bbedit-default-editor'

.PHONY: brew-dump
brew-dump: BREWFILE = "$(SCRIPT_DIR)/setup/brew/Brewfile"
brew-dump: ## Create brew dump file; Existing file will get backed up
	@set -x; [ ! -r $(BREWFILE) ] || cp "$(BREWFILE)" "$(BREWFILE).$(shell date +\%u.\%H).bak" && brew bundle dump --file="$(BREWFILE)" --force

### Install

.PHONY: install-bashrc
install-bashrc: .install-bashrc ## Install bash (profile) files only; Does not overwrite

.PHONY: test-install-bashrc
test-install-bashrc: DEBUG=true
test-install-bashrc: install-bashrc

.PHONY: install-skel
install-skel: .install-skel ## Install all skel files; Does not overwrite

.PHONY: test-install-skel
test-install-skel: DEBUG=true
test-install-skel: .install-skel

### Update

.PHONY: update-all
update-all: git-commit-home .update-all .commit-nag ## Full update

.PHONY: test-update-all
test-update-all: DEBUG = true
test-update-all: .update-all

.PHONY: update-bashrc
update-bashrc: git-commit-home .update-bashrc .commit-nag ## Install bash (profile) files only

.PHONY: test-update-bashrc
test-update-bashrc: DEBUG=true
test-update-bashrc: .update-bashrc

.PHONY: update-skel
update-skel: git-commit-home .update-skel .commit-nag ## Install all skel files

.PHONY: test-update-skel
test-update-skel: DEBUG=true
test-update-skel: .update-skel

### Maintain

.PHONY: git-commit-home
git-commit-home: .home-commit ## Git commit handled files in $HOME folder

.PHONY: test-commit
test-commit: DEBUG = true
test-commit: git-commit-home

.PHONY: git-status-home
git-status-home: .home-status ## Git status handled files in $HOME folder

.PHONY: rebuild
rebuild: build deploy ## Build and then deploy 'dist/home'

.PHONY: test-rebuild
test-rebuild: DEBUG = true
test-rebuild: rebuild
