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

PROJECTS := nix_std
PROJECTS += nix_config
PROJECTS += nix_csp
PROJECTS += nix_ticker


# functions

projects_subtask = $(foreach proj,$(PROJECTS),$(1).$(proj))


# targets

.PHONY: all
all: help


.PHONY: build
## build: compile projects
build: $(call projects_subtask,build)


.PHONY: lint
## lint: run linters
lint: pnpm.lint $(call projects_subtask,lint)

.PHONY: fmt
## fmt: run formatters
fmt: pnpm.fmt $(call projects_subtask,fmt)


.PHONY: test
## test: run tests
test: $(call projects_subtask,test)


.PHONY: deps
## deps: fetch dependencies
deps: pnpm.deps $(call projects_subtask,deps)

.PHONY: deps.up
## deps.up: update dependencies
deps.up: pnpm.deps.up $(call projects_subtask,deps.up)


.PHONY: clean
## clean: cleanup build targets
clean: $(call projects_subtask,clean)

.PHONY: deps.clean
## deps.clean: cleanup dependencies
deps.clean:
	@rm -rf ./node_modules $(foreach proj,$(PROJECTS),"./$(proj)/_build" "./$(proj)/deps")

.PHONY: cache.clean
## cache.clean: cleanup cache
cache.clean:
	@rm -rf "$(CACHE_DIR)" $(foreach proj,$(PROJECTS),"./$(proj)/$(CACHE)")

.PHONY: lsp.clean
## lsp.clean: cleanup lsp data
lsp.clean:
	@rm -rf $(foreach proj,$(PROJECTS),"./$(proj)/.elixir_ls")


.PHONY: pnpm.lint
pnpm.lint:
	@pnpm run lint:check

.PHONY: pnpm.fmt
pnpm.fmt:
	@pnpm run lint:fmt

.PHONY: pnpm.deps
pnpm.deps:
	@pnpm install --frozen

.PHONY: pnpm.deps.up
pnpm.deps.up:
	@pnpm update -L


.PHONY: help
help:
	@printf "Usage:\n"
	sed -n "s/^## \+\(.*\): *\(.*\)/$$(tput setaf 3)\1$$(tput sgr0):\2/p" $(MAKEFILE_LIST) \
		| column -t -s ":" \
		| sed -e "s/^/  /"


.PHONY: build.%
build.%:
	@pushd "$*"
	mix compile

.PHONY: lint.%
lint.%:
	@-pushd "$*"
	mix lint.check

.PHONY: fmt.%
fmt.%:
	@pushd "$*"
	mix lint.fmt

.PHONY: test.%
test.%:
	@-pushd "$*"
	mix test

.PHONY: deps.up.%
deps.up.%:
	@pushd "$*"
	mix deps.update --all

.PHONY: deps.%
deps.%:
	@pushd "$*"
	mix deps.get

.PHONY: clean.%
clean.%:
	@pushd "$*"
	mix clean
