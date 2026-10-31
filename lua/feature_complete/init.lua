vim.pack.add {
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mfussenegger/nvim-jdtls",

  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.splitjoin",

  "https://github.com/elanmed/ff.nvim", -- [x]
  "https://github.com/elanmed/rg-far.nvim", -- [x]
  "https://github.com/elanmed/tree.nvim", -- [x]
  "https://github.com/elanmed/surround.nvim", -- [x]
  "https://github.com/elanmed/seek.nvim", -- [x]
  "https://github.com/elanmed/marks.nvim", -- [x]
  "https://github.com/elanmed/ft-highlight.nvim", -- [x]
  "https://github.com/elanmed/quickfix-preview.nvim", -- [x]
  "https://github.com/elanmed/git-hunks.nvim", -- [ ]
  "https://github.com/elanmed/git-diffs.nvim", -- [ ]
}

local h = require "helpers"
h.utils.require_dir "feature_complete/vim_plugins"
h.utils.require_dir "feature_complete/shell_plugins"
vim.cmd.packadd "nvim.undotree"
