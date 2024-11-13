# MAKEFLAGS += --no-print-directory

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

####################
# Standard Public
####################

.PHONY: all
all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"
	@LC_ALL=C $(MAKE) list | sed -E 's/^all ?//' | sort -u | xargs

.PHONY: help
help:
	@LC_ALL=C $(MAKE)

.PHONY: list
list:
	@LC_ALL=C $(MAKE) .list-targets | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

####################
# Hidden Helpers
####################

.list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort

.install:
	@bash -cx '$(SCRIPT_DIR)/script.sh'

####################
# Custom Public
####################

.PHONY: install
install: .install
