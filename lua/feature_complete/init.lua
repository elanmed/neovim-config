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

local function build_pin_commit(plugin, commit)
  return function()
    local plugin_path = vim.fn.stdpath "data" .. "/site/pack/paqs/start/" .. plugin
    vim.fn.system { "git", "-C", plugin_path, "fetch", "--unshallow", }
    vim.fn.system { "git", "-C", plugin_path, "checkout", commit, }
  end
end

bootstrap_paq {
  "savq/paq-nvim",
  -- (no file)
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "tpope/vim-speeddating",
  "jxnblk/vim-mdx-js",
  -- buffers
  "akinsho/bufferline.nvim",
  -- cmp
  "windwp/nvim-autopairs",
  {
    "saghen/blink.cmp",
    build = build_pin_commit("blink.cmp", "586ee87534f5bf65f1c8dea2d1da2a57e8cddd36"),
  },
  "xzbdmw/colorful-menu.nvim",
  -- colorscheme
  "RRethy/nvim-base16",
  -- far
  "MagicDuck/grug-far.nvim",
  -- file_tree
  "stevearc/oil.nvim",
  "nvim-tree/nvim-web-devicons",
  "karb94/neoscroll.nvim",
  -- fzf
  "ibhagwan/fzf-lua",
  "elanmed/rg-glob-builder.nvim",
  "elanmed/fzf-lua-frecency.nvim",
  -- lsp
  "neovim/nvim-lspconfig",
  "stevearc/conform.nvim",
  -- movements
  "folke/flash.nvim",
  "chentoast/marks.nvim",
  "christoomey/vim-tmux-navigator",
  "kylechui/nvim-surround",
  "elanmed/ft-highlight.nvim",
  -- quickfix
  "elanmed/quickfix-preview.nvim",
  -- snacks
  "folke/snacks.nvim",
  -- statusline
  "nvim-lualine/lualine.nvim",
  "ojroques/vim-scrollstatus",
  -- treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", },
  "nvim-treesitter/nvim-treesitter-textobjects",
  "RRethy/nvim-treesitter-endwise",
  "windwp/nvim-ts-autotag",
  "JoosepAlviste/nvim-ts-context-commentstring",
  -- version_control
  "lewis6991/gitsigns.nvim",
  -- wild_menu
  "gelguy/wilder.nvim",
  "romgrk/fzy-lua-native",
}

h.require_dir "feature_complete/plugins"
