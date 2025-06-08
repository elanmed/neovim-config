-- require "quickfix-preview".setup {
--   pedit_prefix = "vertical rightbelow",
--   pedit_postfix = "| wincmd =",
--   keymaps = {
--     select_close_preview = "o",
--     select_close_quickfix = "<cr>",
--     toggle = "t",
--     next = { key = "<C-n>", },
--     prev = { key = "<C-p>", },
--     cnext = { key = "]q", },
--     cprev = { key = "[q", },
--   },
--   preview_win_opts = {
--     relativenumber = false,
--     number = true,
--     signcolumn = "no",
--     cursorline = true,
--   },
-- }

require "homegrown_plugins.quickfix_preview.init".setup {
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "]q", },
    cprev = { key = "[q", },
  },
  get_preview_win_opts = function()
    return { relativenumber = false, number = true, signcolumn = "no", cursorline = true, winblend = 5, }
  end,
  get_open_win_opts = function()
    return { border = "rounded", }
  end,

}
