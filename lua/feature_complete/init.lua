vim.pack.add {
  "https://github.com/neovim/nvim-lspconfig",

  "https://github.com/mfussenegger/nvim-jdtls",
  "https://github.com/ibhagwan/fzf-lua",

  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.splitjoin",

  "https://github.com/elanmed/fzf-lua-frecency.nvim",
  "https://github.com/elanmed/ff.nvim",
  "https://github.com/elanmed/rg-far.nvim",
  "https://github.com/elanmed/tree.nvim",
  "https://github.com/elanmed/surround.nvim",
  "https://github.com/elanmed/seek.nvim",
  "https://github.com/elanmed/marks.nvim",
  "https://github.com/elanmed/ft-highlight.nvim",
  "https://github.com/elanmed/quickfix-preview.nvim",
}

local h = require "helpers"
h.utils.require_dir "feature_complete/vim_plugins"
h.utils.require_dir "feature_complete/shell_plugins"
vim.cmd.packadd "nvim.undotree"
