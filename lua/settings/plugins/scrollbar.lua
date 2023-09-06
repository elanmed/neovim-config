local h = require "shared.helpers"
local scrollbar = require "scrollbar"

vim.api.nvim_create_augroup("ScrollbarInit", {})
vim.api.nvim_create_autocmd({ "WinScrolled", "VimResized", "QuitPre" }, {
  group = "ScrollbarInit",
  callback = h.pcall_cb(scrollbar.show)
})
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
  group = "ScrollbarInit",
  callback = h.pcall_cb(scrollbar.show)
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "BufWinLeave", "FocusLost" }, {
  group = "ScrollbarInit",
  callback = h.pcall_cb(scrollbar.clear)
})
