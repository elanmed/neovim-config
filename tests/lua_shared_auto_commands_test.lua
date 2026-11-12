local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local stub_timers = function()
  local helpers = require "tests._helpers"

  _G.timer_callbacks = {}
  helpers.mock_child(vim.fn, {
    timer_start = function(delay_arg, callback_arg)
      table.insert(_G.timer_callbacks, { delay = delay_arg, callback = callback_arg })

      return #_G.timer_callbacks
    end,
    timer_stop = function() end,
  }, "timer_calls")
end

local stub_ctags = function()
  local helpers = require "tests._helpers"
  local h = require "helpers"
  local cb = h.async.cb

  _G.finished_ctags_runs = 0
  helpers.mock_child(vim, { system = function() end }, "system_calls")
  helpers.mock_child(h.async, {
    cb = function(callback_arg)
      return cb(function(...)
        callback_arg(...)
        _G.finished_ctags_runs = _G.finished_ctags_runs + 1
      end)
    end,
  })
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(stub_timers)
      child.lua [[require "shared.auto_commands"]]
    end,
    post_once = child.stop,
  },
}

local run_last_timer_callback = function()
  child.lua_func(function()
    _G.timer_callbacks[#_G.timer_callbacks].callback()
  end)
end

--- @class HexHighlight
--- @field row integer
--- @field col integer
--- @field end_col integer
--- @field hl_group string

--- @param bufnr_arg number
--- @return HexHighlight[]
local read_hex_highlights = function(bufnr_arg)
  local ns_id = vim.api.nvim_get_namespaces().HexColors
  local highlights = {}
  for _, extmark in
    ipairs(vim.api.nvim_buf_get_extmarks(bufnr_arg, ns_id, 0, -1, { details = true }))
  do
    table.insert(highlights, {
      row = extmark[2],
      col = extmark[3],
      end_col = extmark[4].end_col,
      hl_group = extmark[4].hl_group,
    })
  end

  return highlights
end

--- @param highlight_group_arg string
local read_highlight_group = function(highlight_group_arg)
  return vim.api.nvim_get_hl(0, { name = highlight_group_arg, link = false })
end

local expect_hex_highlights = MiniTest.new_expectation("hex highlights", function(bufnr, expected)
  return vim.deep_equal(child.lua_func(read_hex_highlights, bufnr), expected)
end, function(bufnr, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_func(read_hex_highlights, bufnr)),
    vim.inspect(expected)
  )
end)

local expect_highlight_group = MiniTest.new_expectation("highlight group", function(name, expected)
  return vim.deep_equal(child.lua_func(read_highlight_group, name), expected)
end, function(name, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_func(read_highlight_group, name)),
    vim.inspect(expected)
  )
end)

local expect_ctags_finished = function()
  test_helpers.expect_eventually(function()
    return child.lua_get [[_G.finished_ctags_runs]]
  end, 1)
end

local highlight_hex_colors = function()
  child.lua [[vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })]]
  run_last_timer_callback()
end

T["hex colors"] = MiniTest.new_set()

T["hex colors"]["highlights every hex color in the buffer"] = function()
  child.lua_func(test_helpers.open_buffer, { "#ff0000 #00ff00", "", "#000000" })

  highlight_hex_colors()

  expect_hex_highlights(0, {
    { row = 0, col = 0, end_col = 7, hl_group = "HexColor_ff0000" },
    { row = 0, col = 8, end_col = 15, hl_group = "HexColor_00ff00" },
    { row = 2, col = 0, end_col = 7, hl_group = "HexColor_000000" },
  })
end

