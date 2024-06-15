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
PROJECTS += nix_dev
PROJECTS += nix_test
PROJECTS += nix_config
PROJECTS += nix_csp
PROJECTS += nix_ticker


# functions

each = $(foreach proj,$(1),$(subst %proj%,$(proj),$(2)))

each_mix_project = $(call each,$(PROJECTS),$(1))
each_project = $(call each,pnpm $(PROJECTS),$(1))

mix_projects_subtask = $(call each_mix_project,$(1).%proj%)
projects_subtask = $(call each_project,$(1).%proj%)


# targets

# .PHONY: def
# def: ; @echo $(call projects_subtask,build)

.PHONY: all
all: help


.PHONY: build
## build: compile projects
build: $(call projects_subtask,build)


.PHONY: install
install: $(call projects_subtask,install)


.PHONY: lint
## lint: run linters
lint: $(call projects_subtask,lint)

.PHONY: fmt
## fmt: run formatters
fmt: $(call projects_subtask,fmt)


.PHONY: test
## test: run tests
test: $(call projects_subtask,test)


.PHONY: docs
## docs: generate docs
docs: $(call mix_projects_subtask,docs)


.PHONY: deps
## deps: fetch dependencies
deps: $(call projects_subtask,deps)

.PHONY: deps.up
## deps.up: update dependencies
deps.up: $(call projects_subtask,deps.up)


.PHONY: clean
## clean: clean build targets
clean: $(call projects_subtask,clean)

.PHONY: deps.clean
## deps.clean: clean dependencies
deps.clean:
	@rm -rf ./node_modules $(call each_mix_project,"./%proj%/_build" "./%proj%/deps")

.PHONY: docs.clean
## docs.clean: clean generated documentation
docs.clean:
	@rm -rf $(call each_mix_project,"./%proj%/docs")

.PHONY: cache.clean
## cache.clean: clean cache
cache.clean:
	@rm -rf "$(CACHE_DIR)" $(call each_mix_project,"./%proj%/$(CACHE)")

.PHONY: lsp.clean
## lsp.clean: clean lsp data
lsp.clean:
	@rm -rf "./.elixir_ls" "./.elixir-tools" $(call each_mix_project,"./%proj%/.elixir_ls" "./%proj%/.elixir-tools")



.PHONY: help
help:
	@printf "Usage:\n"
	sed -n "s/^## \+\(.*\): *\(.*\)/$$(tput setaf 3)\1$$(tput sgr0):\2/p" $(MAKEFILE_LIST) \
		| column -t -s ":" \
		| sed -e "s/^/  /"


.PHONY: build.pnpm
build.pnpm:
	@pnpm run dist

.PHONY: build.%
build.%:
	@pushd "$*"
	mix compile

.PHONY: install.nix_dev
install.nix_dev:
	@pushd "nix_dev"
	MIX_ENV=prod mix do archive.build + archive.install --force

.PHONY: install.%
install.%:
	@# noop

.PHONY: lint.pnpm
lint.pnpm:
	@pnpm run lint:check

.PHONY: lint.%
lint.%:
	@pushd "$*"
	mix lint.check

.PHONY: fmt.pnpm
fmt.pnpm:
	@pnpm run lint:fmt

.PHONY: fmt.%
fmt.%:
	@pushd "$*"
	mix lint.fmt

.PHONY: test.pnpm
test.pnpm:
	@pnpm test

.PHONY: test.%
test.%:
	@pushd "$*"
	mix test

.PHONY: docs.%
docs.%:
	@pushd "$*"
	mix docs

.PHONY: deps.up.pnpm
deps.up.pnpm:
	@pnpm update -L

.PHONY: deps.up.%
deps.up.%:
	@pushd "$*"
	mix deps.update --all

.PHONY: deps.pnpm
deps.pnpm:
	@pnpm install --frozen

.PHONY: deps.%
deps.%:
	@pushd "$*"
	mix deps.get

.PHONY: clean.pnpm
clean.pnpm:
	@pnpm run clean

.PHONY: clean.%
clean.%:
	@pushd "$*"
	mix clean
