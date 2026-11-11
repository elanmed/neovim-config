# Plan: add meaningful tests for config Lua sources

## Scope

Future work: create one meaningful `mini.test` file for each of the 29 in-scope config-owned Lua source files under the repository root. Do not add empty smoke-test placeholders; this TODO list tracks the backlog. Exclude `after/`, `ftplugin/java.lua`, all of `fzf_scripts/`, `lua/feature_complete/shell_plugins/fzf.lua` (these fzf files are planned to move into a plugin), `tests/`, `deps/`, and `language_servers/`. The language-server release under `language_servers/` is an ignored installed distribution, and `deps/mini.test` is test infrastructure; neither should receive project tests. Tests themselves are excluded to avoid recursively creating tests for tests.

Place each eventual test in `tests/` and name it by replacing `/` in the source path with `_`, removing `.lua`, then appending `_test.lua` (for example, `lua/shared/options.lua` becomes `tests/lua_shared_options_test.lua`). Each test should exercise observable behavior rather than use a dummy equality assertion.

`mini.test` discovers `test_*.lua` by default, so update `scripts/minimal_init.lua` to discover both the existing `test_*.lua` file and the new `*_test.lua` files. This preserves the existing dummy suite while ensuring the per-file tests are collected. The current `make test` target will remain unchanged.

## Consult the template.nvim model

Shallow-clone `elanmed/template.nvim` to `/tmp/template.nvim`. Read `/tmp/template.nvim/PRINCIPLES.md` in full and assess which principles apply to this Neovim config and its tests.

## TODO: create and fill in substantive tests

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
- [x] `tests/lua_helpers_test.lua` — `lua/helpers.lua`
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

Run `make test`, `make lint`, and StyLua checks. When tests are added, confirm MiniTest discovers every `*_test.lua` file along with the existing `test_*.lua` suite.
