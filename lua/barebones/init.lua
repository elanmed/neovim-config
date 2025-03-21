local h = require "shared.helpers"

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "wildmenu",
  callback = function()
    h.keys.map({ "n", }, "<C-n>", "<tab>")
    h.keys.map({ "n", }, "<C-p>", "<S-tab>")
  end,
})

h.keys.map({ "n", }, "gy", h.keys.user_cmd_cb "cex \"\"", { desc = "Clear all quickfix lists", })
h.keys.map({ "n", }, "z", "zz")
h.keys.map({ "n", }, "L", h.keys.user_cmd_cb "bnext", { desc = "Next buffer", })
h.keys.map({ "n", }, "H", h.keys.user_cmd_cb "bprev", { desc = "Previous buffer", })

-- removing banner causes a bug where the terminal flickers
-- h.let.netrw_banner = 0 -- removes banner at the top
h.let.netrw_liststyle = 3 -- tree view
h.keys.map({ "n", }, "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current file", })
vim.opt.path:append "**" -- search in subfolder
h.keys.map({ "n", }, "<C-p>",
  function()
    vim.notify("use <C-z> and <C-p> in the terminal instead!", vim.log.levels.ERROR)
  end)
h.keys.map({ "i", }, "<C-s>", "<C-n>") -- autocomplete
vim.cmd "nnoremap <C-g> :buffer<space>"
vim.cmd "nnoremap <leader>lg :grep<space>"
h.keys.map({ "c", }, "/", function()
  if vim.fn.wildmenumode() == 1 then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })

h.keys.map({ "n", }, "gd", "<nop>")
h.keys.map({ "n", }, "gh", "<nop>")
h.keys.map({ "n", }, "<C-b>", "<nop>")
