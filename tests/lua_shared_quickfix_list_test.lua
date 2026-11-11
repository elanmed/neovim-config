local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.o.columns = 100
      child.o.lines = 30
      child.lua [[require "shared.quickfix_list"]]
    end,
    post_once = child.stop,
  },
}

--- @class QuickfixTestItem
--- @field path string?
--- @field lnum integer?
--- @field col integer?
--- @field text string

--- @param items QuickfixTestItem[]
--- @param idx integer?
local set_qf_list = function(items, idx)
  child.lua_func(
    --- @param items_arg QuickfixTestItem[]
    --- @param idx_arg integer
    function(items_arg, idx_arg)
      local qf_items = {}
      for index, item_arg in ipairs(items_arg) do
        local bufnr = (function()
          if item_arg.path == nil then
            return nil
          end

          return vim.fn.bufadd(item_arg.path)
        end)()

        qf_items[index] = {
          bufnr = bufnr,
          lnum = item_arg.lnum,
          col = item_arg.col,
          text = item_arg.text,
        }
      end
      vim.fn.setqflist({}, " ", { items = qf_items, idx = idx_arg })
    end,
    items,
    idx or 1
  )
end

local formatted_items = function()
  return child.lua_get [[_G.GetQuickfixTextFunc()]]
end

local current_qf_list_nr = function()
  return child.lua_get [[vim.fn.getqflist({ nr = 0 }).nr]]
end

local expect_bufname = MiniTest.new_expectation(
  "buffer name",
  --- @param observed string
  --- @param expected string
  function(observed, expected)
    return observed == expected
  end,
  --- @param observed string
  --- @param expected string
  function(observed, expected)
    return string.format("Observed: %s\nExpected: %s", vim.inspect(observed), vim.inspect(expected))
  end
)

local expect_line = MiniTest.new_expectation(
  "cursor line",
  --- @param observed integer
  --- @param expected integer
  function(observed, expected)
    return observed == expected
  end,
  --- @param observed integer
  --- @param expected integer
  function(observed, expected)
    return string.format("Observed: %s\nExpected: %s", vim.inspect(observed), vim.inspect(expected))
  end
)

T["GetQuickfixTextFunc()"] = MiniTest.new_set()

T["GetQuickfixTextFunc()"]["aligns the file name, row, and column columns"] = function()
  child.o.columns = 300
  local paths = test_helpers.make_files { "alpha/short.lua", "beta/very_long_name.lua" }
  set_qf_list {
    { path = paths[1], lnum = 7, col = 12, text = "  hello  " },
    { path = paths[2], lnum = 100, col = 3, text = "world" },
  }

  MiniTest.expect.equality(formatted_items(), {
    "alpha/short.lua         |   7:12 | hello",
    "beta/very_long_name.lua | 100:3  | world",
  })
end

T["GetQuickfixTextFunc()"]["truncates entries wider than the window"] = function()
  local paths = test_helpers.make_files { "aa/f.lua" }
  set_qf_list {
    { path = paths[1], lnum = 1, col = 1, text = "the quick brown fox jumps over the lazy dog" },
  }
  child.cmd "silent copen"

  MiniTest.expect.equality(formatted_items(), { "aa/f.lua | 1:1 | the quick brown fox jum" })
end

T["GetQuickfixTextFunc()"]["keeps the full entry when a preview window is open"] = function()
  local paths = test_helpers.make_files { "aa/f.lua" }
  set_qf_list {
    { path = paths[1], lnum = 1, col = 1, text = "the quick brown fox jumps over the lazy dog" },
  }
  child.cmd "silent copen"
  child.lua_func(function()
    vim.cmd "split"
    vim.bo.filetype = "quickfix-preview"
    vim.cmd "wincmd p"
  end)

  MiniTest.expect.equality(
    formatted_items(),
    { "aa/f.lua | 1:1 | the quick brown fox jumps over the lazy dog" }
  )
end

T["GetQuickfixTextFunc()"]["cuts multibyte text in the middle of a character"] = function()
  local paths = test_helpers.make_files { "dd/f.lua" }
  set_qf_list {
    { path = paths[1], lnum = 1, col = 1, text = string.rep("é", 30) },
  }
  child.cmd "silent copen"

  MiniTest.expect.equality(
    formatted_items(),
    { "dd/f.lua | 1:1 | " .. string.rep("é", 11) .. "\195" }
  )
end

