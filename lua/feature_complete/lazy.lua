-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },

    -- tpope
    { "tpope/vim-surround",
      dependencies = { "ggandor/leap.nvim" }
    },
    { "tpope/vim-repeat" },
    { "tpope/vim-speeddating" },

    { "mg979/vim-visual-multi",    commit = "38b0e8d" },
    { "windwp/nvim-autopairs",     commit = "19606af" },
    { "stevearc/aerial.nvim",      commit = "92f93f4" },
    { "neoclide/coc.nvim",         branch = "release", commit = "ae1a557" },

    -- visuals
    { "nvim-lualine/lualine.nvim", commit = "b431d22" },
    { "echasnovski/mini.map",      commit = "8baf542" },
    { "folke/zen-mode.nvim",       commit = "29b292b" },
    { "karb94/neoscroll.nvim",     commit = "532dcc8" },

    -- movements
    { "ggandor/leap.nvim",
      commit = "c6bfb19",
      config = function()
        require("leap").create_default_mappings()
      end
    },
    { "easymotion/vim-easymotion",      commit = "b3cfab2" },
    { "ggandor/flit.nvim",              commit = "1ef72de" },
    { "chentoast/marks.nvim",           commit = "74e8d01" },
    { "christoomey/vim-tmux-navigator", commit = "5b3c701" },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      commit = "0378a6c"
    },

    -- buffers as tabs
    { "akinsho/bufferline.nvim",                  commit = "0b2fd86" },
    { "RRethy/nvim-base16",                       commit = "6ac181b" },
    { "numtostr/BufOnly.nvim",                    cmd = "BufOnly",           commit = "30579c2" },

    -- bqf
    { "kevinhwang91/nvim-bqf",                    commit = "1b24dc6" },
    { "junegunn/fzf",                             build = "./install --bin", commit = "a09c6e9" },

    -- telescope
    { "nvim-telescope/telescope.nvim",            commit = "a0bbec2" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make",            commit = "cf48d4d" },
    { "AckslD/nvim-neoclip.lua",                  commit = "709c97f" },
    { "fannheyward/telescope-coc.nvim",           commit = "b305a2c" },
    -- {  "nvim-telescope/telescope-frecency.nvim" },

    -- git
    { "lewis6991/gitsigns.nvim",                  commit = "899e993" },
    { "tpope/vim-fugitive" },

    -- file tree
    { "kyazdani42/nvim-web-devicons",             commit = "3722e3d" },
    { "stevearc/oil.nvim",                        commit = "30e0438" },
    { "preservim/nerdtree",                       commit = "9b465ac" },

    -- treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      -- https://github.com/rafamadriz/dotfiles/commit/c1268c73bdc7da52af0d57dcbca196ca3cb5ed79
      build = function() require("nvim-treesitter.install").update() end,
      commit = "7a64148",
      dependencies = {
        { "windwp/nvim-ts-autotag",                      commit = "e239a56" },
        { "JoosepAlviste/nvim-ts-context-commentstring", commit = "375c2d8" },
        { "lukas-reineke/indent-blankline.nvim",         commit = "db92699" },
        { "numToStr/Comment.nvim",                       commit = "e30b7f2" },
        { "RRethy/nvim-treesitter-endwise",              commit = "8b34305" },
      },
      opts = {
        {
          ensure_installed = {
            "bash",
            "comment",
            "css",
            "html",
            "javascript",
            "json",
            "json5",
            "jsonc",
            "lua",
            "markdown",
            "regex",
            "ruby",
            "scss",
            "tsx",
            "typescript",
            "yaml",
            "vimdoc"
          },
          indent = { enable = true },
          autotag = { enable = true, },
          endwise = { enable = true, },
        }
      }
    },
    ({
      "MeanderingProgrammer/markdown.nvim",
      commit = "8c67dbc",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {}
    })

  },
}
