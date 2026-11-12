local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local stub_preview = function()
  _G.preview_close_calls = 0
  vim.api.nvim_create_user_command("QuickfixPreviewClosePreview", function()
    _G.preview_close_calls = _G.preview_close_calls + 1
  end, {})
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(stub_preview)
      child.lua [[require "feature_complete.vim_plugins.quickfix_list"]]
    end,
    post_once = child.stop,
  },
}

local expect_preview_close_count = MiniTest.new_expectation(
  "preview close count",
  function(expected)
    return child.lua_get [[_G.preview_close_calls]] == expected
  end,
  function(expected)
    return string.format(
      "Observed: %s\nExpected: %s",
      vim.inspect(child.lua_get [[_G.preview_close_calls]]),
      vim.inspect(expected)
    )
  end
)

T["<leader>x"] = MiniTest.new_set()

T["<leader>x"]["clears every quickfix list"] = function()
  child.lua_func(test_helpers.seed_quickfix_lists)
  child.cmd "silent copen"

  child.type_keys "\\x"

  MiniTest.expect.equality(child.lua_func(test_helpers.get_quickfix_titles), {})
  expect_preview_close_count(1)
end

T["<leader>d"] = MiniTest.new_set()

T["<leader>d"]["clears the current list and drops it from the history"] = function()
  child.lua_func(test_helpers.seed_quickfix_lists)
  child.cmd "silent copen"

  child.type_keys "\\d"

  MiniTest.expect.equality(child.lua_func(test_helpers.get_quickfix_titles), { "first" })
  expect_preview_close_count(1)
end

T["<leader>d"]["closes the quickfix window when no list is left"] = function()
  child.lua_func(test_helpers.seed_quickfix_list)
  child.cmd "silent copen"

  child.type_keys "\\d"

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  MiniTest.expect.equality(child.lua_func(test_helpers.get_quickfix_titles), {})
  expect_preview_close_count(1)
end

return T
