local MiniTest = require "mini.test"
local h = require "helpers"
local test_helpers = require "tests._helpers"
local T = MiniTest.new_set()

--- @class QuickfixList
--- @field title string

--- @class QuickfixItem
--- @field text string

--- @param filepath string
local readfile = function(filepath)
  local task = vim.async.run(function()
    return vim.async.await(h.fs.readfile(filepath))
  end)
  return task:wait(1000)
end

T["tbl.map()"] = MiniTest.new_set()

T["tbl.map()"]["maps values and passes their indices"] = function()
  --- @param value_arg string
  --- @param index_arg number
  local result = h.tbl.map(function(value_arg, index_arg)
    return value_arg .. index_arg
  end, { "a", "b" })

  MiniTest.expect.equality(result, { "a1", "b2" })
end

T["tbl.map()"]["returns an empty list for empty input"] = function()
  MiniTest.expect.equality(
    h.tbl.map(
      --- @param value_arg any
      function(value_arg)
        return value_arg
      end,
      {}
    ),
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

T["fs.readfile()"] = MiniTest.new_set()

T["fs.readfile()"]["reads lines asynchronously"] = function()
  local path = test_helpers.write_temp_file "first\n\nlast\n"

  MiniTest.expect.equality(readfile(path), {
    lines = { "first", "", "last" },
    str = "first\n\nlast\n",
  })
end

T["fs.readfile()"]["normalizes files without a final newline"] = function()
  local path = test_helpers.write_temp_file "first\nsecond"

  MiniTest.expect.equality(readfile(path), {
    lines = { "first", "second" },
    str = "first\nsecond\n",
  })
end

T["fs.readfile()"]["preserves multiple trailing blank lines"] = function()
  local path = test_helpers.write_temp_file "first\n\n\n"

  MiniTest.expect.equality(readfile(path), {
    lines = { "first", "", "" },
    str = "first\n\n\n",
  })
end

T["fs.readfile()"]["preserves leading blank lines"] = function()
  local path = test_helpers.write_temp_file "\nfirst\n"

  MiniTest.expect.equality(readfile(path), { lines = { "", "first" }, str = "\nfirst\n" })
end

T["fs.readfile()"]["returns empty contents for empty files"] = function()
  local path = test_helpers.write_temp_file ""

  MiniTest.expect.equality(readfile(path), { lines = {}, str = "" })
end

T["fs.readfile()"]["raises an error for missing files"] = function()
  local path = vim.fn.tempname()

  MiniTest.expect.error(function()
    readfile(path)
  end)
end

T["fs.readfile()"]["returns empty contents without reading zero-byte files"] = function()
  local did_read = false
  local did_close = false

  test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback(nil, { size = 0 })
    end,
    fs_read = function(_, _, _, callback)
      did_read = true
      callback(nil, "")
    end,
    fs_close = function(_, callback)
      did_close = true
      callback(nil)
    end,
  })

  MiniTest.expect.equality(readfile "mocked-empty.txt", { lines = {}, str = "" })
  MiniTest.expect.equality({ did_read, did_close }, { false, true })
end

T["fs.readfile()"]["propagates open errors"] = function()
  test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback "open failed"
    end,
  })

  MiniTest.expect.error(function()
    readfile "mocked-missing.txt"
  end)
end

T["fs.readfile()"]["closes the descriptor after reading mocked contents"] = function()
  local content = "first\n\nlast\n"
  local calls = test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback(nil, { size = #content })
    end,
    fs_read = function(_, _, _, callback)
      callback(nil, content)
    end,
    fs_close = function(_, callback)
      callback(nil)
    end,
  })

  MiniTest.expect.equality(readfile "mocked.txt", {
    lines = { "first", "", "last" },
    str = "first\n\nlast\n",
  })
  MiniTest.expect.equality(calls, {
    { name = "fs_open", args = { "mocked.txt", 0, 0, "<function>" } },
    { name = "fs_fstat", args = { 17, "<function>" } },
    { name = "fs_read", args = { 17, #content, 0, "<function>" } },
    { name = "fs_close", args = { 17, "<function>" } },
  })
end

T["fs.readfile()"]["closes the descriptor when stat fails"] = function()
  local did_close = false
  test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback "stat failed"
    end,
    fs_close = function(_, callback)
      did_close = true
      callback(nil)
    end,
  })

  MiniTest.expect.error(function()
    readfile "mocked.txt"
  end)
  MiniTest.expect.equality(did_close, true)
