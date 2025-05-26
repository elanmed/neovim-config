require "quickfix-preview".setup {
  pedit_prefix = "vertical rightbelow",
  pedit_postfix = "| wincmd =",
  keymaps = {
    open = "o",
    openc = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "]q", },
    cprev = { key = "[q", },
  },
  preview_win_opts = {
    relativenumber = false,
    number = true,
    signcolumn = "no",
    cursorline = true,
  },
}
