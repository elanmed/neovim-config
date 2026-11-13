# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case or reproduction that pins it down.

## `lua/shared/notify.lua` — newline cut mixes byte and character offsets

`string.find(message, "\n", 1, true)` returns a byte index, but it is passed to `strcharpart` as a character count. Any multibyte character before the newline inflates the index, so the newline and part of the following line survive the cut: `vim.notify("日本語\nsecond", vim.log.levels.INFO)` echoes `日本語\nsecon…` instead of `日本語…`.

## `lua/shared/notify.lua` — message width ignores double-width characters

`needs_cut` compares `strchars(message)` with `columns - 1`, counting characters instead of display cells, so a wide-character message overflows the window: with `columns = 40`, 30 `猫` (60 cells) is echoed unchanged.

## `lua/feature_complete/vim_plugins/lsp.lua` — virtual lines toggle always reports "disabled"

`toggle_virtual_lines` branches on `if current_virtual_lines == nil then "enabled" else "disabled"`, but `vim.diagnostic.config()` reports the default `virtual_lines = false` instead of `nil`, so the `nil` branch is unreachable: enabling virtual lines with `<C-t>` notifies `Virtual lines disabled` at `vim.log.levels.OFF`, exactly like disabling does. Pinned by `tests/lua_feature_complete_vim_plugins_lsp_test.lua` cases `toggles virtual lines on and off` and `notifies disabled when enabling over the VimEnter default`; the message should depend on the new value (`not current_virtual_lines`).

## `lua/feature_complete/vim_plugins/lsp.lua` — LSP formatting mixes the captured buffer with the current buffer

In `format_with_lsp` the request is issued for the buffer captured as `bufnr`, but the full-replacement branch builds `unformatted` from `vim.api.nvim_buf_get_lines(0, ...)` in the callback. If the user switches buffers while `textDocument/formatting` is in flight, the minimal diff is computed against the wrong buffer's text, and the resulting edits are applied to `bufnr`. No test pins this down; reproducing it needs a buffer switch between the request and the callback.

## `lua/feature_complete/vim_plugins/lsp.lua` — `:Add` reports success when staging fails

`stage_file` awaits `h.async.system { "git", "add", "--", name }` and throws the result away, so a non-zero `git add` still reaches `vim.notify("Staged", vim.log.levels.TRACE)`. Pinned by `tests/lua_feature_complete_vim_plugins_lsp_test.lua` case `notifies staged even when git add fails`; the error from `stage_file` should be propagated and notified at `vim.log.levels.ERROR` instead.

## `lua/feature_complete/vim_plugins/lsp.lua` — `:Add` stages stale content after an aborted write

`get_stageable_buffer_name` calls `M.write()` and ignores that it can abort (readonly buffer, non-normal buftype) before returning the name, so `:Add` stages the old on-disk content and notifies `Staged` while the buffer's edits stay out of the index. Pinned by case `stages the on-disk content of a modified readonly buffer`; `write` should report success and `get_stageable_buffer_name` should return `nil` when it did not write.
