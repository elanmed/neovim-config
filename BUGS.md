# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case or reproduction that pins it down.

## `lua/shared/notify.lua` — newline cut mixes byte and character offsets

`string.find(message, "\n", 1, true)` returns a byte index, but it is passed to `strcharpart` as a character count. Any multibyte character before the newline inflates the index, so the newline and part of the following line survive the cut: `vim.notify("日本語\nsecond", vim.log.levels.INFO)` echoes `日本語\nsecon…` instead of `日本語…`.

## `lua/shared/notify.lua` — message width ignores double-width characters

`needs_cut` compares `strchars(message)` with `columns - 1`, counting characters instead of display cells, so a wide-character message overflows the window: with `columns = 40`, 30 `猫` (60 cells) is echoed unchanged.

## `lua/feature_complete/shell_plugins/version_control.lua` — lazygit exit throws after `<c-c>` closed the window

`<c-c>` closes the floating window but leaves `lazygit_term_winnr` pointing at the destroyed window id and the job running. When lazygit later exits, `on_exit` calls `nvim_win_close` on that stale id without an `nvim_win_is_valid` guard, so it raises `Invalid window id` and `bdelete` never runs: the terminal buffer survives, and pressing `<leader>g` again finds it valid and reopens a dead buffer. Test: `tests/lua_feature_complete_shell_plugins_version_control_test.lua`, case `lazygit exit | errors when the exit arrives after <c-c> closed the window`.
