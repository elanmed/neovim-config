# Plan: add smoke-test placeholders for every config Lua source

## Scope

Create one `mini.test` file for each of the 29 in-scope config-owned Lua source files under the repository root. Exclude `after/`, `ftplugin/java.lua`, all of `fzf_scripts/`, `lua/feature_complete/shell_plugins/fzf.lua` (these fzf files are planned to move into a plugin), `tests/`, `deps/`, and `language_servers/`. The language-server release under `language_servers/` is an ignored installed distribution, and `deps/mini.test` is test infrastructure; neither should receive project tests. Tests themselves are excluded to avoid recursively creating tests for tests.

Each new file will be placed in `tests/` and named by replacing `/` in the source path with `_`, removing `.lua`, then appending `_test.lua` (for example, `lua/shared/options.lua` becomes `tests/lua_shared_options_test.lua`). Each will contain one smoke case using a trivial `MiniTest.expect.equality(true, true)` assertion; these placeholders are to be filled out with meaningful checks later.

`mini.test` discovers `test_*.lua` by default, so update `scripts/minimal_init.lua` to discover both the existing `test_*.lua` file and the new `*_test.lua` files. This preserves the existing dummy suite while ensuring every generated smoke test runs. The current `make test` target will remain unchanged.

## TODO: replace smoke placeholders with substantive tests

- [ ] `tests/barebones_test.lua` — `barebones.lua`
- [ ] `tests/container_test.lua` — `container.lua`
- [ ] `tests/feature_complete_test.lua` — `feature_complete.lua`
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
- [ ] `tests/lua_helpers_test.lua` — `lua/helpers.lua`
- [ ] `tests/lua_shared_abbrev_test.lua` — `lua/shared/abbrev.lua`
- [ ] `tests/lua_shared_auto_commands_test.lua` — `lua/shared/auto_commands.lua`
- [ ] `tests/lua_shared_keymaps_test.lua` — `lua/shared/keymaps.lua`
- [ ] `tests/lua_shared_movements_test.lua` — `lua/shared/movements.lua`
- [ ] `tests/lua_shared_notify_test.lua` — `lua/shared/notify.lua`
- [ ] `tests/lua_shared_options_test.lua` — `lua/shared/options.lua`
- [ ] `tests/lua_shared_pairs_test.lua` — `lua/shared/pairs.lua`
- [ ] `tests/lua_shared_quickfix_list_test.lua` — `lua/shared/quickfix_list.lua`
- [ ] `tests/lua_shared_tabline_test.lua` — `lua/shared/tabline.lua`
- [ ] `tests/lua_shared_user_commands_test.lua` — `lua/shared/user_commands.lua`
- [ ] `tests/scripts_minimal_init_test.lua` — `scripts/minimal_init.lua`

## Verification after approval

Run `make test`, `make lint`, and StyLua checks. Confirm MiniTest discovers all 29 new smoke cases plus the existing smoke test, for 30 total cases.
