# make settings
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

# project-wide variables

CWD ?= .
CACHE_DIR ?= $(CWD)/.cache

MARKER_FILE = .maketarget


# targets

.PHONY: all
all: help


.PHONY: test
## test: run tests
test:


.PHONY: clean
## clean: cleanup build targets
clean:


.PHONY: help
help:
	@printf "Usage:\n"
	@sed -n "s/^## \+\(.*\): *\(.*\)/$$(tput setaf 3)\1$$(tput sgr0):\2/p" $(MAKEFILE_LIST) \
		| column -t -s ":" \
		| sed -e "s/^/  /"
