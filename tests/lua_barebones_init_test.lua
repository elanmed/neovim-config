local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
    end,
    post_once = child.stop,
  },
}

local load_config = function()
  child.lua [[require "barebones"]]
end

--- @param cwd string
local stub_cwd = function(cwd)
  require("tests._helpers").mock_child(vim.uv, {
    cwd = function()
      return cwd
    end,
  })
end

--- @param cwd string
local stub_missing_relpath = function(cwd)
  require("tests._helpers").mock_child(vim.uv, {
    cwd = function()
      return cwd
    end,
  })
  require("tests._helpers").mock_child(vim.fs, {
    relpath = function()
      return nil
    end,
  })
end

--- @class FdStubOpts
--- @field executable integer
--- @field files string[]?

--- @param opts FdStubOpts
local stub_fd = function(opts)
  require("tests._helpers").mock_child(vim.fn, {
    executable = function()
      return opts.executable
    end,
    systemlist = function()
      return opts.files
    end,
  })
end

--- @class SelectStubOpts
--- @field choice? any

--- The recorded calls hold the `vim.ui.select` options, whose `format_item` is a function, so
-- they cannot be read back from the parent: publish the serializable part on `_G` instead.
--- @param opts SelectStubOpts
local stub_select = function(opts)
  require("tests._helpers").mock_child(vim.ui, {
    select = function(items, select_opts, on_choice)
      _G.selected_items = items
      _G.selected_formatted_items = vim.tbl_map(select_opts.format_item, items)
      on_choice(opts.choice)
    end,
  })
end

--- @class BufferFixtures
--- @field named integer[]
--- @field unnamed integer
--- @field unlisted integer
--- @field unloaded integer

--- @param paths string[] four file paths
--- @return BufferFixtures
local make_buffer_fixtures = function(paths)
  local fixtures = { named = {} }

  for index = 1, 2 do
    vim.cmd.edit { args = { paths[index] }, mods = { silent = true } }
    table.insert(fixtures.named, vim.api.nvim_get_current_buf())
  end

  fixtures.unnamed = vim.api.nvim_create_buf(true, false)

  vim.cmd.edit { args = { paths[3] }, mods = { silent = true } }
  fixtures.unlisted = vim.api.nvim_get_current_buf()
  vim.bo[fixtures.unlisted].buflisted = false

  vim.cmd.edit { args = { paths[4] }, mods = { silent = true } }
  fixtures.unloaded = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_buf(fixtures.named[2])
  vim.api.nvim_buf_delete(fixtures.unloaded, { unload = true })

  return fixtures
end

--- @param path string
--- @param mark string
--- @param lnum integer
local set_mark = function(path, mark, lnum)
  vim.cmd.edit { args = { path }, mods = { silent = true } }
  vim.fn.setpos("'" .. mark, { vim.api.nvim_get_current_buf(), lnum, 1, 0 })
end

T["K"] = MiniTest.new_set()

