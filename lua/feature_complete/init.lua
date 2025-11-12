vim.pack.add {
  "https://github.com/neovim/nvim-lspconfig",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", },

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
vim.cmd.packadd "nvim.undotree"
require "helpers".require_dir "feature_complete/plugins"

vim.keymap.set("n", "<leader>r", require "rg-far".open, { desc = "Open the rg-far ui", })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rg-far",
  callback = function()
    vim.keymap.set("n", "<leader>s", "<Plug>RgFarReplace", { buffer = true, })
    vim.keymap.set("n", "<leader>f", "<Plug>RgFarResultsToQfList<Plug>RgFarClose", { buffer = true, })
  end,
})
