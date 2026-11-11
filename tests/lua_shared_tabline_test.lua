local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.o.columns = 30
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

--- @class BranchStubResult
--- @field err string?
--- @field stdout string?

--- @param result BranchStubResult
local stub_branch = function(result)
  local helpers = require "helpers"

  require("tests._helpers").mock_child(helpers.async, {
    system = function()
      return vim.async.run(function()
        --- @diagnostic disable-next-line: redundant-return-value, return-type-mismatch
        return result.err, result.stdout
      end)
    end,
  }, "branch_calls")
end

T["invalidates the branch cache on GitHeadChanged"] = function()
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
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua       %#TabLine#ALT b/two.lua"
  )
end

T["Tabline()"]["truncates long buffer names from the left"] = function()
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/one.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/" .. string.rep("0123456789", 4))

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#…123456789      %#TabLine#ALT a/one.lua"
  )
end

T["Tabline()"]["shows [unnamed] for buffers without a name"] = function()
  load_module()
  child.lua_func(test_helpers.open_buffer)

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[unnamed]       %#TabLine#ALT "
  )
end

T["Tabline()"]["shows [terminal] for terminal buffers"] = function()
  load_module()
  child.lua_func(test_helpers.open_buffer)
  child.lua [[vim.fn.jobstart({ "true" }, { term = true })]]

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[terminal]      %#TabLine#ALT "
  )
end

T["Tabline()"]["hides the alternate buffer when it has the same relative name"] = function()
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/x/dir/f.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/two/y/dir/f.lua")

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#dir/f.lua       %#TabLine#ALT "
  )
end

T["Tabline()"]["shows the current tab page number when there are multiple tab pages"] = function()
  load_module()
  child.cmd "tabnew"

  MiniTest.expect.equality(
    tabline(),
    "%#Search# 2 %#TabLine# %#TabLineTitle#EDIT %#TabLineSel#[unnamed]       %#TabLine#ALT "
  )
end

T["Tabline()"]["pads fractional section lengths up"] = function()
  child.o.columns = 27
  load_module()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/b/two.lua")
  child.lua_func(test_helpers.open_named_buffer, "/root/one/a/one.lua")

  MiniTest.expect.equality(
    tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua      %#TabLine#ALT b/two.lua"
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
