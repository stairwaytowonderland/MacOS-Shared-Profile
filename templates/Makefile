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
	@printf "\033[1m%s\033[0m\n\n" "Use \`make help' to display this message"
	@printf "\033[1m%s\033[0m\n" "Please use \`make <target>' where <target> is one of"
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
clean: commit-home ## Clean 'dist/' and $HOME; Removes any files added by the installer
	@echo "$(SKEL_BASE_FILES)" | xargs tar -C "$(HOME)" -czvf "$(TAR_FILE)" -T -
	$(RM) $(HOME_FILES)

####################
# Helpers
####################

.PHONY: .install
.install:
	@set -x; 'DEBUG=$(DEBUG) SCRIPT_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/script.sh'

####################
# Common
####################

.PHONY: install
install: .install

.PHONY: test
test: DEBUG = true
test: install
