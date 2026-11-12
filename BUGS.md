# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case or reproduction that pins it down.

## `lua/shared/notify.lua` — newline cut mixes byte and character offsets

`string.find(message, "\n", 1, true)` returns a byte index, but it is passed to `strcharpart` as a character count. Any multibyte character before the newline inflates the index, so the newline and part of the following line survive the cut: `vim.notify("日本語\nsecond", vim.log.levels.INFO)` echoes `日本語\nsecon…` instead of `日本語…`.

## `lua/shared/notify.lua` — message width ignores double-width characters

`needs_cut` compares `strchars(message)` with `columns - 1`, counting characters instead of display cells, so a wide-character message overflows the window: with `columns = 40`, 30 `猫` (60 cells) is echoed unchanged.

## `lua/shared/keymaps.lua:130` — the `relpath is nil` guard in `<leader>ye`/`yr` is unreachable for unnamed buffers

`vim.fs.relpath(cwd, "")` returns `"."` rather than nil, so an unnamed buffer sets the registers to `.` (or `.|<row>|<col>` for `<leader>ye`) instead of warning. Only an uncomputed relative path (e.g. across Windows drives) reaches the guard.