T["K"]["jumps to the tag under the cursor in a split window"] = function()
  load_config()
  local def_path = test_helpers.write_temp_file "first\nsecond\n"
  local source_path = test_helpers.write_temp_file "foo\nbar\n"
  child.o.tags = test_helpers.write_temp_file("foo\t" .. def_path .. "\t2\n")
  child.lua_func(test_helpers.edit_file, source_path)

  child.type_keys "K"

  MiniTest.expect.equality(#child.api.nvim_tabpage_list_wins(0), 2)
  MiniTest.expect.equality(child.api.nvim_buf_get_name(0), def_path)
  test_helpers.expect_cursor(child, { 2, 0 })
end

T["<leader>b"] = MiniTest.new_set()

T["<leader>b"]["lists only loaded, listed, and named buffers"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua", "d.lua" }
  local fixtures = child.lua_func(make_buffer_fixtures, paths)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, { choice = fixtures.named[1] })

  child.type_keys "\\b"

  MiniTest.expect.equality(test_helpers.get_calls(child, "selected_items"), fixtures.named)
end

T["<leader>b"]["formats buffers relative to the working directory"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua", "d.lua" }
  child.lua_func(make_buffer_fixtures, paths)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\b"

  MiniTest.expect.equality(
    test_helpers.get_calls(child, "selected_formatted_items"),
    { "a.lua", "b.lua" }
  )
end

T["<leader>b"]["switches to the selected buffer"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua", "d.lua" }
  local fixtures = child.lua_func(make_buffer_fixtures, paths)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, { choice = fixtures.named[1] })

  child.type_keys "\\b"

  MiniTest.expect.equality(child.api.nvim_get_current_buf(), fixtures.named[1])
end

T["<leader>b"]["keeps the current buffer when the selection is cancelled"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua", "d.lua" }
  local fixtures = child.lua_func(make_buffer_fixtures, paths)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\b"

  MiniTest.expect.equality(child.api.nvim_get_current_buf(), fixtures.named[2])
end

T["<leader>b"]["warns when the relative path is unavailable"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua", "d.lua" }
  child.lua_func(make_buffer_fixtures, paths)
  child.lua_func(stub_missing_relpath, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\b"

  MiniTest.expect.equality(test_helpers.get_calls(child, "selected_formatted_items"), { "", "" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "relpath is nil", vim.log.levels.WARN } },
    { name = "notify", args = { "relpath is nil", vim.log.levels.WARN } },
  })
end

T["<leader>l"] = MiniTest.new_set()

T["<leader>l"]["lists the marks inside the working directory"] = function()
  load_config()
  local paths = test_helpers.make_files { "a/f.lua", "a/g.lua", "b/h.lua" }
  child.lua_func(set_mark, paths[1], "A", 7)
  child.lua_func(set_mark, paths[2], "B", 3)
  child.lua_func(set_mark, paths[3], "C", 5)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\l"

  MiniTest.expect.equality(test_helpers.get_calls(child, "selected_items"), {
    { name = "A", lnum = 7, file = paths[1] },
    { name = "B", lnum = 3, file = paths[2] },
  })
end

T["<leader>l"]["formats marks as the name and relative path"] = function()
  load_config()
  local paths = test_helpers.make_files { "a/f.lua", "a/g.lua" }
  child.lua_func(set_mark, paths[1], "A", 7)
  child.lua_func(set_mark, paths[2], "B", 3)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\l"

  MiniTest.expect.equality(
    test_helpers.get_calls(child, "selected_formatted_items"),
    { "A|f.lua", "B|g.lua" }
  )
end

T["<leader>l"]["jumps to the selected mark"] = function()
  load_config()
  local paths = test_helpers.make_files { "a/f.lua", "a/g.lua" }
  child.lua_func(set_mark, paths[1], "A", 7)
  child.lua_func(set_mark, paths[2], "B", 3)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, { choice = { name = "B", lnum = 3, file = paths[2] } })

  child.type_keys "\\l"

  MiniTest.expect.equality(child.api.nvim_buf_get_name(0), paths[2])
  test_helpers.expect_cursor(child, { 3, 0 })
end

T["<leader>l"]["keeps the cursor when the selection is cancelled"] = function()
  load_config()
  local paths = test_helpers.make_files { "a/f.lua", "a/g.lua" }
  child.lua_func(set_mark, paths[1], "A", 7)
  child.lua_func(test_helpers.edit_file, paths[2])
  child.api.nvim_win_set_cursor(0, { 5, 0 })
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\l"

  MiniTest.expect.equality(child.api.nvim_buf_get_name(0), paths[2])
  test_helpers.expect_cursor(child, { 5, 0 })
end

T["<leader>l"]["excludes marks outside the working directory"] = function()
  load_config()
  local paths = test_helpers.make_files { "a/f.lua", "ab/g.lua" }
  child.lua_func(set_mark, paths[1], "A", 7)
  child.lua_func(set_mark, paths[2], "B", 4)
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\l"

  MiniTest.expect.equality(test_helpers.get_calls(child, "selected_items"), {
    { name = "A", lnum = 7, file = paths[1] },
  })
end

T["s"] = MiniTest.new_set()

T["s"]["writes the buffer to disk"] = function()
  load_config()
  local path = test_helpers.write_temp_file "1\n2\n"
  child.lua_func(test_helpers.edit_file, path)
  child.api.nvim_buf_set_lines(0, 0, 1, false, { "changed" })

  child.type_keys "s"

  MiniTest.expect.equality(vim.fn.readfile(path), { "changed", "2" })
end

T["s"]["aborts for a readonly buffer"] = function()
  load_config()
  local path = test_helpers.write_temp_file "1\n2\n"
  child.lua_func(test_helpers.edit_file, path)
  child.bo.readonly = true
  child.api.nvim_buf_set_lines(0, 0, 1, false, { "changed" })
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "s"

  MiniTest.expect.equality(vim.fn.readfile(path), { "1", "2" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } },
  })
end

T["s"]["aborts for a buffer with a non-empty buftype"] = function()
  load_config()
  child.lua_func(test_helpers.open_scratch_buffer, { "abc" }, { 1, 0 })
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "s"

  test_helpers.expect_lines(child, { "abc" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, buftype is not normal", vim.log.levels.WARN } },
  })
end

T["'findfunc'"] = MiniTest.new_set()

T["'findfunc'"]["points to FdFindFiles when fd is executable"] = function()
  child.lua_func(stub_fd, { executable = 1 })
  load_config()

  MiniTest.expect.equality({
    findfunc = child.o.findfunc,
    finder = child.lua_get [[type(_G.FdFindFiles)]],
  }, { findfunc = "v:lua.FdFindFiles", finder = "function" })
end

T["'findfunc'"]["stays empty when fd is missing"] = function()
  child.lua_func(stub_fd, { executable = 0 })
  load_config()

  MiniTest.expect.equality({
    findfunc = child.o.findfunc,
    finder = child.lua_get [[type(_G.FdFindFiles)]],
  }, { findfunc = "", finder = "nil" })
end

T["FdFindFiles()"] = MiniTest.new_set()

T["FdFindFiles()"]["fuzzily matches the files reported by fd"] = function()
  child.lua_func(stub_fd, {
    executable = 1,
    files = { "lua/alpha.lua", "lua/beta.lua", "test/alpha_spec.lua" },
  })
  load_config()

  MiniTest.expect.equality(child.lua_get [[_G.FdFindFiles("alpha.lua")]], {
    "lua/alpha.lua",
    "test/alpha_spec.lua",
  })
end

return T
