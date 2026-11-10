local MiniTest = require "mini.test"
local h = require "helpers"
local test_helpers = require "tests._helpers"
local T = MiniTest.new_set()

T["tbl.map()"] = MiniTest.new_set()

T["tbl.map()"]["maps values and passes their indices"] = function()
  local result = h.tbl.map(function(value_arg, index_arg)
    return value_arg .. index_arg
  end, { "a", "b" })

  MiniTest.expect.equality(result, { "a1", "b2" })
end

T["tbl.map()"]["returns an empty list for empty input"] = function()
  MiniTest.expect.equality(
    h.tbl.map(function(value_arg)
      return value_arg
    end, {}),
    {}
  )
end

T["tbl.extend()"] = function()
  local first = { "a" }
  local second = { "b", "c" }
  local result = h.tbl.extend(first, second)

  MiniTest.expect.equality(result, { "a", "b", "c" })
  MiniTest.expect.equality(first, { "a" })
  MiniTest.expect.equality(second, { "b", "c" })
end

T["tbl.reverse()"] = MiniTest.new_set()

T["tbl.reverse()"]["reverses without changing the input"] = function()
  local input = { "a", "b", "c" }

  MiniTest.expect.equality(h.tbl.reverse(input), { "c", "b", "a" })
  MiniTest.expect.equality(input, { "a", "b", "c" })
end

T["tbl.reverse()"]["handles empty input"] = function()
  MiniTest.expect.equality(h.tbl.reverse {}, {})
end

T["str.pad()"] = MiniTest.new_set()

T["str.pad()"]["pads on the left and right"] = function()
  MiniTest.expect.equality(h.str.pad("cat", { min_len = 5, side = "left" }), "  cat")
  MiniTest.expect.equality(h.str.pad("cat", { min_len = 5, side = "right" }), "cat  ")
end

T["str.pad()"]["does not truncate values already at the requested length"] = function()
  MiniTest.expect.equality(h.str.pad("cat", { min_len = 2, side = "left" }), "cat")
  MiniTest.expect.equality(h.str.pad(12, { min_len = 4, side = "right" }), "12  ")
end

T["str.pad()"]["counts multibyte characters"] = function()
  MiniTest.expect.equality(h.str.pad("猫", { min_len = 3, side = "left" }), "  猫")
end

T["str.truncate()"] = MiniTest.new_set()

T["str.truncate()"]["truncates from either side"] = function()
  MiniTest.expect.equality(h.str.truncate("abcdefgh", { max_len = 5, side = "right" }), "abcd…")
  MiniTest.expect.equality(h.str.truncate("abcdefgh", { max_len = 5, side = "left" }), "…efgh")
end

T["str.truncate()"]["leaves values at or below the limit unchanged"] = function()
  MiniTest.expect.equality(h.str.truncate("cat", { max_len = 5, side = "right" }), "cat")
  MiniTest.expect.equality(h.str.truncate("abcde", { max_len = 5, side = "right" }), "abcde")
end

T["str.truncate()"]["preserves multibyte characters"] = function()
  MiniTest.expect.equality(h.str.truncate("猫犬鳥", { max_len = 2, side = "right" }), "猫…")
  MiniTest.expect.equality(h.str.truncate("猫犬鳥", { max_len = 2, side = "left" }), "…鳥")
end

T["str.truncate()"]["handles limits of zero and one"] = function()
  MiniTest.expect.equality(h.str.truncate("abc", { max_len = 0, side = "right" }), "")
  MiniTest.expect.equality(h.str.truncate("abc", { max_len = 1, side = "left" }), "…")
  MiniTest.expect.equality(h.str.truncate("a", { max_len = 1, side = "right" }), "a")
end

T["utils.vim_cmd_try_catch()"] = function()
  vim.g.helpers_try_catch_result = nil

  h.utils.vim_cmd_try_catch(
    "let g:helpers_try_catch_result = 'try'",
    "let g:helpers_try_catch_result = 'catch'"
  )
  MiniTest.expect.equality(vim.g.helpers_try_catch_result, "try")

  vim.g.helpers_try_catch_result = nil
  h.utils.vim_cmd_try_catch(
    "invalid-helper-test-command",
    "let g:helpers_try_catch_result = 'catch'"
  )
  MiniTest.expect.equality(vim.g.helpers_try_catch_result, "catch")

  vim.g.helpers_try_catch_result = nil