T["GetQuickfixTextFunc()"]["uses the current buffer name for entries without a file"] = function()
  child.o.columns = 300
  local paths = test_helpers.make_files { "alpha/short.lua" }
  child.cmd("edit " .. vim.fn.fnameescape(paths[1]))
  set_qf_list { { text = "no file" } }

  MiniTest.expect.equality(formatted_items(), { "alpha/short.lua | 0:0 | no file" })
end

T["<C-n>"] = MiniTest.new_set()

T["<C-n>"]["jumps to the next entry"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua", "aa/f3.lua" }
  set_qf_list({
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
    { path = paths[3], lnum = 15, col = 1, text = "text3" },
  }, 2)

  child.type_keys "<C-n>"

  expect_bufname(child.fn.bufname(), paths[3])
  expect_line(child.fn.line ".", 15)
end

T["<C-n>"]["wraps to the first entry after the last one"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua" }
  set_qf_list({
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
  }, 2)

  child.type_keys "<C-n>"

  expect_bufname(child.fn.bufname(), paths[1])
  expect_line(child.fn.line ".", 5)
end

T["<C-n>"]["does nothing when the quickfix list is empty"] = function()
  child.type_keys "<C-n>"

  expect_bufname(child.fn.bufname(), "")
  expect_line(child.fn.line ".", 1)
end

T["<C-p>"] = MiniTest.new_set()

T["<C-p>"]["jumps to the previous entry"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua", "aa/f3.lua" }
  set_qf_list({
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
    { path = paths[3], lnum = 15, col = 1, text = "text3" },
  }, 2)

  child.type_keys "<C-p>"

  expect_bufname(child.fn.bufname(), paths[1])
  expect_line(child.fn.line ".", 5)
end

T["<C-p>"]["wraps to the last entry before the first one"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua" }
  set_qf_list {
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
  }

  child.type_keys "<C-p>"

  expect_bufname(child.fn.bufname(), paths[2])
  expect_line(child.fn.line ".", 10)
end

T["quickfix window keymaps"] = MiniTest.new_set()

T["quickfix window keymaps"]["closes the window and jumps on <CR>"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua" }
  set_qf_list {
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
  }
  child.cmd "silent copen"

  child.type_keys("2G", "<CR>")

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
  expect_bufname(child.fn.bufname(), paths[2])
  expect_line(child.fn.line ".", 10)
end

T["quickfix window keymaps"]["jumps and keeps the window open on o"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua" }
  set_qf_list {
    { path = paths[1], lnum = 5, col = 1, text = "text1" },
    { path = paths[2], lnum = 10, col = 1, text = "text2" },
  }
  child.cmd "silent copen"

  child.type_keys("2G", "o")

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 2)
  expect_bufname(child.fn.bufname(), paths[2])
  expect_line(child.fn.line ".", 10)
end

T["quickfix window keymaps"]["closes the window on the leader mapping"] = function()
  set_qf_list { { text = "no file" } }
  child.cmd "silent copen"

  child.type_keys "\\c"

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
end

T["quickfix window keymaps"]["starts no macro recording on q"] = function()
  set_qf_list { { text = "no file" } }
  child.cmd "silent copen"

  child.type_keys "q"

  MiniTest.expect.equality(#child.api.nvim_list_wins(), 2)
  MiniTest.expect.equality(child.fn.reg_recording(), "")
end

T["quickfix window keymaps"]["> and < move between the lists"] = function()
  local paths = test_helpers.make_files { "aa/f1.lua", "aa/f2.lua" }
  set_qf_list { { path = paths[1], lnum = 5, col = 1, text = "text1" } }
  set_qf_list { { path = paths[2], lnum = 10, col = 1, text = "text2" } }
  child.cmd "silent copen"
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "<"

  MiniTest.expect.equality(current_qf_list_nr(), 1)
  MiniTest.expect.equality(child.lua_get [[_G.notifications]], {})

  child.type_keys "<"
  child.type_keys ">"

  MiniTest.expect.equality(current_qf_list_nr(), 2)

  child.type_keys ">"

  MiniTest.expect.equality(current_qf_list_nr(), 2)
  MiniTest.expect.equality(child.lua_get [[_G.notifications]], {
    { name = "notify", args = { "No older list!", vim.log.levels.WARN } },
    { name = "notify", args = { "No newer list!", vim.log.levels.WARN } },
  })
end

return T
