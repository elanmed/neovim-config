local h = require "shared.helpers"

h.let.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "netrw",
  callback = function()
    h.nmap("-", "-^") -- go up a directory
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "wildmenu",
  callback = function()
    h.nmap("<C-n>", "<tab>")
    h.nmap("<C-p>", "<S-tab>")
  end,
})

h.nmap("z", "zz")
h.nmap("L", h.user_cmd_cb "bnext", { desc = "Next buffer", })
h.nmap("H", h.user_cmd_cb "bprev", { desc = "Previous buffer", })
h.nmap("<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current file", })
vim.opt.path:append "**" -- search in subfolder
vim.cmd "nnoremap <C-p> :find<space>"
h.imap("<C-s>", "<C-n>") -- autocomplete
vim.cmd "nnoremap <C-g> :buffer<space>"
vim.cmd "nnoremap <leader>lg :grep<space>"

h.nmap("gd", "<nop>")
h.nmap("gh", "<nop>")
h.nmap("<C-b>", "<nop>")
