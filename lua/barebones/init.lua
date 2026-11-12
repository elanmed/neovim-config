vim.o.pummaxwidth = vim.o.columns

vim.api.nvim_create_autocmd("FileType", {
  pattern = "directory",
  callback = function(ev)
    vim.bo[ev.buf].bufhidden = "delete"
    vim.keymap.set("n", "h", "<Plug>(nvim-dir-up)", { buffer = ev.buf })
    vim.keymap.set("n", "l", "<Plug>(nvim-dir-open)", { buffer = ev.buf })
  end,
})

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "directory" then
    vim.cmd.bdelete()
  else
    vim.cmd [[execute "normal \<Plug>(nvim-dir-up)"]]
  end
end)

local h = require "helpers"
if vim.fn.executable "fd" == h.vimscript_true then
  function _G.FdFindFiles(cmdarg)
    local fnames = vim.fn.systemlist(table.concat(h.fd_cmd, " "))
    return vim.fn.matchfuzzy(fnames, cmdarg, { matchseq = 1, limit = 100 })
  end

  vim.o.findfunc = "v:lua.FdFindFiles"
end
vim.keymap.set("n", "/", "/\\V", { desc = "/ without regex" })
vim.keymap.set("n", "K", "<C-w><C-]>", { desc = "Tags hover" })
vim.keymap.set("n", "<leader>f", ":find ", { desc = ":find" })
vim.keymap.set("n", "<leader>b", function()
  local buffers = vim
    .iter(vim.api.nvim_list_bufs())
    :filter(
      --- @param bufnr_arg integer
      function(bufnr_arg)
        local bname = vim.api.nvim_buf_get_name(bufnr_arg)
        if bname == nil then
          return false
        end
        if bname == "" then
          return false
        end

        local is_loaded = vim.api.nvim_buf_is_loaded(bufnr_arg)
        if not is_loaded then
          return false
        end

        local is_listed = vim.bo[bufnr_arg].buflisted
        if not is_listed then
          return false
        end

        return true
      end
    )
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
    if bufnr == nil then
      return
    end
    vim.cmd.buffer(bufnr)
  end)
end)
vim.keymap.set("n", "<leader>l", function()
  --- @class MarkEntry
  --- @field mark string
  --- @field pos integer[]
  --- @field file string
  --- @class Mark
  --- @field name string
  --- @field lnum integer
  --- @field file string
  --- @type MarkEntry[]
  local mark_entries = vim.fn.getmarklist()
  local marks = vim
    .iter(mark_entries)
    :map(
      --- @param mark_entry_arg MarkEntry
      function(mark_entry_arg)
        local name = mark_entry_arg.mark:sub(2, 2)
        local lnum = mark_entry_arg.pos[2]
        ---@diagnostic disable-next-line: missing-return-value
        return { name = name, lnum = lnum, file = mark_entry_arg.file }
      end
    )
    :filter(
      --- @param mark_arg Mark
      function(mark_arg)
        if mark_arg.name:match "[A-Z]" == nil then
          return false
        end

        local normalized = vim.fs.normalize(mark_arg.file)
        if normalized == nil then
          return false
        end

        local cwd = vim.uv.cwd()
        assert(cwd ~= nil)
        if vim.fs.relpath(cwd, normalized) == nil then
          return false
        end

        return true
      end
    )
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
    if mark == nil then
      return
    end
    vim.cmd.edit(mark.file)
    vim.api.nvim_win_set_cursor(0, { mark.lnum, 0 })
  end)
end)

vim.keymap.set("n", "s", function()
  if vim.bo.readonly then
    return vim.notify("Aborting, readonly", vim.log.levels.WARN)
  end

  if vim.bo.buftype ~= "" then
    return vim.notify("Aborting, buftype is not normal", vim.log.levels.WARN)
  end

  vim.cmd.write()
end)
