local MiniTest = require "mini.test"

local M = {}

--- @class MockCall
--- @field name string
--- @field args any[]

--- @param target table<string, any>
--- @param overrides table<string, function>
--- @param store_name string?
M.mock_child = function(target, overrides, store_name)
  local originals = {}
  local calls = {}
  for name, replacement in pairs(overrides) do
    originals[name] = target[name]
    --- @param ... any
    rawset(target, name, function(...)
      local args = {}
      for index = 1, select("#", ...) do
        local arg = select(index, ...)
        if type(arg) == "function" then
          arg = "<function>"
        end
        args[index] = arg
      end
      table.insert(calls, { name = name, args = args })
      return replacement(...)
    end)
  end

  if store_name ~= nil then
    _G[store_name] = calls
  end

  return calls, originals
end

--- @param target table<string, any>
--- @param overrides table<string, function>
M.mock = function(target, overrides)
  local calls, originals = M.mock_child(target, overrides)

  MiniTest.finally(function()
    for name, original in pairs(originals) do
      rawset(target, name, original)
    end
  end)

  return calls
end

--- @param store_name string
--- @return MockCall[]
M.get_calls = function(child, store_name)
  return child.lua_get(("_G.%s"):format(store_name))
end

M.stub_notify = function()
  return require("tests._helpers").mock_child(vim, { notify = function() end }, "notifications")
end

M.expect_lines = MiniTest.new_expectation("buffer lines", function(child, expected)
  return vim.deep_equal(child.api.nvim_buf_get_lines(0, 0, -1, false), expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.api.nvim_buf_get_lines(0, 0, -1, false)),
    vim.inspect(expected)
  )
end)

M.expect_cursor = MiniTest.new_expectation("cursor position", function(child, expected)
  return vim.deep_equal(child.api.nvim_win_get_cursor(0), expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.api.nvim_win_get_cursor(0)),
    vim.inspect(expected)
  )
end)

M.expect_cmdline = MiniTest.new_expectation("command line", function(child, expected)
  return vim.deep_equal(child.lua_get [[vim.fn.getcmdline()]], expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.fn.getcmdline()]]),
    vim.inspect(expected)
  )
end)

M.expect_cmdline_cursor = MiniTest.new_expectation("command line cursor", function(child, expected)
  return vim.deep_equal(child.lua_get [[vim.fn.getcmdpos()]], expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.fn.getcmdpos()]]),
    vim.inspect(expected)
  )
end)

M.expect_eventually = MiniTest.new_expectation(
  "eventually matching value",
  function(get_value, expected)
    return vim.wait(1000, function()
      return vim.deep_equal(get_value(), expected)
    end)
  end,
  function(get_value, expected)
    return string.format(
      "Observed: %s\nExpected: %s",
      vim.inspect(get_value()),
      vim.inspect(expected)
    )
  end
)

M.make_temp_dir = function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  MiniTest.finally(function()
    vim.fn.delete(dir, "rf")
  end)

  return dir
end

--- @param relative_paths string[]
M.make_files = function(relative_paths)
  local dir = M.make_temp_dir()

  return vim.tbl_map(
    --- @param relative_path_arg string
    function(relative_path_arg)
      local path = vim.fs.joinpath(dir, relative_path_arg)
      vim.fn.mkdir(vim.fs.dirname(path), "p")
      vim.fn.writefile(vim.fn.range(1, 30), path)

      return path
    end,
    relative_paths
  )
end

-- Fixtures below are handed to `child.lua_func`, so they must not reference `M`
-- or any other upvalue.

--- @param lines string[]
M.open_file_buffer = function(lines)
  local path = vim.fn.tempname()
  vim.fn.writefile(lines, path)
  vim.cmd.edit { args = { path }, mods = { silent = true } }

  return path
end

--- @param path string
M.edit_file = function(path)
  vim.cmd.edit { args = { path }, mods = { silent = true } }
end

--- @param lines string[]?
M.open_buffer = function(lines)
  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf_id)
  if lines ~= nil then
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  end

  return buf_id
end

--- @param name string
M.open_named_buffer = function(name)
  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf_id, name)
  vim.api.nvim_set_current_buf(buf_id)

  return buf_id
end

--- @param lines string[]
--- @param cursor integer[]
M.open_scratch_buffer = function(lines, cursor)
  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, cursor)

  return buf_id
end

--- @param path string
--- @param line string
M.file_contains = function(path, line)
  --- @param line_arg string
  local lines = vim.tbl_map(function(line_arg)
    return (line_arg:gsub("%s+", " "))
  end, vim.fn.readfile(path))

  return vim.tbl_contains(lines, line)
end

--- @param contents string
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
