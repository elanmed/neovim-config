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
  -- (no file)
  "nvim-lua/popup.nvim",
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "jxnblk/vim-mdx-js",
  -- buffers
  "akinsho/bufferline.nvim",
  -- cmp
  "windwp/nvim-autopairs",
  "saghen/blink.cmp",
  "xzbdmw/colorful-menu.nvim",
  -- colorscheme
  "RRethy/nvim-base16",
  -- far
  "MagicDuck/grug-far.nvim",
  -- file_tree
  "stevearc/oil.nvim",
  "kyazdani42/nvim-web-devicons",
  "karb94/neoscroll.nvim",
  -- fzf
  "ibhagwan/fzf-lua",
  -- lsp
  "neovim/nvim-lspconfig",
  "stevearc/conform.nvim",
  -- movements
  "folke/flash.nvim",
  "chentoast/marks.nvim",
  "christoomey/vim-tmux-navigator",
  "kylechui/nvim-surround",
  "elanmed/ft-highlight.nvim",
  "elanmed/quickfix-preview.nvim",
  "elanmed/rg-glob-builder.nvim",
  -- snacks
  "folke/snacks.nvim",
  -- statusline
  "nvim-lualine/lualine.nvim",
  "ojroques/vim-scrollstatus",
  -- treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", },
  "nvim-treesitter/nvim-treesitter-textobjects",
  "MeanderingProgrammer/markdown.nvim",
  "RRethy/nvim-treesitter-endwise",
  "windwp/nvim-ts-autotag",
  "JoosepAlviste/nvim-ts-context-commentstring",
  -- version_control
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim",
  "sindrets/diffview.nvim",
  -- wild_menu
  "gelguy/wilder.nvim",
  "romgrk/fzy-lua-native",
  "Olical/nfnl",
}

local base_lua_path = vim.fn.stdpath "config" .. "/lua"              -- ~/.config/nvim/lua/
local glob_path = base_lua_path .. "/feature_complete/plugins/*.lua" -- ~/.config/nvim/lua/feature_complete/plugins/*.lua
for _, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
  -- convert absolute filename to relative
  -- ~/.config/nvim/lua/feature_complete/plugins/*.lua -> feature_complete/plugins/*
  local relfilename = path:gsub(base_lua_path, ""):gsub(".lua", "")
  require(relfilename)
end
