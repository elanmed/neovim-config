local h = require "helpers"
-- local bufferline = require "bufferline"
--
-- bufferline.setup {
--   options = {
--     diagnostics = "nvim_lsp",
--     style_preset = bufferline.style_preset.no_italic,
--     custom_filter = function(buf_number)
--       local buf_name = vim.fn.bufname(buf_number)
--       if buf_name == "" then return false end
--
--       local excluded_filetypes = { "grug-far", }
--       local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf_number, })
--       if vim.tbl_contains(excluded_filetypes, filetype) then
--         return false
--       end
--
--       return true
--     end,
--   },
-- }

vim.keymap.set("n", "L", h.keys.vim_cmd_cb "bnext")
vim.keymap.set("n", "H", h.keys.vim_cmd_cb "bprev")
vim.keymap.set("n", "]b", "<nop>")
vim.keymap.set("n", "[b", "<nop>")
require "mini.tabline".setup()
