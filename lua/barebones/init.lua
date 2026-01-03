vim.o.pummaxwidth = vim.o.columns

if vim.fn.executable "fd" == 1 then
  function _G.FdFindFiles(cmdarg)
    local fnames = vim.fn.systemlist(require "helpers".fd_cmd)
    return vim.fn.matchfuzzy(fnames, cmdarg, { matchseq = 1, limit = 100, })
  end

  vim.o.findfunc = "v:lua.FdFindFiles"
end
vim.keymap.set("n", "<leader>f", ":find ", { desc = ":find", })
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
    return require "helpers".notify.error "Aborting"
  end
  vim.cmd.write()
end)

local tree
--- @class TreeOpts
--- @field _dir string
--- @field _bufnr number
--- @param opts TreeOpts
tree = function(opts)
  --- @class Line
  --- @field abs_path string
  --- @field rel_path string
  --- @field type "file"|"directory"

  local cwd = vim.fn.getcwd()

  --- @type Line[]
  local lines = {}
  for name, type in vim.fs.dir(opts._dir) do
    local abs_path = vim.fs.normalize(vim.fs.joinpath(opts._dir, name))
    --- @type Line
    local line = {
      abs_path = abs_path,
      rel_path = vim.fs.relpath(cwd, abs_path) or "",
      type = type,
    }
    table.insert(lines, line)
  end

  opts._bufnr = (function()
    if vim.api.nvim_buf_is_valid(opts._bufnr) then
      return opts._bufnr
    end
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].bufhidden = "delete"
    vim.api.nvim_win_set_buf(0, bufnr)
    return bufnr
  end)()
  vim.wo.spell = false
  vim.api.nvim_buf_set_name(opts._bufnr, vim.fs.joinpath(vim.fs.basename(opts._dir), "/"))

  local formatted_lines = vim.iter(lines)
      :map(function(line)
        if line.type == "directory" then
          return vim.fs.joinpath(line.rel_path, "/")
        end
        return line.rel_path
      end)
      :totable()

  vim.bo[opts._bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(opts._bufnr, 0, -1, false, formatted_lines)
  vim.bo[opts._bufnr].modifiable = false

  --- @param alt_bufnr number
  local function set_alt_bufnr(alt_bufnr)
    if vim.api.nvim_buf_is_valid(alt_bufnr) then
      vim.fn.setreg("#", alt_bufnr)
    end
  end

  vim.keymap.set("n", "<cr>", function()
    local line = lines[vim.fn.line "."]
    if not line then return end

    if line.type == "file" then
      local alt_bufnr = vim.fn.bufnr "#"
      vim.cmd.edit(line.abs_path)
      set_alt_bufnr(alt_bufnr)
      return
    elseif line.type == "directory" then
      local alt_bufnr = vim.fn.bufnr "#"
      tree { _dir = line.abs_path, _bufnr = opts._bufnr, }
      set_alt_bufnr(alt_bufnr)
    end
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "l", function()
    local line = lines[vim.fn.line "."]
    if not line then return end

    if line.type ~= "directory" then return end
    local alt_bufnr = vim.fn.bufnr "#"
    tree { _dir = line.abs_path, _bufnr = opts._bufnr, }
    set_alt_bufnr(alt_bufnr)
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "h", function()
    local line = lines[vim.fn.line "."]
    if not line then return end
    local alt_bufnr = vim.fn.bufnr "#"
    tree { _dir = vim.fs.dirname(opts._dir), _bufnr = opts._bufnr, }
    set_alt_bufnr(alt_bufnr)
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "yr", function()
    local line = lines[vim.fn.line "."]
    if not line then return end
    require "helpers".utils.set_and_rotate(line.rel_path)
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "ya", function()
    local line = lines[vim.fn.line "."]
    if not line then return end
    require "helpers".utils.set_and_rotate(line.abs_path)
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "yb", function()
    local line = lines[vim.fn.line "."]
    if not line then return end
    require "helpers".utils.set_and_rotate(vim.fs.basename(line.abs_path))
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "e", function()
    local alt_bufnr = vim.fn.bufnr "#"
    tree { _dir = opts._dir, _bufnr = opts._bufnr, }
    set_alt_bufnr(alt_bufnr)
    require "helpers".notify.doing "Refreshed tree"
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "<C-f>", function()
    local alt_bufnr = vim.fn.bufnr "#"
    vim.cmd.bdelete(opts._bufnr)
    set_alt_bufnr(alt_bufnr)
  end, { buffer = opts._bufnr, })

  vim.keymap.set("n", "<C-^>", "<nop>", { buffer = opts._bufnr, })
  vim.keymap.set("n", "<C-o>", "<nop>", { buffer = opts._bufnr, })
  vim.keymap.set("n", "<C-i>", "<nop>", { buffer = opts._bufnr, })
end

vim.keymap.set("n", "<C-f>", function()
  local alt_bufnr = vim.fn.bufnr "#"
  tree {
    _dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    _bufnr = -1,
  }
  if vim.api.nvim_buf_is_valid(alt_bufnr) then
    vim.fn.setreg("#", alt_bufnr)
  end
end)
