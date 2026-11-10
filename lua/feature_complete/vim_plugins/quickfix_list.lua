vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("QfListPreviewRemaps", { clear = true }),
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "t", "<Plug>QuickfixPreviewToggle", { buffer = true })
    vim.keymap.set("n", "<C-d>", "<Plug>QuickfixPreviewScrollDown", { buffer = true })
    vim.keymap.set("n", "<C-u>", "<Plug>QuickfixPreviewScrollUp", { buffer = true })

    vim.keymap.set("n", "<leader>x", function()
      vim.cmd.QuickfixPreviewClosePreview()
      vim.fn.setqflist({}, "f")
    end, { buffer = true, desc = "Clear all quickfix lists" })

    vim.keymap.set("n", "<leader>d", function()
      vim.cmd.QuickfixPreviewClosePreview()
      vim.fn.setqflist({}, "r")

      local qf_lists = require("helpers").qf.filter(function(qf_list)
        return #qf_list.items > 0
      end)
      require("helpers").qf.replace(qf_lists)
      if #qf_lists == 0 then
        vim.cmd.cclose()
      end
    end, { buffer = true, desc = "Clear the current quickfix list" })
  end,
})