end

T["fs.readfile()"]["closes the descriptor when reading fails"] = function()
  local did_close = false
  test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback(nil, { size = 1 })
    end,
    fs_read = function(_, _, _, callback)
      callback "read failed"
    end,
    fs_close = function(_, callback)
      did_close = true
      callback(nil)
    end,
  })

  MiniTest.expect.error(function()
    readfile "mocked.txt"
  end)
  MiniTest.expect.equality(did_close, true)
end

T["fs.readfile()"]["raises when closing fails"] = function()
  test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback(nil, { size = 1 })
    end,
    fs_read = function(_, _, _, callback)
      callback(nil, "x")
    end,
    fs_close = function(_, callback)
      callback "close failed"
    end,
  })

  MiniTest.expect.error(function()
    readfile "mocked.txt"
  end)
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

local child = MiniTest.new_child_neovim()

local child_hooks = {
  pre_case = function()
    child.restart { "-u", "scripts/minimal_init.lua" }
  end,
  post_once = function()
    if child.is_running() then
      child.stop()
    end
  end,
}

local seed_qf_lists = function()
  vim.fn.setqflist({}, "f")
  vim.fn.setqflist({}, " ", {
    title = "first",
    items = { { text = "first item", valid = 1 } },
    context = { id = 1 },
  })
  vim.fn.setqflist({}, " ", {
    title = "second",
    items = { { text = "second item", valid = 1 } },
    context = { id = 2 },
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

T["qf.filter()"] = MiniTest.new_set { hooks = child_hooks }

T["qf.filter()"]["returns an empty list when no list matches"] = function()
  child.lua_func(seed_qf_lists)

  local filtered_count = child.lua_func(function()
    local helpers = require "helpers"

    return #helpers.qf.filter(function()
      return false
    end)
  end)

  MiniTest.expect.equality(filtered_count, 0)
end

T["qf.filter()"]["returns an empty list when quickfix history is empty"] = function()
  local filtered_count = child.lua_func(function()
    local helpers = require "helpers"

    vim.fn.setqflist({}, "f")

    return #helpers.qf.filter(function()
      return true
    end)
  end)

  MiniTest.expect.equality(filtered_count, 0)
end

T["qf.filter()"]["filters quickfix lists by predicate"] = function()
  child.lua_func(seed_qf_lists)

  MiniTest.expect.equality(child.lua_func(get_qf_titles), { "first", "second" })
  MiniTest.expect.equality(
    child.lua_func(function()
      local helpers = require "helpers"

      local filtered = helpers.qf.filter(
        --- @param list_arg QuickfixList
        function(list_arg)
          return list_arg.title == "second"
        end
      )

      local titles = {}
      for _, list in ipairs(filtered) do
        table.insert(titles, list.title)
      end

      return titles
    end),
    { "second" }
  )
end

T["qf.replace()"] = MiniTest.new_set { hooks = child_hooks }

T["qf.replace()"]["replaces quickfix history with the supplied lists"] = function()
  child.lua_func(seed_qf_lists)
  child.lua_func(function()
    local helpers = require "helpers"

    helpers.qf.replace(helpers.qf.filter(function()
      return true
    end))
  end)

  MiniTest.expect.equality(child.lua_func(get_qf_titles), { "first", "second" })
  MiniTest.expect.equality(
    child.lua_func(function()
      return vim.tbl_map(
        --- @param item_arg QuickfixItem
        function(item_arg)
          return item_arg.text
        end,
        vim.fn.getqflist({ nr = 1, items = 0 }).items
      )
    end),
    { "first item" }
  )
  MiniTest.expect.equality(
    child.lua_func(function()
      return vim.fn.getqflist({ nr = 1, context = 0, idx = 0 }).context
    end),
    { id = 1 }
  )
