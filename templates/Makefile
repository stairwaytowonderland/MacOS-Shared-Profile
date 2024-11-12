# MAKEFLAGS += --no-print-directory

.PHONY: all install test clean

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"

.setup:
	@bash -cx '$(SCRIPT_DIR)/script.sh'

install: .setup
