vim.pack.add {
  "https://github.com/neovim/nvim-lspconfig",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main", },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/tpope/vim-surround",
  "https://github.com/windwp/nvim-ts-autotag",

  "https://github.com/mfussenegger/nvim-jdtls",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/ibhagwan/fzf-lua",

  "https://github.com/elanmed/fzf-lua-frecency.nvim",
  "https://github.com/elanmed/rg-far.nvim",
  "https://github.com/elanmed/tree.nvim",
  "https://github.com/elanmed/rg-glob-builder.nvim",
  "https://github.com/elanmed/ff.nvim",
  "https://github.com/elanmed/seek.nvim",
  "https://github.com/elanmed/ft-highlight.nvim",
  "https://github.com/elanmed/marks.nvim",
  "https://github.com/elanmed/quickfix-preview.nvim",
}

local h = require "helpers"
h.utils.require_dir "feature_complete/plugins"
h.utils.lazy_load(function() vim.cmd.packadd "nvim.undotree" end)
h.utils.lazy_load(function() require "nvim-ts-autotag".setup() end)

vim.keymap.set({ "x", "o", }, "af", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o", }, "if", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
