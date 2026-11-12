local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua [[require "shared.keymaps"]]
    end,
    post_once = child.stop,
  },
}

local open_folded_buffer = function()
  local lines = {}
  for index = 1, 20 do
    table.insert(lines, "line " .. index)
  end

  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.wo.foldmethod = "manual"
  vim.cmd "2,4fold"
  vim.cmd "10,12fold"
  vim.cmd "16,18fold"
  vim.cmd "normal! zM"
  vim.cmd "normal! gg"
end

local open_unfolded_buffer = function()
  local lines = {}
  for index = 1, 20 do
    table.insert(lines, "line " .. index)
  end

  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.wo.foldmethod = "manual"
  vim.cmd "2,4fold"
  vim.cmd "10,12fold"
  vim.cmd "normal! zR"
  vim.cmd "normal! gg"
end

local open_named_buffer_at_position = function()
  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf_id, "/root/one/foo.lua")
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { "", "", "abc" })
  vim.api.nvim_win_set_cursor(0, { 3, 2 })
end

--- @param cwd string?
local stub_cwd = function(cwd)
  require("tests._helpers").mock_child(vim.uv, {
    cwd = function()
      return cwd
    end,
  })
end

local stub_missing_relpath = function()
  require("tests._helpers").mock_child(vim.fs, {
    relpath = function()
      return nil
    end,
  })
end

local seed_quickfix_list = function()
  vim.fn.setqflist({}, "f")
  vim.fn.setqflist({}, " ", { title = "first", items = { { text = "first item", valid = 1 } } })
end

local get_quickfix_texts = function()
  local texts = {}
  for index = 1, vim.fn.getqflist({ nr = "$" }).nr do
    table.insert(
      texts,
      vim.tbl_map(
        --- @param item_arg vim.quickfix.entry
        function(item_arg)
          return item_arg.text
        end,
        vim.fn.getqflist({ nr = index, items = 0 }).items
      )
    )
  end

  return texts
end

local expect_unnamed_register = MiniTest.new_expectation("unnamed register", function(expected)
  return child.lua_get [[vim.fn.getreg('"')]] == expected
end, function(expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.fn.getreg('"')]]),
    vim.inspect(expected)
  )
end)

local close_tag = function(line)
  child.lua_func(test_helpers.open_buffer, { line })
  child.type_keys("$", "a", "<C-g>")
end

T["<C-g>"] = MiniTest.new_set()

T["<C-g>"]["inserts the closing tag after the tag left of the cursor"] = function()
  close_tag "<div>"

  test_helpers.expect_lines(child, { "<div></div>" })
  test_helpers.expect_cursor(child, { 1, 5 })
end

T["<C-g>"]["uses only the tag name of a tag with attributes"] = function()
  close_tag "<div class=\"x\">"

  test_helpers.expect_lines(child, { "<div class=\"x\"></div>" })
  test_helpers.expect_cursor(child, { 1, 15 })
end

T["<C-g>"]["closes an empty tag"] = function()
  close_tag "<>"

  test_helpers.expect_lines(child, { "<></>" })
  test_helpers.expect_cursor(child, { 1, 2 })
end

T["<C-g>"]["uses the tag closest to the cursor"] = function()
  close_tag "<a><b>"

  test_helpers.expect_lines(child, { "<a><b></b>" })
  test_helpers.expect_cursor(child, { 1, 6 })
end

T["<C-g>"]["closes a tag that text follows"] = function()
  close_tag "<div>text"

  test_helpers.expect_lines(child, { "<div>text</div>" })
  test_helpers.expect_cursor(child, { 1, 9 })
end

T["<C-g>"]["warns when there is no tag left of the cursor"] = function()
  child.lua_func(test_helpers.stub_notify)

  close_tag "no tags here"

  test_helpers.expect_lines(child, { "no tags here" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No matching tag", vim.log.levels.WARN } },
  })
end

T["<C-g>"]["errors when the tag has no name"] = function()
  child.lua_func(test_helpers.stub_notify)

  close_tag "< div>"

  test_helpers.expect_lines(child, { "< div>" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Invalid tag name", vim.log.levels.ERROR } },
  })
end

T["zj"] = MiniTest.new_set()

T["zj"]["jumps to the next closed fold"] = function()
  child.lua_func(open_folded_buffer)

  child.type_keys "zj"

  test_helpers.expect_cursor(child, { 2, 0 })
