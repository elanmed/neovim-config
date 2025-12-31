vim.keymap.set("n", "<leader>r", require "rg-far".open, { desc = "Open the rg-far ui", })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("RgFarRemaps", { clear = true, }),
  pattern = "rg-far",
  callback = function()
    vim.keymap.set("n", "<leader>r", "<Plug>RgFarClose", { buffer = true, })
    vim.keymap.set("n", "<leader>s", "<Plug>RgFarReplace", { buffer = true, })
    vim.keymap.set("n", "<leader>f", "<Plug>RgFarResultsToQfList<Plug>RgFarClose", { buffer = true, })
    vim.keymap.set("n", "<leader>o", "<Plug>RgFarOpenResult", { buffer = true, })
    vim.keymap.set("n", "<leader>e", "<Plug>RgFarRefreshResults", { buffer = true, })
  end,
})
