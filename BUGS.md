# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case or reproduction that pins it down.

## `lua/shared/notify.lua` — newline cut mixes byte and character offsets

`string.find(message, "\n", 1, true)` returns a byte index, but it is passed to `strcharpart` as a character count. Any multibyte character before the newline inflates the index, so the newline and part of the following line survive the cut: `vim.notify("日本語\nsecond", vim.log.levels.INFO)` echoes `日本語\nsecon…` instead of `日本語…`.

## `lua/shared/notify.lua` — message width ignores double-width characters

`needs_cut` compares `strchars(message)` with `columns - 1`, counting characters instead of display cells, so a wide-character message overflows the window: with `columns = 40`, 30 `猫` (60 cells) is echoed unchanged.

## `lua/shared/keymaps.lua:301` — `<C-g>` closes an already closed tag with a doubled slash

The tag content is whatever sits between the last `<` and the next `>` before the cursor, and it is only trimmed of leading whitespace, so a closing tag is read as a tag name. At the end of `<div></div>` or `text</div>`, `<C-g>` inserts `<//div>`.

## `lua/shared/keymaps.lua:146` — `<leader>yf` duplicates the entries only

`vim.fn.setqflist(vim.fn.getqflist())` passes the entries without `title` or `context`, so the duplicate is titled `:setqflist()` and has an empty context: a list with `title = "first"` and `context = { id = 1 }` is copied as `title = ":setqflist()"`, `context = ""`.

## `lua/shared/keymaps.lua:172` — `zk` leaves the cursor inside the closed fold

`next_closed_fold "k"` stops as soon as `foldclosed()` reports a fold, and Vim's `zk` lands on the fold's last line, so the cursor ends on a line the closed fold hides: with folds 2-4 and 10-12 closed, `zjzj` reaches line 10 and then `zk` reports cursor line 4, whose `foldclosed(4)` is still 2. `zj` is asymmetric — it lands on the fold's first line.

## `lua/shared/keymaps.lua:130` — the `relpath is nil` guard in `<leader>ye`/`yr` is unreachable for unnamed buffers

`vim.fs.relpath(cwd, "")` returns `"."` rather than nil, so an unnamed buffer sets the registers to `.` (or `.|<row>|<col>` for `<leader>ye`) instead of warning. Only an uncomputed relative path (e.g. across Windows drives) reaches the guard.
