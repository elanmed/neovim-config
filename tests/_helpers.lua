local MiniTest = require "mini.test"

local M = {}

M.mock = function(target, overrides)
  local originals = {}
  local calls = {}
  for name, replacement in pairs(overrides) do
    originals[name] = target[name]
    rawset(target, name, function(...)
      local args = vim.tbl_filter(function(arg)
        return type(arg) ~= "function"
      end, { ... })
      table.insert(calls, { name = name, args = args })
      return replacement(...)
    end)
  end

  MiniTest.finally(function()
    for name, original in pairs(originals) do
      rawset(target, name, original)
    end
  end)

  return calls
end

M.make_temp_dir = function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  MiniTest.finally(function()
    vim.fn.delete(dir, "rf")
  end)

  return dir
end

M.chdir_to_sandbox = function()
  local original_cwd = vim.fn.getcwd()
  local sandbox_dir = M.make_temp_dir()
  vim.fn.chdir(sandbox_dir)
  MiniTest.finally(function()
    vim.fn.chdir(original_cwd)
  end)

  return sandbox_dir
end

M.open_file_buffer = function(lines)
  local path = vim.fs.joinpath(M.make_temp_dir(), "test.txt")
  vim.fn.writefile(lines, path)
  vim.cmd.edit { args = { path }, mods = { silent = true } }
  MiniTest.finally(function()
    vim.cmd.bwipeout { bang = true }
  end)

  return path
end

M.open_scratch_buffer = function(lines, cursor)
  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, cursor)
  MiniTest.finally(function()
    vim.api.nvim_buf_delete(buf_id, { force = true })
  end)

  return buf_id
end

M.file_contains = function(path, line)
  local lines = vim.tbl_map(function(line_arg)
    return (line_arg:gsub("%s+", " "))
  end, vim.fn.readfile(path))

  return vim.tbl_contains(lines, line)
end

M.write_temp_file = function(contents)
  local path = vim.fn.tempname()
  MiniTest.finally(function()
    vim.fn.delete(path)
  end)

  local file = assert(io.open(path, "wb"))
  file:write(contents)
  file:close()

  return path
end

return M
