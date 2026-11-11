# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case that pins it down.

## `Format` writes the buffer even when formatting changed nothing

`lua/shared/user_commands.lua:21` runs `vim.cmd.write { mods = { silent = true } }` unconditionally after `keepjumps normal! gg=G`, so every `:Format` on an unchanged buffer still hits the disk and fires `BufWritePre`/`BufWritePost` (auto-commands, watchers, LSP `didSave`, formatters-on-save).

Test: `tests/lua_shared_user_commands_test.lua` -> `Format | formats and writes the current buffer`.

## `Snippet` keeps one character past the cursor and drops the rest of the line

`lua/shared/user_commands.lua:63-64` computes `col_1i_incl = col_0i + 2` and then `curr_content = line_content:sub(1, col_1i_incl)`, so the prefix taken from the current line is one character longer than the text before the cursor. With the cursor on column 0 of `  click("x")` the prefix is `"  "`, and because the whole line is replaced, everything after the cursor is discarded.

Test: `tests/lua_shared_user_commands_test.lua` -> `Snippet | replaces the current line with the snippet content`.

## `Snippet` errors out when the snippet file is missing

`lua/shared/user_commands.lua:65` calls `vim.fn.readfile` without a guard, so a trigger whose file was deleted raises `E484: Can't open file ...` instead of the `vim.notify(..., vim.log.levels.WARN)` path used for an unknown trigger.

No test: the mapping is hardcoded to files that currently exist in `snippets/`.

## `Tabline` pads to a fractional length on odd widths

`lua/shared/tabline.lua:62-68` uses `min_len = section_len * 1.5`, which is fractional whenever `section_len` is odd (`columns = 57` -> `19 * 1.5 = 28.5`). `h.str.pad` then calls `string.rep(" ", 28.5 - #value)`, relying on implicit float-to-int truncation, so the padding is one column short: `h.str.pad("abc", { min_len = 28.5, side = "right" })` returns 28 characters.

Test: `tests/lua_shared_tabline_test.lua` -> `Tabline() | caps the sections at forty columns` covers only the exact (`columns = 300` -> `60`) case.

## `GetQuickfixTextFunc` cuts multibyte text in the middle of a character

`lua/shared/quickfix_list.lua:49-50` compares `vim.fn.strchars(formatted_item)` with `win_width` but then truncates with the byte-based `formatted_item:sub(1, win_width)`. With multibyte text in the entry the cut can land inside a character, so the returned line ends with a lone UTF-8 lead byte (`"dd/f.lua | 1:1 | " .. string.rep("é", 11) .. "\195"`).

Test: `tests/lua_shared_quickfix_list_test.lua` -> `GetQuickfixTextFunc() | cuts multibyte text in the middle of a character`.

## `GetQuickfixTextFunc` names fileless entries after the current buffer

`lua/shared/quickfix_list.lua:14,28,35` pass `item.bufnr` straight to `vim.fn.bufname`. Entries without a file have `bufnr` 0, which Neovim resolves to the *current* buffer, so a text-only entry is labeled with whatever file is focused (`alpha/short.lua | 0:0 | no file`) or with a shortened `"."` when that buffer is unnamed.

Test: `tests/lua_shared_quickfix_list_test.lua` -> `GetQuickfixTextFunc() | uses the current buffer name for entries without a file`.
