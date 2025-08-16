local h = require "helpers"

-- https://github.com/neovim/neovim/issues/18000#issuecomment-1088700694
-- vim.opt.wildchar = ("<C-n>"):byte()
vim.cmd "set wildchar=<C-n>"

vim.opt.scrolloff = 999

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top
vim.g.netrw_liststyle = 3

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<leader>f", ":find<space>")

vim.opt.path:append "**" -- search in subdirectories
vim.keymap.set("n", "<leader>a", ":grep<space>")
vim.keymap.set("n", "<leader>h", ":help<space>")
vim.keymap.set("n", "<leader>zm", h.keys.vim_cmd_cb "marks")
vim.keymap.set("n", "<leader>z;", h.keys.vim_cmd_cb "history")
vim.keymap.set("n", "<leader>b", ":buffer<space>")
vim.keymap.set("n", "<C-n>", h.keys.vim_cmd_cb "cnext")
vim.keymap.set("n", "<C-p>", h.keys.vim_cmd_cb "cprev")

vim.keymap.set("c", "/", function()
  if vim.fn.wildmenumode() == 1 then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })

-- https://yobibyte.github.io/vim.html
vim.keymap.set("n", "<space>ze", function()
  vim.ui.input({ prompt = "$ ", }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd "vnew"
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(cmd))
    end
  end)
end)
