local MiniTest = require "mini.test"
local h = require "helpers"
local test_helpers = require "tests._helpers"

local original_options

local T = MiniTest.new_set {
  hooks = {
    pre_once = function()
      original_options = {
        columns = vim.o.columns,
        showtabline = vim.o.showtabline,
        statusline = vim.o.statusline,
        tabline = vim.o.tabline,
      }

      require "shared.tabline"
    end,
    post_once = function()
      vim.o.columns = original_options.columns
      vim.o.showtabline = original_options.showtabline
      vim.o.statusline = original_options.statusline
      vim.o.tabline = original_options.tabline
      _G.Tabline = nil
      _G.Statusline = nil
      vim.api.nvim_del_augroup_by_name "InvalidateBranchCache"
    end,
  },
}

local stub_branch = function(err, stdout)
  return test_helpers.mock(h.async, {
    system = function()
      return vim.async.run(function()
        --- @diagnostic disable-next-line: redundant-return-value
        return err, stdout
      end)
    end,
  })
end

local fire_git_head_changed = function()
  vim.api.nvim_exec_autocmds("User", { pattern = "GitHeadChanged" })
end

T["setup"] = MiniTest.new_set()

T["setup"]["defines the global Tabline and Statusline functions"] = function()
  MiniTest.expect.equality(type(_G.Tabline), "function")
  MiniTest.expect.equality(type(_G.Statusline), "function")
end

T["setup"]["sets the tabline and statusline options"] = function()
  MiniTest.expect.equality(vim.o.showtabline, 2)
  MiniTest.expect.equality(vim.o.tabline, "%!v:lua.Tabline()")
  MiniTest.expect.equality(vim.o.statusline, "%!v:lua.Statusline()")
end

T["setup"]["invalidates the branch cache on GitHeadChanged"] = function()
  local autocmds = vim.api.nvim_get_autocmds {
    group = "InvalidateBranchCache",
    event = "User",
    pattern = "GitHeadChanged",
  }

  MiniTest.expect.equality(#autocmds, 1)
  MiniTest.expect.equality(autocmds[1].group_name, "InvalidateBranchCache")
  MiniTest.expect.equality(autocmds[1].event, "User")
  MiniTest.expect.equality(autocmds[1].pattern, "GitHeadChanged")
end

T["Tabline()"] = MiniTest.new_set {
  hooks = {
    pre_case = function()
      vim.o.columns = 60
    end,
  },
}

T["Tabline()"]["shows the current and the alternate buffer names"] = function()
  test_helpers.open_named_buffer "/root/one/b/two.lua"
  test_helpers.open_named_buffer "/root/one/a/one.lua"

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua"
      .. string.rep(" ", 22)
      .. "%#TabLine#ALT b/two.lua"
  )
end

T["Tabline()"]["truncates long buffer names from the left"] = function()
  test_helpers.open_named_buffer "/root/one/a/one.lua"
  test_helpers.open_named_buffer("/root/one/a/" .. string.rep("0123456789", 4))

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#…1234567890123456789"
      .. string.rep(" ", 11)
      .. "%#TabLine#ALT a/one.lua"
  )
end

T["Tabline()"]["shows [unnamed] for buffers without a name"] = function()
  test_helpers.open_buffer()

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[unnamed]" .. string.rep(" ", 22) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["shows [terminal] for terminal buffers"] = function()
  test_helpers.open_buffer()
  vim.fn.jobstart({ "true" }, { term = true })

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#[terminal]" .. string.rep(" ", 21) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["hides the alternate buffer when it has the same relative name"] = function()
  test_helpers.open_named_buffer "/root/one/x/dir/file.lua"
  test_helpers.open_named_buffer "/root/two/y/dir/file.lua"

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#dir/file.lua" .. string.rep(" ", 19) .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["shows the current tab page number when there are multiple tab pages"] = function()
  vim.cmd.tabnew()
  MiniTest.finally(function()
    vim.cmd.tabclose()
  end)

  MiniTest.expect.equality(
    _G.Tabline(),
    "%#Search# 2 %#TabLine# %#TabLineTitle#EDIT %#TabLineSel#[unnamed]"
      .. string.rep(" ", 22)
      .. "%#TabLine#ALT "
  )
end

T["Tabline()"]["caps the sections at forty columns"] = function()
  vim.o.columns = 300
  test_helpers.open_named_buffer "/root/one/b/two.lua"
  test_helpers.open_named_buffer "/root/one/a/one.lua"

  MiniTest.expect.equality(
    _G.Tabline(),
    " %#TabLineTitle#EDIT %#TabLineSel#a/one.lua"
      .. string.rep(" ", 52)
      .. "%#TabLine#ALT b/two.lua"
  )
end

T["Statusline()"] = MiniTest.new_set()

T["Statusline()"]["shows the current branch"] = function()
  local calls = stub_branch(nil, "main\n")

  fire_git_head_changed()

  test_helpers.expect_eventually(_G.Statusline, "%#TabLine#BRANCH: main")
  MiniTest.expect.equality(
    calls,
    { { name = "system", args = { { "git", "branch", "--show-current" } } } }
  )
end

T["Statusline()"]["shows [no branch] when git fails"] = function()
  stub_branch("git branch --show-current failed. Error: fatal: not a git repository", nil)

  fire_git_head_changed()

  test_helpers.expect_eventually(_G.Statusline, "%#TabLine#BRANCH: [no branch]")
end

T["Statusline()"]["shows [no branch] when git reports no branch"] = function()
  stub_branch(nil, "\n")

  fire_git_head_changed()

  test_helpers.expect_eventually(_G.Statusline, "%#TabLine#BRANCH: [no branch]")
end

return T
