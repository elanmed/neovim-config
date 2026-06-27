vim.o.pummaxwidth = vim.o.columns

if vim.fn.executable "fd" == 1 then
  function _G.FdFindFiles(cmdarg)
    local fnames = vim.fn.systemlist(require "helpers".fd_cmd)
    return vim.fn.matchfuzzy(fnames, cmdarg, { matchseq = 1, limit = 100, })
  end

  vim.o.findfunc = "v:lua.FdFindFiles"
end
vim.keymap.set("n", "/", "/\\V", { desc = "/ without regex", })
vim.keymap.set("n", "K", "<C-w><C-]>", { desc = "Tags hover", })
vim.keymap.set("n", "<leader>f", ":find ", { desc = ":find", })
vim.keymap.set("n", "<leader>b", function()
  local buffers =
      vim.iter(vim.api.nvim_list_bufs())
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
      local cwd = vim.uv.cwd()
      assert(cwd ~= nil)

      local rel_path = vim.fs.relpath(cwd, vim.api.nvim_buf_get_name(bufnr))
      if rel_path == nil then
        vim.notify("relpath is nil", vim.log.levels.WARN)
        return ""
      end

      return rel_path
    end,
  }, function(bufnr)
    if bufnr == nil then return end
    vim.cmd.buffer(bufnr)
  end)
end)
vim.keymap.set("n", "<leader>l", function()
  local marks =
      vim.iter(vim.fn.getmarklist())
      :map(function(mark_entry)
        local name = mark_entry.mark:sub(2, 2)
        local lnum = mark_entry.pos[2]
        return { name = name, lnum = lnum, file = mark_entry.file, }
      end)
      :filter(function(mark)
        if mark.name:match "[A-Z]" == nil then return false end

        local normalized = vim.fs.normalize(mark.file)
        if normalized == nil then return false end

        local cwd = vim.uv.cwd()
        assert(cwd ~= nil)
        if not vim.startswith(normalized, cwd) then return false end

        return true
      end)
      :totable()

  vim.ui.select(marks, {
    format_item = function(mark)
      local cwd = vim.uv.cwd()
      assert(cwd ~= nil)
      local rel_path = vim.fs.relpath(cwd, mark.file)
      if rel_path == nil then
        return ""
      end

      return mark.name .. "|" .. rel_path
    end,
  }, function(mark)
    if mark == nil then return end
    vim.cmd.edit(mark.file)
    vim.api.nvim_win_set_cursor(0, { mark.lnum, 0, })
  end)
end)
vim.keymap.set("n", "s", function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return vim.notify("Aborting", vim.log.levels.ERROR)
  end
  vim.cmd.write()
end)
