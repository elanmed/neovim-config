return {
  {
    "RRethy/nvim-base16",
    commit = "6ac181b",
    lazy = false,
    priority = 1000,
    config = function()
      require("base16-colorscheme").setup(require "feature_complete.colors.all_colors")
    end
  },

  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "tpope/vim-surround",
    dependencies = { "ggandor/leap.nvim" }
  },
  { "tpope/vim-repeat" },
  { "tpope/vim-speeddating" },
  { "tpope/vim-fugitive" },
  {
    "mg979/vim-visual-multi",
    commit = "38b0e8d"
  },
  {
    "windwp/nvim-autopairs",
    commit = "19606af",
    event = "InsertEnter",
    opts = { map_cr = false }
  },
  {
    "neoclide/coc.nvim",
    branch = "release",
    commit = "ae1a557"
  },
  {
    "MeanderingProgrammer/markdown.nvim",
    commit = "8c67dbc",
    opts = {},
    ft = "markdown"
  },

  -- movements
  {
    "ggandor/leap.nvim",
    commit = "c6bfb19",
    config = function()
      local leap = require("leap")
      leap.create_default_mappings()
      leap.opts.highlight_unlabeled_phase_one_targets = true
    end
  },
  {
    "easymotion/vim-easymotion",
    commit = "b3cfab2"
  },
  {
    "ggandor/flit.nvim",
    commit = "1ef72de",
    opts = {}
  },
  {
    "chentoast/marks.nvim",
    commit = "74e8d01",
    opts = {
      excluded_filetypes = { "oil" },
      default_mappings = false,
      mappings = {
        toggle = "mt",
        next = "me",         -- nExt
        prev = "mr",         -- pRev
        delete_line = "dml", -- delete mark on the current Line
        delete_buf = "dma",  -- delete All
      }
    }
  },
  {
    "christoomey/vim-tmux-navigator",
    commit = "5b3c701"
  },

  -- telescope
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    commit = "cf48d4d"
  },
  {
    "fannheyward/telescope-coc.nvim",
    commit = "b305a2c"
  },
  -- {  "nvim-telescope/telescope-frecency.nvim" },

  -- file tree
  {
    "kyazdani42/nvim-web-devicons",
    commit = "3722e3d"
  },
  {
    "preservim/nerdtree",
    commit = "9b465ac"
  },
}
