vim.opt.wildmode = "noselect"
vim.opt.wildoptions = "fuzzy"

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})

vim.keymap.set("c", "<C-e>", "<C-e><C-z>")
