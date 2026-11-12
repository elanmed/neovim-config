# Plan: add meaningful tests for config Lua sources

## Scope

Skip tests for pure configuration. A file earns tests only when it branches, computes, formats, or transitions state.

Place each eventual test in `tests/` and name it by replacing `/` in the source path with `_`, removing `.lua`, then appending `_test.lua` (for example, `lua/shared/options.lua` becomes `tests/lua_shared_options_test.lua`). Each test should exercise observable behavior rather than use a dummy equality assertion.

`mini.test` discovers `test_*.lua` by default, so update `scripts/minimal_init.lua` to discover both the existing `test_*.lua` file and the new `*_test.lua` files. This preserves the existing dummy suite while ensuring the per-file tests are collected. The current `make test` target will remain unchanged.

## TODO: create and fill in substantive tests

Files with real logic, kept in the backlog:

- [ ] `tests/ftplugin_lua_test.lua` — `ftplugin/lua.lua`
- [ ] `tests/lua_barebones_init_test.lua` — `lua/barebones/init.lua`
- [ ] `tests/lua_feature_complete_shell_plugins_version_control_test.lua` — `lua/feature_complete/shell_plugins/version_control.lua`
- [ ] `tests/lua_feature_complete_vim_plugins_lsp_test.lua` — `lua/feature_complete/vim_plugins/lsp.lua`
- [x] `tests/lua_feature_complete_vim_plugins_movements_test.lua` — `lua/feature_complete/vim_plugins/movements.lua`
- [x] `tests/lua_feature_complete_vim_plugins_quickfix_list_test.lua` — `lua/feature_complete/vim_plugins/quickfix_list.lua`
- [x] `tests/lua_helpers_test.lua` — `lua/helpers.lua`
- [x] `tests/lua_shared_auto_commands_test.lua` — `lua/shared/auto_commands.lua`
- [x] `tests/lua_shared_keymaps_test.lua` — `lua/shared/keymaps.lua`
- [x] `tests/lua_shared_movements_test.lua` — `lua/shared/movements.lua`
- [x] `tests/lua_shared_notify_test.lua` — `lua/shared/notify.lua`
- [x] `tests/lua_shared_pairs_test.lua` — `lua/shared/pairs.lua`
- [x] `tests/lua_shared_quickfix_list_test.lua` — `lua/shared/quickfix_list.lua`
- [x] `tests/lua_shared_tabline_test.lua` — `lua/shared/tabline.lua`
- [x] `tests/lua_shared_user_commands_test.lua` — `lua/shared/user_commands.lua`

## Verification after approval

Run `make test`, `make lint`, and StyLua checks. When tests are added, confirm MiniTest discovers every `*_test.lua` file along with the existing `test_*.lua` suite.
