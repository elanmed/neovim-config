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
}
