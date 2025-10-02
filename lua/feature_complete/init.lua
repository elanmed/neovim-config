local h = require "helpers"

vim.pack.add {
  "https://github.com/mfussenegger/nvim-jdtls",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/mbbill/undotree",
  -- far
  "https://github.com/MagicDuck/grug-far.nvim",
  -- file_tree
  "https://github.com/elanmed/tree.nvim",
  -- fzf
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/elanmed/rg-glob-builder.nvim",
  "https://github.com/elanmed/fzf-lua-frecency.nvim",
  -- ff
  "https://github.com/elanmed/ff.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  -- lsp
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  -- movements
  "https://github.com/folke/flash.nvim",
  "https://github.com/chentoast/marks.nvim",
  "https://github.com/elanmed/ft-highlight.nvim",
  -- quickfix
  "https://github.com/elanmed/quickfix-preview.nvim",
  -- treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/RRethy/nvim-treesitter-endwise",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
}

vim.system({ "make", }, { cwd = vim.pack.get { "telescope-fzf-native.nvim", }[1].path, }):wait()

h.require_dir "feature_complete/plugins"
