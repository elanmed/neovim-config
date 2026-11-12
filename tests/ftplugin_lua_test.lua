local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(function()
        local path = vim.fn.tempname() .. ".lua"
        vim.fn.writefile({}, path)
        vim.cmd.edit { args = { path }, mods = { silent = true } }
      end)
    end,
    post_once = child.stop,
  },
}

--- @param lines string[]
--- @param row integer
local press_enter_after = function(lines, row)
  child.lua_func(
    --- @param lines_arg string[]
    --- @param row_arg integer
    function(lines_arg, row_arg)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines_arg)
      vim.api.nvim_win_set_cursor(0, { row_arg, 0 })
    end,
    lines,
    row
  )
  child.type_keys("A", "<CR>")
end

T["<Cr>"] = MiniTest.new_set()

T["<Cr>"]["adds end after a named local function"] = function()
  press_enter_after({ "local function name()" }, 1)

  test_helpers.expect_lines(child, { "local function name()", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["adds end after a named function with parameters"] = function()
  press_enter_after({ "function M.name(a, b)" }, 1)

  test_helpers.expect_lines(child, { "function M.name(a, b)", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["adds end after a method definition"] = function()
  press_enter_after({ "function M:name()" }, 1)

  test_helpers.expect_lines(child, { "function M:name()", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["adds end after an anonymous function"] = function()
  press_enter_after({ "local f = function()" }, 1)

  test_helpers.expect_lines(child, { "local f = function()", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["adds end at the indent of the block"] = function()
  press_enter_after({ "\tlocal function inner()" }, 1)

  test_helpers.expect_lines(child, { "\tlocal function inner()", "\t\t", "\tend" })
  test_helpers.expect_cursor(child, { 2, 2 })
end

T["<Cr>"]["adds end after a then block"] = function()
  press_enter_after({ "if x then" }, 1)

  test_helpers.expect_lines(child, { "if x then", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["adds end after a do block"] = function()
  press_enter_after({ "for i = 1, 10 do" }, 1)

  test_helpers.expect_lines(child, { "for i = 1, 10 do", "\t", "end" })
  test_helpers.expect_cursor(child, { 2, 1 })
end

T["<Cr>"]["inserts a plain newline for other lines"] = function()
  press_enter_after({ "local x = 1" }, 1)

  test_helpers.expect_lines(child, { "local x = 1", "" })
  test_helpers.expect_cursor(child, { 2, 0 })
end

T["<Cr>"]["does not add end to a finished block"] = function()
  press_enter_after({ "function M.name() end" }, 1)

  test_helpers.expect_lines(child, { "function M.name() end", "" })
  test_helpers.expect_cursor(child, { 2, 0 })
end

return T