end

local clear_qf = function()
  vim.fn.setqflist({}, "f")
end

local add_qf_list = function(title, item_text, context_id)
  vim.fn.setqflist({}, " ", {
    title = title,
    items = { { text = item_text, valid = 1 } },
    context = { id = context_id },
  })
end

local get_qf_titles = function()
  local count = vim.fn.getqflist({ nr = "$" }).nr
  local titles = {}
  for index = 1, count do
    table.insert(titles, vim.fn.getqflist({ nr = index, title = 0 }).title)
  end
  return titles
end

local qf_hooks = {
  pre_case = function()
    clear_qf()
    add_qf_list("first", "first item", 1)
    add_qf_list("second", "second item", 2)
  end,
  post_case = clear_qf,
}

T["qf.filter()"] = MiniTest.new_set { hooks = qf_hooks }

T["qf.filter()"]["returns an empty list when no list matches"] = function()
  MiniTest.expect.equality(
    h.qf.filter(function()
      return false
    end),
    {}
  )
end

T["qf.filter()"]["returns an empty list when quickfix history is empty"] = function()
  clear_qf()

  MiniTest.expect.equality(
    h.qf.filter(function()
      return true
    end),
    {}
  )
end

T["qf.filter()"]["filters quickfix lists by predicate"] = function()
  local result = h.qf.filter(function(list_arg)
    return list_arg.title == "second"
  end)

  MiniTest.expect.equality(get_qf_titles(), { "first", "second" })
  MiniTest.expect.equality(
    vim.tbl_map(function(list_arg)
      return list_arg.title
    end, result),
    { "second" }
  )
end

T["qf.replace()"] = MiniTest.new_set { hooks = qf_hooks }

T["qf.replace()"]["replaces quickfix history with the supplied lists"] = function()
  h.qf.replace(h.qf.filter(function()
    return true
  end))

  MiniTest.expect.equality(get_qf_titles(), { "first", "second" })
  MiniTest.expect.equality(
    vim.tbl_map(function(item_arg)
      return item_arg.text
    end, vim.fn.getqflist({ nr = 1, items = 0 }).items),
    { "first item" }
  )
  MiniTest.expect.equality(vim.fn.getqflist({ nr = 1, context = 0, idx = 0 }).context, { id = 1 })
end

T["qf.replace()"]["clears quickfix history when given no lists"] = function()
  h.qf.replace {}

  MiniTest.expect.equality(get_qf_titles(), {})
end

T["utils.is_big_file()"] = MiniTest.new_set()

T["utils.is_big_file()"]["uses a strict line-count threshold"] = function()
  local missing_file = vim.fn.tempname()

  MiniTest.expect.equality({
    h.utils.is_big_file { bname = missing_file, line_count = 20000 },
    h.utils.is_big_file { bname = missing_file, line_count = 20001 },
  }, { false, true })
end

T["utils.is_big_file()"]["accepts files exactly one and a half megabytes"] = function()
  local path = test_helpers.write_temp_file(string.rep("x", 1572864))

  MiniTest.expect.equality(h.utils.is_big_file { bname = path, line_count = 0 }, false)
end

T["utils.is_big_file()"]["detects files larger than one and a half megabytes"] = function()
  local path = test_helpers.write_temp_file(string.rep("x", 1572865))

  MiniTest.expect.equality(h.utils.is_big_file { bname = path, line_count = 0 }, true)
end

local original_registers = {}
T["utils.rotate_registers()"] = MiniTest.new_set {
  hooks = {
    pre_once = function()
      for index = 0, 9 do
        original_registers[index] = vim.fn.getreginfo(tostring(index))
      end
    end,
    pre_case = function()
      for index = 0, 9 do
        vim.fn.setreg(tostring(index), "reg" .. index)
      end
    end,
    post_case = function()
      for index = 0, 9 do
        local register_info = original_registers[index]
        vim.fn.setreg(tostring(index), register_info.regcontents, register_info.regtype)
      end
    end,
  },
}

