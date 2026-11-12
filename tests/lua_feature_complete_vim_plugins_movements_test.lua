local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local stub_marks = function()
  local helpers = require "tests._helpers"

  local marks = {
    char_sets = {
      local_marks = "abcdefghijklmnopqrstuvwxyz",
      global_marks = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    },
  }
  package.loaded.marks = marks
  helpers.mock_child(marks, { refresh_signs = function() end }, "marks_calls")
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(stub_marks)
      child.lua [[require "feature_complete.vim_plugins.movements"]]
    end,
    post_once = child.stop,
  },
}

local expect_mark = MiniTest.new_expectation("mark", function(mark, expected)
  return vim.deep_equal(child.api.nvim_buf_get_mark(0, mark), expected)
end, function(mark, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.api.nvim_buf_get_mark(0, mark)),
    vim.inspect(expected)
  )
end)

T["<leader>mt"] = MiniTest.new_set()

T["<leader>mt"]["marks both ends of the first jump and refreshes the signs"] = function()
  child.lua_func(test_helpers.open_buffer, { "local t = {", "  a = 1,", "}" })
  child.api.nvim_win_set_cursor(0, { 1, 10 })

  child.type_keys "\\mt"

  expect_mark("y", { 1, 10 })
  expect_mark("z", { 3, 0 })
  test_helpers.expect_cursor(child, { 1, 10 })
  MiniTest.expect.equality(test_helpers.get_calls(child, "marks_calls"), {
    { name = "refresh_signs", args = {} },
  })
end

T["<leader>mt"]["marks a jump that stays on the same line"] = function()
  child.lua_func(test_helpers.open_buffer, { "f(a, b)" })
  child.api.nvim_win_set_cursor(0, { 1, 1 })

  child.type_keys "\\mt"

  expect_mark("y", { 1, 1 })
  expect_mark("z", { 1, 6 })
  test_helpers.expect_cursor(child, { 1, 1 })
  MiniTest.expect.equality(test_helpers.get_calls(child, "marks_calls"), {
    { name = "refresh_signs", args = {} },
  })
end

return T
