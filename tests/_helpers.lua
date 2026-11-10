local MiniTest = require "mini.test"

local Helpers = {}

Helpers.write_temp_file = function(contents)
  local path = vim.fn.tempname()
  MiniTest.finally(function()
    vim.fn.delete(path)
  end)

  local file = assert(io.open(path, "wb"))
  file:write(contents)
  file:close()

  return path
end

return Helpers
