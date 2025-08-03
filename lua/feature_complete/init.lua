local h = require "helpers"

-- :h paq-bootstrapping
local function clone_paq()
  local path = vim.fn.stdpath "data" .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
  if not is_installed then
    vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path, }
    return true
  end
end

local function bootstrap_paq(packages)
  local first_install = clone_paq()
  vim.cmd.packadd "paq-nvim"
  local paq = require "paq"
  paq(packages)

  if first_install then
    vim.notify "Installing plugins... If prompted, hit Enter to continue."
    paq.install()
  end
end

bootstrap_paq {
  "savq/paq-nvim",
  "echasnovski/mini.nvim",
  "tpope/vim-speeddating",
  "jxnblk/vim-mdx-js",
  -- cmp
  "saghen/blink.cmp",
  "xzbdmw/colorful-menu.nvim",
  -- far
  "MagicDuck/grug-far.nvim",
  -- fzf
  "junegunn/fzf.vim",
  "ibhagwan/fzf-lua",
  "elanmed/rg-glob-builder.nvim",
  "elanmed/fzf-lua-frecency.nvim",
  -- lsp
  "neovim/nvim-lspconfig",
  "stevearc/conform.nvim",
  -- movements
  "folke/flash.nvim",
  "chentoast/marks.nvim",
  "elanmed/ft-highlight.nvim",
  "karb94/neoscroll.nvim",
  -- quickfix
  "elanmed/quickfix-preview.nvim",
  -- snacks
  "folke/snacks.nvim",
  -- treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", },
  "RRethy/nvim-treesitter-endwise",
  "windwp/nvim-ts-autotag",
  "JoosepAlviste/nvim-ts-context-commentstring",
  -- wild_menu
  "gelguy/wilder.nvim",
  "romgrk/fzy-lua-native",
}

h.require_dir "feature_complete/plugins"
