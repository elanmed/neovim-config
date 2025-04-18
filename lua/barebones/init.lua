local h = require "shared.helpers"

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "wildmenu",
  callback = function()
    vim.keymap.set("n", "<C-n>", "<tab>")
    vim.keymap.set("n", "<C-p>", "<S-tab>")
  end,
})

vim.keymap.set("n", "L", h.keys.vim_cmd_cb "bnext", { desc = "Next buffer", })
vim.keymap.set("n", "H", h.keys.vim_cmd_cb "bprev", { desc = "Previous buffer", })

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top
vim.g.netrw_liststyle = 3 -- tree view
vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })
vim.opt.path:append "**"                   -- search in subfolder
vim.keymap.set("n", "<C-p>", h.keys.vim_cmd_cb "wq!")
vim.keymap.set({ "i", }, "<C-s>", "<C-n>") -- autocomplete
vim.cmd "nnoremap <leader>lg :grep<space>"
vim.cmd "nnoremap <leader>la :grep<space>"
vim.keymap.set({ "c", }, "/", function()
  if vim.fn.wildmenumode() == 1 then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })
