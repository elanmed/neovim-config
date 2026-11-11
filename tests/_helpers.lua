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
