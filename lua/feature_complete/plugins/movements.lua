vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptBegin",
  callback = function() vim.b.coc_diagnostic_disable = 1 end
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptEnd",
  callback = function() vim.b.coc_diagnostic_disable = 0 end
})

return {
  {
    "ggandor/leap.nvim",
    commit = "c6bfb19",
    config = function()
      local leap = require("leap")
      leap.create_default_mappings()
      leap.opts.highlight_unlabeled_phase_one_targets = true
    end
  },
  {
    "easymotion/vim-easymotion",
    commit = "b3cfab2"
  },
  {
    "ggandor/flit.nvim",
    commit = "1ef72de",
    opts = {}
  },
  {
    "chentoast/marks.nvim",
    commit = "74e8d01",
    opts = {
      excluded_filetypes = { "oil" },
      default_mappings = false,
      mappings = {
        toggle = "mt",
        next = "me",         -- nExt
        prev = "mr",         -- pRev
        delete_line = "dml", -- delete mark on the current Line
        delete_buf = "dma",  -- delete All
      }
    }
  },
  {
    "christoomey/vim-tmux-navigator",
    commit = "5b3c701"
  },
  {
    "mg979/vim-visual-multi",
    commit = "38b0e8d"
  },
}
