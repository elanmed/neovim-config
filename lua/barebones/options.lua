local h = require "shared.helpers"

h.let.netrw_winsize = 40
h.let.netrw_banner = 0 -- removes banner at the top
h.let.netrw_keepdir = 0

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "netrw",
  callback = function()
    h.nmap("-", "-^") -- go up a directory
  end
})
