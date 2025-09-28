vim.g.quickfix_preview = {
  pedit_prefix = "vertical rightbelow",
  pedit_postfix = "| wincmd =",
  preview_win_opts = {
    relativenumber = false,
    signcolumn = "no",
  },
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "o", "<Plug>QuickfixPreviewSelectClosePreview", { buffer = true, })
    vim.keymap.set("n", "<cr>", "<Plug>QuickfixPreviewSelectCloseQuickfix", { buffer = true, })
    vim.keymap.set("n", "t", "<Plug>QuickfixPreviewToggle", { buffer = true, })
    vim.keymap.set("n", "<C-n>", "<Plug>QuickfixPreviewNext", { buffer = true, })
    vim.keymap.set("n", "<C-p>", "<Plug>QuickfixPreviewPrev", { buffer = true, })

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

vim.keymap.set("n", "<C-n>", "<Plug>QuickfixPreviewCNext")
vim.keymap.set("n", "<C-p>", "<Plug>QuickfixPreviewCPrev")

vim.api.nvim_create_autocmd({ "BufWinEnter", }, {
  callback = function()
    if not vim.api.nvim_get_option_value("previewwindow", { win = 0, }) then
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
    end
  end,
})
