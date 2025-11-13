vim.api.nvim_create_autocmd({ "FileType", }, {
  group = vim.api.nvim_create_augroup("QfListPreviewRemaps", { clear = true, }),
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "t", "<Plug>QuickfixPreviewToggle", { buffer = true, })

    vim.keymap.set("n", "<leader>x", function()
      vim.cmd.QuickfixPreviewClosePreview()
      vim.fn.setqflist({}, "f")
    end, { buffer = true, desc = "Clear all quickfix lists", })

    vim.keymap.set("n", "<leader>d", function()
      vim.cmd.QuickfixPreviewClosePreview()
      vim.fn.setqflist({}, "r")
    end, { buffer = true, desc = "Clear the current quickfix list", })
  end,
})
