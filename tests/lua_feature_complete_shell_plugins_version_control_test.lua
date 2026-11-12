local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local editor_size = { lines = 24, columns = 80 }

--- @return string[]
local get_messages = function()
  local output = vim.api.nvim_exec2("messages", { output = true }).output

  return vim.split(output, "\n", { plain = true, trimempty = true })
end

--- @return table
local get_window_geometry = function()
  local config = vim.api.nvim_win_get_config(0)

  return {
    col = config.col,
    height = config.height,
    relative = config.relative,
    row = config.row,
    width = config.width,
  }
end

--- @return string[]
local get_jobstart_commands = function()
  --- @diagnostic disable-next-line: undefined-field
  local calls = _G.jobstart_calls

  return vim.tbl_map(function(call_arg)
    return call_arg.args[1]
  end, calls)
end

--- @return integer
local get_terminal_job_id = function()
  return vim.b.terminal_job_id
end

--- @param job_id integer
--- @return integer[]
local get_job_status = function(job_id)
  return vim.fn.jobwait({ job_id }, 0)
end

--- @param job_id integer
local stop_lazygit = function(job_id)
  vim.fn.jobstop(job_id)
end

--- @return string
local get_mode = function()
  return vim.api.nvim_get_mode().mode
end

--- @param command string[]
local stub_jobstart = function(command)
  local original_jobstart = vim.fn.jobstart

  require("tests._helpers").mock_child(vim.fn, {
    jobstart = function(_, opts_arg)
      return original_jobstart(command, opts_arg)
    end,
  }, "jobstart_calls")
end

local expect_window_geometry = MiniTest.new_expectation("window geometry", function(expected)
  return vim.deep_equal(child.lua_func(get_window_geometry), expected)
end, function(expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_func(get_window_geometry)),
    vim.inspect(expected)
  )
end)

local press_lazygit_key = function()
  child.type_keys "\\g"
  test_helpers.expect_eventually(function()
    return child.bo.buftype
  end, "terminal")
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.o.lines = editor_size.lines
      child.o.columns = editor_size.columns
      child.lua_func(test_helpers.stub_notify)
      child.lua_func(stub_jobstart, { "sleep", "60" })
      child.lua [[require "feature_complete.shell_plugins.version_control"]]
    end,
    post_once = child.stop,
  },
}

T["<leader>g"] = MiniTest.new_set()

T["<leader>g"]["opens lazygit in a full-width floating terminal from the first row"] = function()
  press_lazygit_key()

  expect_window_geometry { col = 0, height = 22, relative = "editor", row = 1, width = 80 }
  test_helpers.expect_eventually(function()
    return child.lua_func(get_mode)
  end, "t")
  MiniTest.expect.equality(child.lua_func(get_jobstart_commands), { "lazygit" })
end

T["<leader>g"]["reopens the running lazygit buffer after the window is closed"] = function()
  press_lazygit_key()
  local buf_id = child.api.nvim_get_current_buf()

  child.type_keys "<c-c>"
  press_lazygit_key()

  MiniTest.expect.equality(child.api.nvim_get_current_buf(), buf_id)
  MiniTest.expect.equality(#child.api.nvim_list_wins(), 2)
  MiniTest.expect.equality(child.lua_func(get_jobstart_commands), { "lazygit" })
end

T["<c-c>"] = MiniTest.new_set()

T["<c-c>"]["closes the window and notifies while lazygit keeps running"] = function()
  press_lazygit_key()
  local buf_id = child.api.nvim_get_current_buf()
  local job_id = child.lua_func(get_terminal_job_id)

  child.type_keys "<c-c>"

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  MiniTest.expect.equality(child.lua_func(get_job_status, job_id), { -1 })
  MiniTest.expect.equality(child.api.nvim_buf_is_valid(buf_id), true)
  test_helpers.expect_eventually(function()
    return test_helpers.get_calls(child, "notifications")
  end, {
    {
      name = "notify",
      args = { "Closing the lazygit window, buffer saved", vim.log.levels.INFO },
    },
  })
end

T["VimResized"] = MiniTest.new_set()

T["VimResized"]["resizes the window to the editor size"] = function()
  press_lazygit_key()

  child.o.lines = 40
  child.o.columns = 120

  test_helpers.expect_eventually(function()
    return child.lua_func(get_window_geometry)
  end, {
    col = 0,
    height = 38,
    relative = "editor",
    row = 1,
    width = 120,
  })
end

T["VimResized"]["keeps quiet once the window is closed"] = function()
  press_lazygit_key()

  child.type_keys "<c-c>"
  child.o.lines = 40

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  MiniTest.expect.equality(child.lua_func(get_messages), {})
end

T["lazygit exit"] = MiniTest.new_set()

T["lazygit exit"]["closes the window and deletes the terminal buffer"] = function()
  press_lazygit_key()
  local buf_id = child.api.nvim_get_current_buf()

  child.lua_func(stop_lazygit, child.lua_func(get_terminal_job_id))

  test_helpers.expect_eventually(function()
    return child.api.nvim_buf_is_valid(buf_id)
  end, false)
  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  MiniTest.expect.equality(child.lua_func(get_messages), {})
end

T["lazygit exit"]["closes cleanly when the exit arrives after <c-c> closed the window"] = function()
  press_lazygit_key()
  local buf_id = child.api.nvim_get_current_buf()
  local job_id = child.lua_func(get_terminal_job_id)

  child.type_keys "<c-c>"
  child.lua_func(stop_lazygit, job_id)

  test_helpers.expect_eventually(function()
    return child.api.nvim_buf_is_valid(buf_id)
  end, false)
  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  MiniTest.expect.equality(child.lua_func(get_messages), {})

  press_lazygit_key()

  MiniTest.expect.equality(child.lua_func(get_jobstart_commands), { "lazygit", "lazygit" })
end

return T