T["utils.rotate_registers()"]["shifts numbered registers up by one"] = function()
  h.utils.rotate_registers()

  MiniTest.expect.equality(
    vim.tbl_map(function(index_arg)
      return vim.fn.getreginfo(tostring(index_arg)).regcontents[1]
    end, { 1, 2, 3, 4, 5, 6, 7, 8, 9 }),
    { "reg0", "reg1", "reg2", "reg3", "reg4", "reg5", "reg6", "reg7", "reg8" }
  )
end

T["utils.set_and_rotate()"] = function()
  local original_registers = {}
  for index = 0, 9 do
    original_registers[index] = vim.fn.getreginfo(tostring(index))
  end
  original_registers.unnamed = vim.fn.getreginfo "\""

  local original_setreg = vim.fn.setreg
  local original_notify = vim.notify
  local clipboard_value = nil
  local notification = nil
  rawset(vim.fn, "setreg", function(register_arg, value_arg, regtype_arg)
    if register_arg == "+" then
      clipboard_value = value_arg
      return 0
    end
    return original_setreg(register_arg, value_arg, regtype_arg)
  end)
  rawset(vim, "notify", function(message_arg, level_arg)
    notification = { message = message_arg, level = level_arg }
  end)

  MiniTest.finally(function()
    rawset(vim.fn, "setreg", original_setreg)
    rawset(vim, "notify", original_notify)
    for index = 0, 9 do
      local register_info = original_registers[index]
      vim.fn.setreg(tostring(index), register_info.regcontents, register_info.regtype)
    end
    vim.fn.setreg("\"", original_registers.unnamed.regcontents, original_registers.unnamed.regtype)
  end)

  for index = 0, 9 do
    vim.fn.setreg(tostring(index), "reg" .. index)
  end
  h.utils.set_and_rotate "new value"

  MiniTest.expect.equality(vim.fn.getreg("\"", 1, true), { "new value" })
  MiniTest.expect.equality(clipboard_value, "new value")
  MiniTest.expect.equality(notification, {
    message = "Setting the unnamed and + registers to: `new value`",
    level = 2,
  })
  MiniTest.expect.equality(
    vim.tbl_map(function(index_arg)
      return vim.fn.getreginfo(tostring(index_arg)).regcontents[1]
    end, { 1, 2, 3, 4, 5, 6, 7, 8, 9 }),
    { "new value", "reg1", "reg2", "reg3", "reg4", "reg5", "reg6", "reg7", "reg8" }
  )
end

T["async.system()"] = function()
  --- @type vim.async.Task<vim.SystemCompleted>
  local task = vim.async.run(
    --- @return vim.SystemCompleted
    function()
      return h.async.system { "printf", "%s", "async output" }
    end
  )
  local result = task:wait(1000) --[[@as vim.SystemCompleted]]

  MiniTest.expect.equality(
    { code = result.code, stdout = result.stdout, stderr = result.stderr },
    { code = 0, stdout = "async output", stderr = "" }
  )
end

T["async.ui_input()"] = function()
  local original_helpers = package.loaded.helpers
  local original_input = vim.ui.input
  rawset(vim.ui, "input", function(opts_arg, callback_arg)
    callback_arg "confirmed"
  end)
  package.loaded.helpers = nil
  local helpers_with_stubbed_input = require "helpers"

  MiniTest.finally(function()
    rawset(vim.ui, "input", original_input)
    package.loaded.helpers = original_helpers
  end)

  local result = vim.async
    .run(function()
      return helpers_with_stubbed_input.async.ui_input { prompt = "test" }
    end)
    :wait(1000)

  MiniTest.expect.equality(result, "confirmed")
end

T["async.cb()"] = function()
  local callback_result = nil
  local callback = h.async.cb(function(value_arg)
    callback_result = value_arg
  end)
  callback "callback value"

  MiniTest.expect.equality(
    vim.wait(1000, function()
      return callback_result ~= nil
    end),
    true
  )
  MiniTest.expect.equality(callback_result, "callback value")
end

T["async.ensure_main_loop()"] = function()
  --- @type vim.async.Task<string>
  local task = vim.async.run(
    --- @return string
    function()
      h.async.ensure_main_loop()
      return "resumed"
    end
  )
  local result = task:wait(1000)

  MiniTest.expect.equality(result, "resumed")
end

return T
