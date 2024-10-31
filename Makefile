# MAKEFLAGS += --no-print-directory

.PHONY: all install test debug clean

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"

debug: $(TARGETS)
	@printf "\033[4mShowing Vars\033[0m\n%s\t= %s\n" "SCRIPT_DIR" "$(SCRIPT_DIR)"

install:
	@bash -c 'sh $(SCRIPT_DIR)/setup/setup.sh'

combined-profile:
	@bash -c 'sh $(SCRIPT_DIR)/setup/profile/generate.sh'

bbedit-default-editor:
	@bash -c 'sh $(SCRIPT_DIR)/setup/bbedit/bbedit-default-editor'
