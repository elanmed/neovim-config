local h = require "shared.helpers"
local scrollbar = require "scrollbar"

vim.api.nvim_create_augroup("ScrollbarGroup", {})
vim.api.nvim_create_autocmd({ "WinScrolled", "VimResized", "QuitPre" }, {
  group = "ScrollbarGroup",
  callback = h.pcall_cb(scrollbar.show)
})
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
  group = "ScrollbarGroup",
  callback = h.pcall_cb(scrollbar.show)
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "BufWinLeave", "FocusLost" }, {
  group = "ScrollbarGroup",
  callback = h.pcall_cb(scrollbar.clear)
})
