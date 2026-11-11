# Potential bugs

Found while writing tests. Each entry records the code under test, the surprising behavior, and the test case that pins it down.

## `GetQuickfixTextFunc` cuts multibyte text in the middle of a character

`lua/shared/quickfix_list.lua:49-50` compares `vim.fn.strchars(formatted_item)` with `win_width` but then truncates with the byte-based `formatted_item:sub(1, win_width)`. With multibyte text in the entry the cut can land inside a character, so the returned line ends with a lone UTF-8 lead byte (`"dd/f.lua | 1:1 | " .. string.rep("é", 11) .. "\195"`).

Test: `tests/lua_shared_quickfix_list_test.lua` -> `GetQuickfixTextFunc() | cuts multibyte text in the middle of a character`.

## `GetQuickfixTextFunc` names fileless entries after the current buffer

`lua/shared/quickfix_list.lua:14,28,35` pass `item.bufnr` straight to `vim.fn.bufname`. Entries without a file have `bufnr` 0, which Neovim resolves to the _current_ buffer, so a text-only entry is labeled with whatever file is focused (`alpha/short.lua | 0:0 | no file`) or with a shortened `"."` when that buffer is unnamed.

Test: `tests/lua_shared_quickfix_list_test.lua` -> `GetQuickfixTextFunc() | uses the current buffer name for entries without a file`.
