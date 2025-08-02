local h = require "helpers"

vim.keymap.set("n", "L", h.keys.vim_cmd_cb "bnext")
vim.keymap.set("n", "H", h.keys.vim_cmd_cb "bprev")
vim.keymap.set("n", "]b", "<nop>")
vim.keymap.set("n", "[b", "<nop>")
require "mini.tabline".setup()
