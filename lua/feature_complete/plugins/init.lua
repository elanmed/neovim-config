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
  {
    "nvim-telescope/telescope.nvim",
    commit = "a0bbec2",
    dependencies = {
      "AckslD/nvim-neoclip.lua",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        commit = "cf48d4d"
      },
      {
        "fannheyward/telescope-coc.nvim",
        commit = "b305a2c"
      },
    },
  },

  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
}
