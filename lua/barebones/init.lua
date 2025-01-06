local h = require "shared.helpers"

h.let.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "netrw",
  callback = function()
    h.map({ "n", }, "-", "-^") -- go up a directory
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "wildmenu",
  callback = function()
    h.map({ "n", }, "<C-n>", "<tab>")
    h.map({ "n", }, "<C-p>", "<S-tab>")
  end,
})

h.map({ "n", }, "z", "zz")
h.map({ "n", }, "L", h.user_cmd_cb "bnext", { desc = "Next buffer", })
h.map({ "n", }, "H", h.user_cmd_cb "bprev", { desc = "Previous buffer", })
h.map({ "n", "v", }, "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current file", })
vim.opt.path:append "**" -- search in subfolder
vim.cmd "nnoremap <C-p> :find<space>"
vim.cmd "inoremap <C-p> :find<space>"
vim.cmd "vnoremap <C-p> :find<space>"
h.map({ "i", }, "<C-s>", "<C-n>") -- autocomplete
vim.cmd "nnoremap <C-g> :buffer<space>"
vim.cmd "vnoremap <C-g> :buffer<space>"
vim.cmd "nnoremap <leader>lg :grep<space>"

h.map({ "n", }, "gd", "<nop>")
h.map({ "n", }, "gh", "<nop>")
h.map({ "n", }, "<C-b>", "<nop>")
