local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.o.columns = 60
    end,
    post_once = child.stop,
  },
}

local load_module = function()
  child.lua [[require "shared.tabline"]]
end

local tabline = function()
  return child.lua_get [[_G.Tabline()]]
end

local statusline = function()
  return child.lua_get [[_G.Statusline()]]
end

local stub_branch = function(result)
  local helpers = require "helpers"

  _G.branch_calls = require("tests._helpers").mock_child(helpers.async, {
    system = function()
      return vim.async.run(function()
        --- @diagnostic disable-next-line: redundant-return-value
        return result.err, result.stdout
      end)
    end,
  })
end

T["setup"] = MiniTest.new_set()

T["setup"]["defines the global Tabline and Statusline functions"] = function()
  load_module()

  MiniTest.expect.equality(child.lua_get [[type(_G.Tabline)]], "function")
  MiniTest.expect.equality(child.lua_get [[type(_G.Statusline)]], "function")
end

T["setup"]["sets the tabline and statusline options"] = function()
  load_module()

  MiniTest.expect.equality(child.o.showtabline, 2)
  MiniTest.expect.equality(child.o.tabline, "%!v:lua.Tabline()")
  MiniTest.expect.equality(child.o.statusline, "%!v:lua.Statusline()")
end

T["setup"]["invalidates the branch cache on GitHeadChanged"] = function()
  load_module()

  local autocmd_count = child.lua_func(function()
    return #vim.api.nvim_get_autocmds {
      group = "InvalidateBranchCache",
      event = "User",
      pattern = "GitHeadChanged",
    }
  end)

  MiniTest.expect.equality(autocmd_count, 1)
end

T["Tabline()"] = MiniTest.new_set()

T["Tabline()"]["shows the current and the alternate buffer names"] = function()
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/b/two.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/one.lua")

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua"
      .. string.rep(" ", 22)
      .. "%#TabLine#ALT b/two.lua"
  )
end

T["Tabline()"]["truncates long buffer names from the left"] = function()
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/one.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/" .. string.rep("0123456789", 4))

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#…1234567890123456789"
      .. string.rep(" ", 11)
      .. "%#TabLine#ALT a/one.lua"
  )
end

T["Tabline()"]["shows [unnamed] for buffers without a name"] = function()
  load_module()
  child.lua_func(test_helpers.open_buffer)

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[unnamed]" .. string.rep(" ", 22) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["shows [terminal] for terminal buffers"] = function()
  load_module()
  child.lua_func(test_helpers.open_buffer)
  child.lua [[vim.fn.jobstart({ "true" }, { term = true })]]

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[terminal]" .. string.rep(" ", 21) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["hides the alternate buffer when it has the same relative name"] = function()
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/x/dir/file.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/two/y/dir/file.lua")

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#dir/file.lua" .. string.rep(" ", 19) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["shows the current tab page number when there are multiple tab pages"] = function()
  load_module()
  child.cmd "tabnew"

  MiniTest.expect.equality(
    tabline(),
    "%#Search# 2 %#TabLine# %#TabLineTitle#EDIT %#TabLineSel#[unnamed]"
      .. string.rep(" ", 22)
      .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["caps the sections at forty columns"] = function()
  child.o.columns = 300
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/b/two.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/one.lua")

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua"
      .. string.rep(" ", 52)
      .. "%#TabLine#ALT b/two.lua"
  )
end

T["Statusline()"] = MiniTest.new_set()

T["Statusline()"]["shows the current branch"] = function()
  child.lua_func(stub_branch, { stdout = "main\n" })
  load_module()

  test_helpers.expect_eventually(statusline, "%#TabLine#BRANCH: main")
  MiniTest.expect.equality(child.lua_get [[_G.branch_calls]], {
    { name = "system", args = { { "git", "branch", "--show-current" } } },
  })
end

T["Statusline()"]["updates the branch when GitHeadChanged fires"] = function()
  child.lua_func(stub_branch, { stdout = "main\n" })
  load_module()
  test_helpers.expect_eventually(statusline, "%#TabLine#BRANCH: main")

  child.lua_func(stub_branch, { stdout = "feature\n" })
  child.lua [[vim.api.nvim_exec_autocmds("User", { pattern = "GitHeadChanged" })]]

  test_helpers.expect_eventually(statusline, "%#TabLine#BRANCH: feature")
  MiniTest.expect.equality(child.lua_get [[_G.branch_calls]], {
    { name = "system", args = { { "git", "branch", "--show-current" } } },
  })
end

T["Statusline()"]["shows [no branch] when git fails"] = function()
  child.lua_func(stub_branch, { err = "git branch --show-current failed. Error: fatal" })
  load_module()

  test_helpers.expect_eventually(statusline, "%#TabLine#BRANCH: [no branch]")
end

T["Statusline()"]["shows [no branch] when git reports no branch"] = function()
  child.lua_func(stub_branch, { stdout = "\n" })
  load_module()

  test_helpers.expect_eventually(statusline, "%#TabLine#BRANCH: [no branch]")
end

return T
