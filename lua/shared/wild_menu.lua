vim.opt.wildmode = "noselect"
vim.opt.wildoptions = "fuzzy"

local prev_cmdline = ""
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = ":",
  callback = function()
    prev_cmdline = ""
  end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    local curr_cmdline = vim.fn.getcmdline()
    -- CmdlineChanged fires twice with the same value of getcmdline()
    if curr_cmdline ~= prev_cmdline then
      vim.fn.feedkeys("\26", "n") -- <C-Z>, the default wildcharm
    end
    prev_cmdline = curr_cmdline
  end,
})

vim.keymap.set("c", "<C-e>", "<C-e><C-z>")
