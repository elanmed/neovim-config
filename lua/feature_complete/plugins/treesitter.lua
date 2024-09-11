return {
  "nvim-treesitter/nvim-treesitter",
  commit = "7a64148",
  -- https://github.com/rafamadriz/dotfiles/commit/c1268c73bdc7da52af0d57dcbca196ca3cb5ed79
  build = function() require("nvim-treesitter.install").update() end,
  dependencies = {
    {
      "lukas-reineke/indent-blankline.nvim",
      commit = "18603eb",
      config = function()
        require('ibl').setup({
          scope = {
            show_start = false,
            show_end = false
          }
        })
      end
    },
    { "windwp/nvim-ts-autotag",         commit = "e239a56" },
    { "RRethy/nvim-treesitter-endwise", commit = "8b34305" },
    "JoosepAlviste/nvim-ts-context-commentstring",
    "numToStr/Comment.nvim",
    "nvim-treesitter/nvim-treesitter-textobjects"
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
}
