require "quickfix-preview".setup {
  pedit_prefix = "vertical rightbelow",
  pedit_postfix = "| wincmd =",
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "<C-n>", },
    cprev = { key = "<C-p>", },
  },
  preview_win_opts = {
    relativenumber = false,
    signcolumn = "no",
  },
}

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  callback = function()
    if not vim.api.nvim_get_option_value("previewwindow", { win = 0, }) then
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
    end
  end,
})

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
