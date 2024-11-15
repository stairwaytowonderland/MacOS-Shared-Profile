# MAKEFLAGS += --no-print-directory

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))
BREWFILE := "$(SCRIPT_DIR)/setup/brew/Brewfile"
SKEL_FILES := $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name ".*" -exec echo {} \;)

####################
# Standard Public
####################

.PHONY: all
all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"
	@LC_ALL=C $(MAKE) .list-targets | sed -E 's/^all ?//' | sort -u | xargs

.PHONY: help
help:
	@LC_ALL=C $(MAKE) .list-targets

.PHONY: list
list:
	@LC_ALL=C $(MAKE) .list-targets | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

####################
# Hidden Helpers
####################

.PHONY: .list-targets
.list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort

.PHONY: .install-full
.install-full:
	@bash -cx 'UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh'

.PHONY: .install-basic-bash
.install-basic-bash:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --bash-basic'

.PHONY: .install-cron
.install-cron:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --cron'

.PHONY: .update-bash
.update-bash:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --update bash'

.PHONY: .update-env
.update-env:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --update env'

.PHONY: .update-git
.update-git:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --update git'

.PHONY: .update-cron
.update-cron:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --update cron'

.PHONY: .update
.update: .git
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --update all'

.PHONY: .git
.git:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh --git $(SKEL_FILES)'

####################
# Custom Public
####################

.PHONY: combined-profile
combined-profile:
	@bash -cx '$(SCRIPT_DIR)/setup/profile/generate.sh'

.PHONY: bbedit-default-editor
bbedit-default-editor:
	@bash -cx '$(SCRIPT_DIR)/setup/bbedit/bbedit-default-editor'

.PHONY: brew-dump
brew-dump:
	@bash -cx '[ ! -r $(BREWFILE) ] || cp "$(BREWFILE)" "$(BREWFILE).$(shell date +\%u.\%H).bak" && brew bundle dump --file="$(BREWFILE)" --force'

.PHONY: install
install: .install-full

.PHONY: install-bash-basic
install-bash-basic: .install-basic-bash

.PHONY: install-cron
install-cron: .install-cron

.PHONY: update-bash
update-bash: .update-bash

.PHONY: update-env
update-env: .update-env

.PHONY: update-git
update-git: .update-git

.PHONY: update-cron
update-cron: .update-cron

.PHONY: update
update: .update

.PHONY: git
git: .git
