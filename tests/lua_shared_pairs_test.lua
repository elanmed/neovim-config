local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua [[require "shared.pairs"]]
    end,
    post_once = child.stop,
  },
}

local pair_shortcuts = {
  { keys = ";u", pair = "()" },
  { keys = ";v", pair = "[]" },
  { keys = ";c", pair = "{}" },
  { keys = ";a", pair = "<>" },
  { keys = ";d", pair = [[""]] },
  { keys = ";s", pair = "''" },
  { keys = ";t", pair = "``" },
}

local type_in_insert_mode = function(keys)
  child.cmd "enew!"
  child.cmd "startinsert"
  child.type_keys(keys)
end

local type_in_command_line = function(keys)
  child.type_keys("<Esc>", ":", keys)
end

T["pair shortcuts"] = MiniTest.new_set()

T["pair shortcuts"]["inserts the pair with the cursor in the middle"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_insert_mode(shortcut.keys)

    test_helpers.expect_lines(child, { shortcut.pair })
    test_helpers.expect_cursor(child, { 1, 1 })
  end
end

T["pair shortcuts"]["inserts the pair with the command line cursor in the middle"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_command_line(shortcut.keys)

    test_helpers.expect_cmdline(child, shortcut.pair)
    test_helpers.expect_cmdline_cursor(child, 2)
  end
end

T["<bs>"] = MiniTest.new_set()

T["<bs>"]["removes the pair the cursor sits in the middle of"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_insert_mode { shortcut.keys, "<bs>" }

    test_helpers.expect_lines(child, { "" })
    test_helpers.expect_cursor(child, { 1, 0 })
  end
end

T["<bs>"]["removes the pair the cursor sits after"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_insert_mode { shortcut.keys, "<Right>", "<bs>" }

    test_helpers.expect_lines(child, { "" })
    test_helpers.expect_cursor(child, { 1, 0 })
  end
end

T["<bs>"]["removes the pair the command line cursor sits in the middle of"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_command_line { shortcut.keys, "<bs>" }

    test_helpers.expect_cmdline(child, "")
    test_helpers.expect_cmdline_cursor(child, 1)
  end
end

T["<bs>"]["removes the pair the command line cursor sits after"] = function()
  for _, shortcut in ipairs(pair_shortcuts) do
    type_in_command_line { shortcut.keys, "<Right>", "<bs>" }

    test_helpers.expect_cmdline(child, "")
    test_helpers.expect_cmdline_cursor(child, 1)
  end
end

T["<bs>"]["removes only the preceding character of ordinary text"] = function()
  type_in_insert_mode { "abc", "<bs>" }

  test_helpers.expect_lines(child, { "ab" })
  test_helpers.expect_cursor(child, { 1, 2 })
end

T["<bs>"]["removes only the preceding character when the neighbours are not a pair"] = function()
  type_in_insert_mode { "((a))", "<bs>" }

  test_helpers.expect_lines(child, { "((a)" })
  test_helpers.expect_cursor(child, { 1, 4 })
end

T["<bs>"]["does nothing at the start of a line"] = function()
  type_in_insert_mode { ";u", "<Left>", "<bs>" }

  test_helpers.expect_lines(child, { "()" })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["<bs>"]["removes only the preceding character in the command line"] = function()
  type_in_command_line { "abc", "<bs>" }

  test_helpers.expect_cmdline(child, "ab")
  test_helpers.expect_cmdline_cursor(child, 3)
end

T["<C-d>"] = MiniTest.new_set()

T["<C-d>"]["removes the preceding character in insert mode"] = function()
  type_in_insert_mode { "abc", "<C-d>" }

  test_helpers.expect_lines(child, { "ab" })
  test_helpers.expect_cursor(child, { 1, 2 })
end

T["<C-d>"]["removes the preceding character in the command line"] = function()
  type_in_command_line { "abc", "<C-d>" }

  test_helpers.expect_cmdline(child, "ab")
  test_helpers.expect_cmdline_cursor(child, 3)
end

T["<C-d>"]["removes only one character of the pair, unlike <bs>"] = function()
  type_in_insert_mode { ";u", "<C-d>" }

  test_helpers.expect_lines(child, { ")" })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["<C-d>"]["removes only one character of a command line pair, unlike <bs>"] = function()
  type_in_command_line { ";u", "<C-d>" }

  test_helpers.expect_cmdline(child, ")")
  test_helpers.expect_cmdline_cursor(child, 1)
end

return T
