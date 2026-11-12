local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local stub_echo_and_timers = function()
  local helpers = require "tests._helpers"

  _G.timer_callbacks = {}
  helpers.mock_child(vim.api, { nvim_echo = function() end }, "echo_calls")
  helpers.mock_child(vim.fn, {
    timer_start = function(_, callback_arg)
      table.insert(_G.timer_callbacks, callback_arg)

      return #_G.timer_callbacks
    end,
    timer_stop = function() end,
  }, "timer_calls")
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(stub_echo_and_timers)
      child.lua [[require "shared.notify"]]
    end,
    post_once = child.stop,
  },
}

--- @param message string
--- @param level integer?
local notify = function(message, level)
  child.lua_func(
    --- @param message_arg string
    --- @param level_arg integer?
    function(message_arg, level_arg)
      vim.notify(message_arg, level_arg)
    end,
    message,
    level
  )
end

local get_echo_calls = function()
  return test_helpers.get_calls(child, "echo_calls")
end

local get_timer_calls = function()
  return test_helpers.get_calls(child, "timer_calls")
end

local run_timer_callback = function()
  child.lua_func(function()
    _G.timer_callbacks[1]()
  end)
end

T["highlight groups"] = MiniTest.new_set {
  parametrize = {
    { "NotifyDebug", vim.log.levels.DEBUG },
    { "NotifyError", vim.log.levels.ERROR },
    { "NotifyInfo", vim.log.levels.INFO },
    { "NotifyOff", vim.log.levels.OFF },
    { "NotifyTrace", vim.log.levels.TRACE },
    { "NotifyWarn", vim.log.levels.WARN },
  },
}

T["highlight groups"]["echoes the message with the highlight group of the level"] = function(
  hl_group,
  level
)
  notify("hello", level)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "hello", hl_group } }, true, {} } },
  })
end

T["vim.notify"] = MiniTest.new_set()

T["vim.notify"]["echoes a message without a level without a highlight group"] = function()
  notify "hello"

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "hello" } }, true, {} } },
  })
end

T["vim.notify"]["cuts the message at the first newline"] = function()
  notify("hello\nworld", vim.log.levels.INFO)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "hello…", "NotifyInfo" } }, true, {} } },
  })
end

T["vim.notify"]["cuts the message to the width of the window"] = function()
  child.o.columns = 40

  notify(string.rep("x", 50), vim.log.levels.INFO)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { string.rep("x", 38) .. "…", "NotifyInfo" } }, true, {} } },
  })
end

T["vim.notify"]["keeps a message that fits the window"] = function()
  child.o.columns = 40

  notify(string.rep("x", 39), vim.log.levels.INFO)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { string.rep("x", 39), "NotifyInfo" } }, true, {} } },
  })
end

T["vim.notify"]["cuts multibyte messages by characters"] = function()
  child.o.columns = 40

  notify(string.rep("é", 50), vim.log.levels.INFO)

  test_helpers.expect_eventually(get_echo_calls, {
    {
      name = "nvim_echo",
      args = { { { string.rep("é", 38) .. "…", "NotifyInfo" } }, true, {} },
    },
  })
end

T["vim.notify"]["stops the previous timer before starting a new one"] = function()
  notify("first", vim.log.levels.INFO)
  notify("second", vim.log.levels.INFO)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "first", "NotifyInfo" } }, true, {} } },
    { name = "nvim_echo", args = { { { "second", "NotifyInfo" } }, true, {} } },
  })
  MiniTest.expect.equality(get_timer_calls(), {
    { name = "timer_start", args = { 2000, "<function>" } },
    { name = "timer_stop", args = { 1 } },
    { name = "timer_start", args = { 2000, "<function>" } },
  })
end

T["vim.notify"]["clears the message when the timer fires in normal mode"] = function()
  notify("hello", vim.log.levels.WARN)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "hello", "NotifyWarn" } }, true, {} } },
  })
  run_timer_callback()

  MiniTest.expect.equality(get_echo_calls(), {
    { name = "nvim_echo", args = { { { "hello", "NotifyWarn" } }, true, {} } },
    { name = "nvim_echo", args = { { { "" } }, false, {} } },
  })
  MiniTest.expect.equality(get_timer_calls(), {
    { name = "timer_start", args = { 2000, "<function>" } },
  })
end

T["vim.notify"]["keeps the message when the timer fires outside normal mode"] = function()
  notify("hello", vim.log.levels.WARN)

  test_helpers.expect_eventually(get_echo_calls, {
    { name = "nvim_echo", args = { { { "hello", "NotifyWarn" } }, true, {} } },
  })
  child.cmd "startinsert"
  run_timer_callback()

  MiniTest.expect.equality(get_echo_calls(), {
    { name = "nvim_echo", args = { { { "hello", "NotifyWarn" } }, true, {} } },
  })
end

return T
