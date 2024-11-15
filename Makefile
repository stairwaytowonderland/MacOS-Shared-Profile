# MAKEFLAGS += --no-print-directory

####################
# Global Variables
####################

UNAME = $(shell uname -s)
SCRIPT_DIR = $(shell sed "s@$$HOME@~@" <<<$$(pwd))

####################
# Standard
####################

.PHONY: all
all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"
	@LC_ALL=C $(MAKE) .list-targets | sed -E 's/^all ?//' | sort -u | xargs -n4 printf "%-25s%-25s%-25s%s\n"

.PHONY: help
help:
	@LC_ALL=C $(MAKE) .list-targets | xargs -n4 printf "%-25s%-25s%-25s%s\n"

.PHONY: list
list:
	@LC_ALL=C $(MAKE) .list-targets | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs -n4 printf "%-25s%-25s%-25s%s\n"

####################
# Helpers
####################

.PHONY: .list-targets
.list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort

.PHONY: .install-full
.install-full:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh'

.PHONY: .install-basic-bash
.install-basic-bash:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --bash-basic'

.PHONY: .install-cron
.install-cron:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --cron'

.PHONY: .update-bash
.update-bash: skel-commit
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update bash'

.PHONY: .update-env
.update-env: skel-commit
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update env'

.PHONY: .update-git
.update-git: skel-commit
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update git'

.PHONY: .update-cron
.update-cron:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update cron'

.PHONY: .update
.update: skel-commit
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --update all'

.PHONY: .skel-commit
.skel-commit: SKEL_FILES := $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name ".*" -exec echo {} \;)
.skel-commit:
	@bash -cx 'BASE_DIR=$(SCRIPT_DIR) DEBUG=$(DEBUG) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --git commit $(SKEL_FILES)'

.PHONY: .skel-status
.skel-status: SKEL_FILES := $(shell find "$$(realpath $(SCRIPT_DIR))/etc/skel" -name ".*" -exec echo {} \;)
.skel-status:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --git status'

.PHONY: .build
.build:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh --build'

.PHONY: .deploy
.deploy: update-skel
####################
# Common
####################

.PHONY: install
install: .install-full

.PHONY: test
test: DEBUG = true
test: install

.PHONY: update
update: .update

.PHONY: build
build: .build combined-profile

.PHONY: test-build
test-build: DEBUG = true
test-build: build

.PHONY: deploy
deploy: .deploy

.PHONY: test-deploy
test-deploy: DEBUG = true
test-deploy: deploy

####################
# Misc
####################

.PHONY: combined-profile
combined-profile:
	@bash -cx 'DEBUG=$(DEBUG) BASE_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/setup/profile/generate.sh'

.PHONY: bbedit-default-editor
bbedit-default-editor:
	@bash -cx '$(SCRIPT_DIR)/setup/bbedit/bbedit-default-editor'

.PHONY: brew-dump
brew-dump: BREWFILE = "$(SCRIPT_DIR)/setup/brew/Brewfile"
brew-dump:
	@bash -cx '[ ! -r $(BREWFILE) ] || cp "$(BREWFILE)" "$(BREWFILE).$(shell date +\%u.\%H).bak" && brew bundle dump --file="$(BREWFILE)" --force'

### Install

.PHONY: install-bash-basic
install-bash-basic: .install-basic-bash

.PHONY: install-cron
install-cron: .install-cron

### Update

.PHONY: update-bash
update-bash: .update-bash

.PHONY: update-env
update-env: .update-env

.PHONY: update-git
update-git: .update-git

.PHONY: update-cron
update-cron: .update-cron

.PHONY: update-skel
update-skel: update-bash update-env update-git

### Maintain

.PHONY: skel-commit
skel-commit: .skel-commit

.PHONY: test-skel-commit
test-skel-commit: DEBUG = true
test-skel-commit: skel-commit

.PHONY: skel-status
skel-status: .skel-status
