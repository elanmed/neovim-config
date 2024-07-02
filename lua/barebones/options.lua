local h = require "shared.helpers"

vim.cmd("colorscheme slate")
h.let.netrw_winsize = 40
h.let.netrw_banner = 0    -- removes banner at the top
h.let.netrw_liststyle = 3 -- tree
h.let.netrw_keepdir = 0

vim.api.nvim_create_autocmd({ "filetype" }, {
  pattern = "netrw",
  callback = function()
    local nmap = function(shortcut, command)
      vim.keymap.set("n", shortcut, command, { remap = true, silent = true, nowait = true })
    end

    nmap("-", "-^")      -- go up a directory
    nmap("P", "<C-w>z")  -- close preview, p to open
    nmap("r", "R")       -- rename
    nmap("a", "%:w<cr>") -- new file
  end
})
