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
install: .install ## Install

.PHONY: test
test: DEBUG = true
test: install
