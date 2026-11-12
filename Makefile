SHELL := /bin/bash

.PHONY: test lint format update-submodules

test:
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

lint:
	@set -eu; \
	VIMRUNTIME="$$(nvim --headless --clean -c 'lua io.write(vim.env.VIMRUNTIME)' -c 'qa')"; \
	export VIMRUNTIME; \
	for path in *.lua lua after ftplugin fzf_scripts scripts tests; do \
		[[ -e "$$path" ]] || continue; \
		lua-language-server --check="$$path" --checklevel=Warning --configpath="$(CURDIR)/.luarc.json"; \
	done

format:
	stylua *.lua after ftplugin fzf_scripts lua scripts tests

update-submodules:
	git submodule update --init --recursive --remote

deploy: update-submodules test lint format
