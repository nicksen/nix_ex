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

PROJECTS :=
ifdef PROJ
PROJECTS += $(PROJ)
else
PROJECTS += nix_std
PROJECTS += nix_dev
PROJECTS += nix_test
PROJECTS += nix_config
PROJECTS += nix_crypto
PROJECTS += nix_csp
PROJECTS += nix_ticker
PROJECTS += nix_totp
endif


# functions

each = $(foreach proj,$(1),$(subst %proj%,$(proj),$(2)))
each_project = $(call each,$(PROJECTS),$(1))
projects_subtask = $(call each_project,$(1).%proj%)


# targets

.PHONY: all
all: help


.PHONY: build
## build: compile projects
build: $(call projects_subtask,build)


.PHONY: install
install: $(call projects_subtask,install)


.PHONY: lint
## lint: run linters
ifdef PROJ
lint: $(call projects_subtask,lint)
else
lint: lint.prettier $(call projects_subtask,lint)
endif

.PHONY: fmt
## fmt: run formatters
fmt: fmt.prettier $(call projects_subtask,fmt)


.PHONY: test
## test: run tests
ifdef PROJ
test: $(call projects_subtask,test)
else
test: test.node $(call projects_subtask,test)
endif


.PHONY: docs
## docs: generate docs
docs: $(call projects_subtask,docs)


.PHONY: deps
## deps: fetch dependencies
deps: deps.node $(call projects_subtask,deps)

.PHONY: deps.up
## deps.up: update dependencies
deps.up: deps.up.node $(call projects_subtask,deps.up)


.PHONY: clean
## clean: clean build targets
clean: $(call projects_subtask,clean)

.PHONY: deps.clean
## deps.clean: clean dependencies
deps.clean:
	@rm -rf ./node_modules $(call each_project,"./%proj%/_build" "./%proj%/deps")

.PHONY: docs.clean
## docs.clean: clean generated documentation
docs.clean:
	@rm -rf $(call each_project,"./%proj%/doc" "./%proj%/cover")

.PHONY: cache.clean
## cache.clean: clean cache
cache.clean:
	@rm -rf "$(CACHE_DIR)" $(call each_project,"./%proj%/$(CACHE)")

.PHONY: lsp.clean
## lsp.clean: clean lsp data
lsp.clean:
	@rm -rf "./.elixir_ls" "./.elixir-tools" "./.lexical" $(call each_project,"./%proj%/.elixir_ls" "./%proj%/.elixir-tools" "./%proj%/.lexical")


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

.PHONY: install.nix_dev
install.nix_dev:
	@pushd "nix_dev"
	MIX_ENV=prod mix do archive.build + archive.install --force

.PHONY: install.%
install.%:
	@# noop

.PHONY: lint.prettier
lint.prettier:
	@bunx prettier --ignore-unknown -c .

.PHONY: lint.%
lint.%:
	@pushd "$*"
	@mix lint.check

.PHONY: fmt.prettier
fmt.prettier:
	@bunx prettier --ignore-unknown -w .

.PHONY: fmt.%
fmt.%:
	@pushd "$*"
	@mix lint.fmt

.PHONY: test.node
test.node:
	@echo "uncomment when there are tests to run - # @bun test"

.PHONY: test.%
test.%: ARGS ?=
test.%:
	@pushd "$*"
	@mix test --warnings-as-errors $(ARGS)

.PHONY: docs.%
docs.%:
	@pushd "$*"
	@mix docs

.PHONY: deps.up.node
deps.up.node:
	@bun update --latest
	@bun install

.PHONY: deps.up.%
deps.up.%:
	@pushd "$*"
	@mix deps.update --all

.PHONY: deps.node
deps.node:
	@bun install

.PHONY: deps.%
deps.%:
	@pushd "$*"
	@mix deps.get

.PHONY: clean.%
clean.%:
	@pushd "$*"
	@mix clean
