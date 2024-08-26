require "feature_complete.packer"

require "feature_complete.plugins.aerial"
require "feature_complete.plugins.bufferline"
require "feature_complete.plugins.bqf"
require "feature_complete.plugins.coc"
require "feature_complete.plugins.comment"
require "feature_complete.plugins.commentstring"
require "feature_complete.plugins.easymotion"
require "feature_complete.plugins.gitsigns"
require "feature_complete.plugins.harpoon2"
require "feature_complete.plugins.leap"
require "feature_complete.plugins.lualine"
require "feature_complete.plugins.neoclip"
require "feature_complete.plugins.mini_map"
require "feature_complete.plugins.neoscroll"
require "feature_complete.plugins.oil"
require "feature_complete.plugins.tele"
require "feature_complete.plugins.treesitter"
require "feature_complete.plugins.visual_multi"
require "feature_complete.plugins.zen_mode"

require("ibl").setup({
  scope = {
    show_start = false
  }
})
require("flit").setup()
require("auto-session").setup({
  auto_session_use_git_branch = true,
  auto_save_enabled = true
})
require("nvim-autopairs").setup({
  map_cr = false
})
require("marks").setup({
  excluded_filetypes = { "oil" },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "me",         -- nExt
    prev = "mr",         -- pRev
    delete_line = "dml", -- delete mark on the current Line
    delete_buf = "dma",  -- delete All
  }
})
