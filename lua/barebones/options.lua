local h = require "shared.helpers"

h.let.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "netrw",
  callback = function()
    h.nmap("-", "-^") -- go up a directory
  end
})