end

T["zj"]["jumps past the current closed fold"] = function()
  child.lua_func(open_folded_buffer)
  child.type_keys "zj"

  child.type_keys "zj"

  test_helpers.expect_cursor(child, { 10, 0 })
end

T["zk"] = MiniTest.new_set()

T["zk"]["jumps to the previous closed fold"] = function()
  child.lua_func(open_folded_buffer)
  child.type_keys "zj"
  child.type_keys "zj"

  child.type_keys "zk"

  test_helpers.expect_cursor(child, { 4, 0 })
end

T["zj"]["restores the cursor when no fold is closed"] = function()
  child.lua_func(open_unfolded_buffer)

  child.type_keys "zj"

  test_helpers.expect_cursor(child, { 1, 0 })
end

T["<leader>yc"] = MiniTest.new_set()

T["<leader>yc"]["comments the current line and puts the original below"] = function()
  child.lua_func(test_helpers.open_buffer, { "abc", "def" })
  child.bo.commentstring = "-- %s"

  child.type_keys "\\yc"

  test_helpers.expect_lines(child, { "-- abc", "abc", "def" })
  test_helpers.expect_cursor(child, { 2, 0 })
end

T["<leader>yc"]["comments the selection and puts the original below"] = function()
  child.lua_func(test_helpers.open_buffer, { "abc", "def", "ghi" })
  child.bo.commentstring = "-- %s"

  child.type_keys("Vj", "\\yc")

  test_helpers.expect_lines(child, { "-- abc", "-- def", "abc", "def", "ghi" })
  test_helpers.expect_cursor(child, { 3, 0 })
end

T["<leader>yp"] = MiniTest.new_set()

T["<leader>yp"]["puts the selection below"] = function()
  child.lua_func(test_helpers.open_buffer, { "abc", "def", "ghi" })

  child.type_keys("Vj", "\\yp")

  test_helpers.expect_lines(child, { "abc", "def", "abc", "def", "ghi" })
  test_helpers.expect_cursor(child, { 3, 0 })
end

T["<leader>ya"] = MiniTest.new_set()

T["<leader>ya"]["sets the registers to the absolute path"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\ya"

  expect_unnamed_register "/root/one/foo.lua"
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    {
      name = "notify",
      args = { "Setting the unnamed and + registers to: `/root/one/foo.lua`", vim.log.levels.INFO },
    },
  })
end

T["<leader>ye"] = MiniTest.new_set()

T["<leader>ye"]["sets the registers to the relative path with the position"] = function()
  child.lua_func(open_named_buffer_at_position)
  child.lua_func(stub_cwd, "/root/one")
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\ye"

  expect_unnamed_register "foo.lua|3|3\n\n"
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    {
      name = "notify",
      args = { "Setting the unnamed and + registers to: `foo.lua|3|3\n\n`", vim.log.levels.INFO },
    },
  })
end

T["<leader>ye"]["warns when the working directory is unavailable"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, nil)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\ye"

  expect_unnamed_register ""
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "cwd is nil", vim.log.levels.WARN } },
  })
end

T["<leader>ye"]["warns when the relative path is unavailable"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, "/root/one")
  child.lua_func(stub_missing_relpath)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\ye"

  expect_unnamed_register ""
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "relpath is nil", vim.log.levels.WARN } },
  })
end

T["<leader>yr"] = MiniTest.new_set()

T["<leader>yr"]["sets the registers to the relative path"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, "/root/one")
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\yr"

  expect_unnamed_register "foo.lua"
end

T["<leader>yr"]["warns when the working directory is unavailable"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, nil)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\yr"

  expect_unnamed_register ""
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "cwd is nil", vim.log.levels.WARN } },
  })
end

T["<leader>yr"]["warns when the relative path is unavailable"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, "/root/one")
  child.lua_func(stub_missing_relpath)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\yr"

  expect_unnamed_register ""
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "relpath is nil", vim.log.levels.WARN } },
  })
end

T["<leader>yf"] = MiniTest.new_set()

T["<leader>yf"]["duplicates the current quickfix list"] = function()
  child.lua_func(seed_quickfix_list)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\yf"

  MiniTest.expect.equality(child.lua_func(get_quickfix_texts), {
    { "first item" },
    { "first item" },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Duplicated the current quickfix list", vim.log.levels.INFO } },
  })
end

return T
