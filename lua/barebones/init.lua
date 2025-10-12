local h = require "helpers"
local fzf = require "shared.fzf"

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    while vim.bo.filetype == "netrw" do
      vim.cmd "bdelete"
    end
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<leader>f", function()
  fzf.fzf {
    source = "fd --hidden --type f --exclude .git --exclude node_modules --exclude dist",
    height = "half",
    options = h.tbl.extend(fzf.default_opts, fzf.multi_select_opts),
    sinklist = function(entries)
      for _, entry in ipairs(entries) do
        vim.cmd("edit " .. entry)
      end
    end,
  }
end)
