local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua [[require "shared.movements"]]
      child.o.lines = 30
    end,
    post_once = child.stop,
  },
}

local hundred_lines = vim.tbl_map(tostring, vim.fn.range(1, 100))

local expect_window_height = MiniTest.new_expectation("window height", function(expected)
  return child.lua_get [[vim.api.nvim_win_get_height(0)]] == expected
end, function(expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.api.nvim_win_get_height(0)]]),
    vim.inspect(expected)
  )
end)

T["<C-d>"] = MiniTest.new_set()

T["<C-d>"]["scrolls down half a page"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)
  expect_window_height(28)

  child.type_keys "<C-d>"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 14, 0 })
end

T["<C-d>"]["stops at the last line"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)
  child.api.nvim_win_set_cursor(0, { 95, 0 })

  child.type_keys "<C-d>"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 100, 0 })
end

T["<C-d>"]["does nothing when the window holds fewer than a half page"] = function()
  child.o.lines = 4
  child.lua_func(test_helpers.open_buffer, hundred_lines)
  expect_window_height(2)

  child.type_keys "<C-d>"

  test_helpers.expect_cursor(child, { 1, 0 })
end

T["<C-d>"]["scrolls in visual mode"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)

  child.type_keys("v", "<C-d>")

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 14, 0 })
  MiniTest.expect.equality(child.lua_get [[vim.fn.mode()]], "v")
end

T["<C-u>"] = MiniTest.new_set()

T["<C-u>"]["scrolls up half a page"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)
  child.api.nvim_win_set_cursor(0, { 30, 0 })
  expect_window_height(28)

  child.type_keys "<C-u>"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 17, 0 })
end

T["<C-u>"]["stops at the first line"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)
  child.api.nvim_win_set_cursor(0, { 2, 0 })

  child.type_keys "<C-u>"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 1, 0 })
end

T["L"] = MiniTest.new_set()

T["L"]["scrolls to the next paragraph break"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "b", "", "c" })

  child.type_keys "L"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 3, 0 })
end

T["L"]["stops at the last line when there is no paragraph break"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "b", "c" })

  child.type_keys "L"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 3, 0 })
end

T["L"]["does nothing on the last line"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "b", "c" })
  child.api.nvim_win_set_cursor(0, { 3, 0 })

  child.type_keys "L"

  test_helpers.expect_cursor(child, { 3, 0 })
end

T["H"] = MiniTest.new_set()

T["H"]["scrolls to the previous paragraph break"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "", "b", "c" })
  child.api.nvim_win_set_cursor(0, { 4, 0 })

  child.type_keys "H"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 2, 0 })
end

T["H"]["stops at the first line when there is no paragraph break"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "b", "c" })
  child.api.nvim_win_set_cursor(0, { 3, 0 })

  child.type_keys "H"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 1, 0 })
end

T["H"]["does nothing on the first line"] = function()
  child.lua_func(test_helpers.open_buffer, { "a", "b", "c" })

  child.type_keys "H"

  test_helpers.expect_cursor(child, { 1, 0 })
end

return T
