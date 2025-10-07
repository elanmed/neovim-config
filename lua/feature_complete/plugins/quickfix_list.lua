vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "t", "<Plug>QuickfixPreviewToggle", { buffer = true, })
    vim.keymap.set("n", "<C-n>", "<Plug>QuickfixPreviewNext", { buffer = true, })
    vim.keymap.set("n", "<C-p>", "<Plug>QuickfixPreviewPrev", { buffer = true, })

    vim.keymap.set("n", "<leader>x", function()
      -- TODO: allow closing the quickfix preview
      vim.fn.setqflist({}, "f")
    end, { buffer = true, desc = "Clear all quickfix lists", })

    vim.keymap.set("n", "<leader>d", function()
      vim.fn.setqflist({}, "r")
    end, { buffer = true, desc = "Clear the current quickfix list", })
  end,
})