end

T["qf.replace()"]["clears quickfix history when given no lists"] = function()
  child.lua_func(seed_qf_lists)
  child.lua [[require("helpers").qf.replace {}]]

  MiniTest.expect.equality(child.lua_func(get_qf_titles), {})
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

T["utils.rotate_registers()"] = MiniTest.new_set { hooks = child_hooks }

T["utils.rotate_registers()"]["shifts numbered registers up by one"] = function()
  local register_contents = child.lua_func(function()
    local helpers = require "helpers"

    for index = 0, 9 do
      vim.fn.setreg(tostring(index), "reg" .. index)
    end

    helpers.utils.rotate_registers()

    local contents = {}
    for index = 1, 9 do
      table.insert(contents, vim.fn.getreginfo(tostring(index)).regcontents[1])
    end

    return contents
  end)

  MiniTest.expect.equality(register_contents, {
    "reg0",
    "reg1",
    "reg2",
    "reg3",
    "reg4",
    "reg5",
    "reg6",
    "reg7",
    "reg8",
  })
end

T["utils.set_and_rotate()"] = MiniTest.new_set { hooks = child_hooks }

T["utils.set_and_rotate()"]["sets the clipboard and unnamed registers and rotates the rest"] = function()
  local result = child.lua_func(function()
    local helpers = require "helpers"

    local test_helpers = require "tests._helpers"

    local clipboard_value = nil
    local original_setreg = vim.fn.setreg
    test_helpers.mock_child(vim.fn, {
      setreg = function(register_arg, value_arg, regtype_arg)
        if register_arg == "+" then
          clipboard_value = value_arg
          return 0
        end

        return original_setreg(register_arg, value_arg, regtype_arg)
      end,
    })
    local notifications = test_helpers.stub_notify()

    for index = 0, 9 do
      vim.fn.setreg(tostring(index), "reg" .. index)
    end
    helpers.utils.set_and_rotate "new value"

    local register_contents = {}
    for index = 1, 9 do
      table.insert(register_contents, vim.fn.getreginfo(tostring(index)).regcontents[1])
    end

    return {
      unnamed = vim.fn.getreg("\"", 1, true),
      clipboard = clipboard_value,
      notifications = notifications,
      registers = register_contents,
    }
  end)

  MiniTest.expect.equality(result.unnamed, { "new value" })
  MiniTest.expect.equality(result.clipboard, "new value")
  MiniTest.expect.equality(result.notifications, {
    {
      name = "notify",
      args = { "Setting the unnamed and + registers to: `new value`", vim.log.levels.INFO },
    },
  })
  MiniTest.expect.equality(result.registers, {
    "new value",
    "reg1",
    "reg2",
    "reg3",
    "reg4",
    "reg5",
    "reg6",
    "reg7",
    "reg8",
  })
end

T["async.system()"] = function()
  local task = vim.async.run(function()
    return vim.async.await(h.async.system { "printf", "%s", "async output" })
  end)
  local err, stdout = task:wait(1000)

  MiniTest.expect.equality({ err = err, stdout = stdout }, { err = nil, stdout = "async output" })
end

T["async.ui_input()"] = MiniTest.new_set { hooks = child_hooks }

T["async.ui_input()"]["returns the value passed to the callback"] = function()
  local result = child.lua_func(function()
    require("tests._helpers").mock_child(vim.ui, {
      input = function(_, callback_arg)
        callback_arg "confirmed"
      end,
    })
    package.loaded.helpers = nil
    local helpers_with_stubbed_input = require "helpers"

    return vim.async
      .run(function()
        return helpers_with_stubbed_input.async.ui_input { prompt = "test" }
      end)
      :wait(1000)
  end)

  MiniTest.expect.equality(result, "confirmed")
end

T["async.cb()"] = function()
  local callback_result = nil
  local callback = h.async.cb(
    --- @param value_arg string
    function(value_arg)
      callback_result = value_arg
    end
  )
  callback "callback value"

  test_helpers.expect_eventually(function()
    return callback_result
  end, "callback value")
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
