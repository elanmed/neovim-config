require "settings.plugins.packer"

require "settings.plugins.bufferline"
require "settings.plugins.bqf"
require "settings.plugins.coc"
require "settings.plugins.comment"
require "settings.plugins.commentstring"
require "settings.plugins.gitsigns"
require "settings.plugins.diffview"
require "settings.plugins.harpoon"
require "settings.plugins.indent"
require "settings.plugins.leap"
require "settings.plugins.lualine"
require "settings.plugins.neoclip"
require "settings.plugins.mini_map"
require "settings.plugins.neoscroll"
require "settings.plugins.oil"
require "settings.plugins.tele"
require "settings.plugins.treesitter"
require "settings.plugins.zen_mode"

require("flit").setup()
require("auto-session").setup({
  auto_session_use_git_branch = true,
  auto_save_enabled = true
})
require("nvim-autopairs").setup({
  map_cr = false
})
