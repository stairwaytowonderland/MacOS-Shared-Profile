# MAKEFLAGS += --no-print-directory

.PHONY: all install brew-dump basic full combined-profile bbedit-default-editor

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))
BREWFILE := "$(SCRIPT_DIR)/setup/brew/Brewfile"

all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"

.setup:
	@bash -cx 'UNAME=$(UNAME) $(SCRIPT_DIR)/setup/setup.sh'

.setup-basic:
	@bash -cx '$(SCRIPT_DIR)/setup/setup.sh true'

install: .setup

basic: .setup-basic

full: install

combined-profile:
	@bash -cx '$(SCRIPT_DIR)/setup/profile/generate.sh'

bbedit-default-editor:
	@bash -cx '$(SCRIPT_DIR)/setup/bbedit/bbedit-default-editor'

brew-dump:
	@bash -cx '[ ! -r $(BREWFILE) ] || cp "$(BREWFILE)" "$(BREWFILE).$(shell date +\%u.\%H).bak" && brew bundle dump --file="$(BREWFILE)" --force'
