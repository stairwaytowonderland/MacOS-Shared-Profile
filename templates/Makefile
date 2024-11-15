# MAKEFLAGS += --no-print-directory

####################
# Global Variables
####################

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

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

.PHONY: .install
.install:
	@bash -cx 'DEBUG=$(DEBUG) SCRIPT_DIR=$(SCRIPT_DIR) UNAME=$(UNAME) $(SCRIPT_DIR)/script.sh'

####################
# Common
####################

.PHONY: install
install: .install

.PHONY: test
test: DEBUG = true
test: install
