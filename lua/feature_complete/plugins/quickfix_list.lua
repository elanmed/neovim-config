require "quickfix-preview".setup {
  pedit_prefix = "vertical rightbelow",
  pedit_postfix = "| wincmd =",
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
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

vim.api.nvim_create_autocmd({ "FileType", }, {
  callback = function()
    if vim.bo.buftype ~= "quickfix" then return end

    vim.keymap.set("n", "<leader>x", function()
      vim.cmd "pclose"
      vim.fn.setqflist({}, "f")
    end, { buffer = true, desc = "Clear all quickfix lists", })

    vim.keymap.set("n", "<leader>d", function()
      vim.cmd "pclose"
      vim.fn.setqflist({}, "r")
    end, { buffer = true, desc = "Clear the current quickfix list", })
  end,
})
