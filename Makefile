# make settings
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

# project-wide variables

CWD ?= .
CACHE := .cache
CACHE_DIR ?= $(CWD)/$(CACHE)

PROJECTS := nix_config nix_csp nix_std nix_ticker


# targets

.PHONY: all
all: help


.PHONY: build
## build: compile projects
build: $(foreach proj,$(PROJECTS),build.$(proj))


.PHONY: lint
## lint: run linters
lint: $(foreach proj,$(PROJECTS),lint.$(proj))

.PHONY: fmt
## fmt: run formatters
fmt: $(foreach proj,$(PROJECTS),fmt.$(proj))


.PHONY: test
## test: run tests
test: $(foreach proj,$(PROJECTS),test.$(proj))


.PHONY: deps
## deps: fetch dependencies
deps: $(foreach proj,$(PROJECTS),deps.$(proj))


.PHONY: clean
## clean: cleanup build targets
clean: $(foreach proj,$(PROJECTS),clean.$(proj))

.PHONY: deps.clean
## deps.clean: cleanup dependencies
deps.clean:
	@rm -rf $(foreach proj,$(PROJECTS),"$(proj)/{_build,deps}")

.PHONY: cache.clean
## cache.clean: cleanup cache
cache.clean:
	@rm -rf "$(CACHE_DIR)" $(foreach proj,$(PROJECTS),"$(proj)/$(CACHE)")

.PHONY: lsp.clean
## lsp.clean: cleanup lsp data
lsp.clean:
	@rm -rf $(foreach proj,$(PROJECTS),"$(proj)/.elixir_ls")


.PHONY: help
help:
	@printf "Usage:\n"
	@sed -n "s/^## \+\(.*\): *\(.*\)/$$(tput setaf 3)\1$$(tput sgr0):\2/p" $(MAKEFILE_LIST) \
		| column -t -s ":" \
		| sed -e "s/^/  /"


.PHONY: build.%
build.%:
	@pushd "$*"
	@mix compile

.PHONY: lint.%
lint.%:
	@pushd "$*"
	@mix lint.check

.PHONY: fmt.%
fmt.%:
	@pushd "$*"
	@mix lint.fmt

.PHONY: test.%
test.%:
	@pushd "$*"
	@mix test

.PHONY: deps.%
deps.%:
	@pushd "$*"
	@mix deps.get

.PHONY: clean.%
clean.%:
	@pushd "$*"
	@mix clean
