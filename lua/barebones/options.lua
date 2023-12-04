local h = require "shared.helpers"

vim.cmd("colorscheme slate")
h.let.netrw_winsize = 40
h.let.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd({ "filetype" }, {
  pattern = "netrw",
  callback = function()
    local nmap = function(shortcut, command)
      vim.keymap.set("n", shortcut, command, { remap = true, silent = true, nowait = true })
    end

    nmap("h", "-^")     -- go up a directory
    nmap("l", "<cr>")
    nmap("P", "<C-w>z") -- close preview, p to open
  end
})
