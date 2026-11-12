# Plan: add meaningful tests for config Lua sources

## Scope

Skip tests for pure configuration: files whose entire job is declaring state — options, keymaps, abbreviations, highlight groups, `vim.pack.add`, plugin `setup()` calls, and autocmd/keymap registrations that only delegate to a plugin. Assigning `vim.o.cursorline = true` and then asserting `vim.o.cursorline` tests Neovim, not this config. A file earns tests only when it branches, computes, formats, or transitions state; the declarative files already reviewed are listed under `## No tests: pure configuration`.

Place each eventual test in `tests/` and name it by replacing `/` in the source path with `_`, removing `.lua`, then appending `_test.lua` (for example, `lua/shared/options.lua` becomes `tests/lua_shared_options_test.lua`). Each test should exercise observable behavior rather than use a dummy equality assertion.

`mini.test` discovers `test_*.lua` by default, so update `scripts/minimal_init.lua` to discover both the existing `test_*.lua` file and the new `*_test.lua` files. This preserves the existing dummy suite while ensuring the per-file tests are collected. The current `make test` target will remain unchanged.

## No tests: pure configuration

Reviewed and intentionally left without tests:

- `init.lua`, `barebones.lua`, `feature_complete.lua` — bootstrap `require`/`require_dir` calls.
- `container.lua` — `vim.g.clipboard` plus two keymaps.
- `lua/first.lua` — `mapleader`/`maplocalleader` and `vim.loader.enable()`.
- `lua/feature_complete/init.lua` — `vim.pack.add`, `require_dir`, `packadd`.
- `lua/shared/options.lua`, `lua/shared/abbrev.lua` — option and abbreviation assignments.
- `lua/feature_complete/vim_plugins/colorscheme.lua` — highlight group definitions.
- `scripts/minimal_init.lua` — `runtimepath` and `mini.test` setup.

## TODO: create and fill in substantive tests

Files with real logic, kept in the backlog:

- [ ] `tests/ftplugin_lua_test.lua` — `ftplugin/lua.lua`
- [ ] `tests/lua_barebones_init_test.lua` — `lua/barebones/init.lua`
- [ ] `tests/lua_feature_complete_init_test.lua` — `lua/feature_complete/init.lua`
- [ ] `tests/lua_feature_complete_shell_plugins_version_control_test.lua` — `lua/feature_complete/shell_plugins/version_control.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_colorscheme_test.lua` — `lua/feature_complete/vim_plugins/colorscheme.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_far_test.lua` — `lua/feature_complete/vim_plugins/far.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_ff_test.lua` — `lua/feature_complete/vim_plugins/ff.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_file_tree_test.lua` — `lua/feature_complete/vim_plugins/file_tree.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_lsp_test.lua` — `lua/feature_complete/vim_plugins/lsp.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_mini_test.lua` — `lua/feature_complete/vim_plugins/mini.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_movements_test.lua` — `lua/feature_complete/vim_plugins/movements.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_quickfix_list_test.lua` — `lua/feature_complete/vim_plugins/quickfix_list.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_version_control_test.lua` — `lua/feature_complete/vim_plugins/version_control.lua`
- [ ] `tests/lua_first_test.lua` — `lua/first.lua`
- [x] `tests/lua_helpers_test.lua` — `lua/helpers.lua`
- [ ] `tests/lua_shared_auto_commands_test.lua` — `lua/shared/auto_commands.lua`
- [ ] `tests/lua_shared_keymaps_test.lua` — `lua/shared/keymaps.lua`
- [x] `tests/lua_shared_movements_test.lua` — `lua/shared/movements.lua`
- [x] `tests/lua_shared_notify_test.lua` — `lua/shared/notify.lua`
- [x] `tests/lua_shared_pairs_test.lua` — `lua/shared/pairs.lua`
- [x] `tests/lua_shared_quickfix_list_test.lua` — `lua/shared/quickfix_list.lua`
- [x] `tests/lua_shared_tabline_test.lua` — `lua/shared/tabline.lua`
- [x] `tests/lua_shared_user_commands_test.lua` — `lua/shared/user_commands.lua`

## Verification after approval

Run `make test`, `make lint`, and StyLua checks. When tests are added, confirm MiniTest discovers every `*_test.lua` file along with the existing `test_*.lua` suite.
