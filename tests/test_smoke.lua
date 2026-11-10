local MiniTest = require "mini.test"
local T = MiniTest.new_set()

T["smoke"] = function()
  MiniTest.expect.equality(true, true)
end

return T
