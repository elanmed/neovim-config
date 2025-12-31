local h = require "helpers"

vim.keymap.set("n", "<leader>f", ":edit ")
vim.keymap.set("n", "<leader>b", function()
  local buffers = vim.iter(vim.api.nvim_list_bufs())
      :filter(function(bufnr)
        local bname = vim.api.nvim_buf_get_name(bufnr)
        if bname == nil then return false end
        if bname == "" then return false end

        local is_loaded = vim.api.nvim_buf_is_loaded(bufnr)
        if not is_loaded then return false end

        local is_listed = vim.bo[bufnr].buflisted

        if not is_listed then return false end
        return true
      end)
      :totable()

  vim.ui.select(buffers, {
    format_item = function(bufnr)
      return vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(bufnr))
    end,
  }, function(bufnr)
    if bufnr == nil then return end
    vim.cmd.buffer(bufnr)
  end)
end)
vim.keymap.set("n", "<leader>l", function()
  local marks = vim.iter(vim.fn.getmarklist())
      :map(function(mark_entry)
        local name = mark_entry.mark:sub(2, 2)
        local lnum = mark_entry.pos[2]
        return { name = name, lnum = lnum, file = mark_entry.file, }
      end)
      :filter(function(mark)
        if not mark.name:match "[A-Z]" then return false end

        local normalized = vim.fs.normalize(mark.file)
        if not normalized then return false end

        if not vim.startswith(normalized, vim.fn.getcwd()) then return false end

        return true
      end)
      :totable()

  vim.ui.select(marks, {
    format_item = function(mark)
      return mark.name .. "|" .. vim.fs.relpath(vim.fn.getcwd(), mark.file)
    end,
  }, function(mark)
    if mark == nil then return end
    vim.cmd.edit(mark.file)
    vim.api.nvim_win_set_cursor(0, { mark.lnum, 0, })
  end)
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

    vim.keymap.set("n", "o", "%", { buffer = true, remap = true, })
    vim.keymap.set("n", "r", "R", { buffer = true, remap = true, })
    vim.keymap.set("n", "dd", "D", { buffer = true, remap = true, })
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