T["hex colors"]["picks the foreground by luminance"] = function()
  child.lua_func(
    test_helpers.open_buffer,
    { "#ffffff #000000", "#ff0000 #00ff00", "#808080 #7f7f7f" }
  )

  highlight_hex_colors()

  expect_highlight_group("HexColor_ffffff", { bg = 0xffffff, fg = 0x000000 })
  expect_highlight_group("HexColor_000000", { bg = 0x000000, fg = 0xffffff })
  expect_highlight_group("HexColor_ff0000", { bg = 0xff0000, fg = 0xffffff })
  expect_highlight_group("HexColor_00ff00", { bg = 0x00ff00, fg = 0x000000 })
  expect_highlight_group("HexColor_808080", { bg = 0x808080, fg = 0x000000 })
  expect_highlight_group("HexColor_7f7f7f", { bg = 0x7f7f7f, fg = 0xffffff })
end

T["hex colors"]["leaves incomplete hex sequences alone"] = function()
  child.lua_func(test_helpers.open_buffer, { "#ff00 #gggggg #12345" })

  highlight_hex_colors()

  expect_hex_highlights(0, {})
end

T["hex colors"]["drops the highlights of text that changed"] = function()
  child.lua_func(test_helpers.open_buffer, { "#ff0000" })
  highlight_hex_colors()
  expect_hex_highlights(0, {
    { row = 0, col = 0, end_col = 7, hl_group = "HexColor_ff0000" },
  })

  child.api.nvim_buf_set_lines(0, 0, -1, false, { "no colors here" })
  highlight_hex_colors()

  expect_hex_highlights(0, {})
end

T["hex colors"]["skips buffers that are no longer current"] = function()
  local buf_id = child.lua_func(test_helpers.open_buffer, { "#ff0000" })
  child.lua [[vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })]]
  child.lua_func(test_helpers.open_buffer, {})

  run_last_timer_callback()

  expect_hex_highlights(buf_id, {})
end

T["hex colors"]["ignores buffers that were deleted"] = function()
  child.lua_func(test_helpers.open_buffer, { "#ff0000" })
  child.lua [[vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })]]
  child.lua_func(function()
    vim.api.nvim_buf_delete(0, { force = true })
  end)

  run_last_timer_callback()

  expect_hex_highlights(0, {})
end

T["ctags"] = MiniTest.new_set()

T["ctags"]["runs ctags with the files of the git root on write"] = function()
  child.lua_func(stub_ctags)
  child.lua_func(test_helpers.stub_async_system, {
    git = { err = nil, stdout = "/repo\n" },
    rg = { err = nil, stdout = "a.lua\nb.lua\n" },
  })
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]

  run_last_timer_callback()
  expect_ctags_finished()

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "rev-parse", "--show-toplevel" } } },
    { name = "system", args = { { "rg", "--files" }, { cwd = "/repo" } } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "system_calls"), {
    {
      name = "system",
      args = {
        { "ctags", "--recurse", "--links=no", "-L", "-" },
        { stdin = "a.lua\nb.lua\n" },
      },
    },
  })
end

T["ctags"]["does not run ctags when the git root cannot be determined"] = function()
  child.lua_func(stub_ctags)
  child.lua_func(test_helpers.stub_async_system, { git = { err = "git failed", stdout = nil } })
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]

  run_last_timer_callback()
  expect_ctags_finished()

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "rev-parse", "--show-toplevel" } } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "system_calls"), {})
end

T["ctags"]["does not run ctags when the file listing fails"] = function()
  child.lua_func(stub_ctags)
  child.lua_func(test_helpers.stub_async_system, {
    git = { err = nil, stdout = "/repo\n" },
    rg = { err = "rg failed", stdout = nil },
  })
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]

  run_last_timer_callback()
  expect_ctags_finished()

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "rev-parse", "--show-toplevel" } } },
    { name = "system", args = { { "rg", "--files" }, { cwd = "/repo" } } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "system_calls"), {})
end

T["ctags"]["restarts the timer on every write"] = function()
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]

  MiniTest.expect.equality(test_helpers.get_calls(child, "timer_calls"), {
    { name = "timer_start", args = { 5000, "<function>" } },
    { name = "timer_stop", args = { 1 } },
    { name = "timer_start", args = { 5000, "<function>" } },
  })
end

return T
