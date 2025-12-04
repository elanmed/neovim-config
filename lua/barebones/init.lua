local h = require "helpers"
local fzf = require "shared.fzf"

vim.keymap.set("n", "<leader>f", function()
  fzf.fzf {
    source = "fd --hidden --type f --exclude .git --exclude node_modules --exclude dist",
    height = "half",
    options = h.tbl.extend(fzf.default_opts, fzf.multi_select_opts),
    sinklist = function(entries)
      for _, entry in ipairs(entries) do
        vim.cmd.edit(entry)
      end
    end,
  }
end)

vim.keymap.set("n", "s", function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return h.notify.error "Aborting"
  end
  vim.cmd.write()
end)

vim.g.netrw_altfile = 1
vim.g.netrw_localcopydircmd = "cp -r"
-- bottom right
vim.g.netrw_preview = 0
vim.g.netrw_alto = 0

vim.keymap.set("n", "<C-f>", function()
  local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  vim.cmd.Explore(dirname)

  if vim.api.nvim_get_current_line() == "../" then
    vim.cmd.normal "gh"
  end
end, { desc = "Toggle netrw, focusing the current dir", })

vim.api.nvim_create_autocmd("BufModifiedSet", {
  callback = function()
    if vim.bo.filetype ~= "netrw" then return end

    vim.opt_local.relativenumber = true

    vim.keymap.set("n", "h", "-", { buffer = true, remap = true, })
    vim.keymap.set("n", "l", function()
      local line = vim.api.nvim_get_current_line()
      if vim.endswith(line, "/") then
        return "<cr>"
      end
    end, { expr = true, buffer = true, remap = true, })

    vim.keymap.set("n", "o", "%<cmd>write<cr>", { buffer = true, remap = true, })
    vim.keymap.set("n", "r", "R", { buffer = true, remap = true, })
    vim.keymap.set("n", "P", "<C-w>z", { buffer = true, remap = true, })
    vim.keymap.set("n", "<C-f>", vim.cmd.bdelete, { buffer = true, })

    vim.keymap.set("n", "mp", function()
      h.notify.doing("Target dir: " .. vim.b.netrw_curdir)
    end, { buffer = true, })

    vim.keymap.set("n", "ya", function()
      local line = vim.api.nvim_get_current_line()
      local abs_path = vim.fs.joinpath(vim.fn.getcwd(), vim.fn.expand "%", line)
      h.utils.set_and_rotate(abs_path)
    end, { buffer = true, })

    vim.keymap.set("n", "yr", function()
      local line = vim.api.nvim_get_current_line()
      local rel_path = vim.fs.joinpath(vim.fn.expand "%", line)
      h.utils.set_and_rotate(rel_path)
    end, { buffer = true, })
  end,
  group = vim.api.nvim_create_augroup("netrw", { clear = false, }),
})

