local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua [[require "shared.user_commands"]]
    end,
    post_once = child.stop,
  },
}

--- @param config_dir string
local stub_snippets_config_dir = function(config_dir)
  require("tests._helpers").mock_child(vim.fn, {
    stdpath = function(what_arg)
      if what_arg == "config" then
        return config_dir
      end

      return ""
    end,
  })
end

local make_snippets_config_dir = function()
  local config_dir = test_helpers.make_temp_dir()
  local snippets_dir = vim.fs.joinpath(config_dir, "snippets")
  vim.fn.mkdir(snippets_dir, "p")
  vim.fn.writefile({ "it(\"\", () => {", "", "});" }, vim.fs.joinpath(snippets_dir, "it.ts"))
  vim.fn.writefile(
    { "expect().not.toBeInTheDocument();" },
    vim.fs.joinpath(snippets_dir, "notToBeInTheDocument.ts")
  )

  return config_dir
end

local get_lines = function()
  return child.api.nvim_buf_get_lines(0, 0, -1, false)
end

T["PrintHighlights"] = function()
  local sandbox_dir = test_helpers.make_temp_dir()
  child.cmd("cd " .. vim.fn.fnameescape(sandbox_dir))
  child.api.nvim_set_hl(0, "UserCommandsTest", { bold = true })

  child.cmd "PrintHighlights"

  MiniTest.expect.equality(
    test_helpers.file_contains(
      vim.fs.joinpath(sandbox_dir, "highlights.txt"),
      "UserCommandsTest xxx cterm=bold gui=bold"
    ),
    true
  )
end

T["PrintRemaps"] = function()
  local sandbox_dir = test_helpers.make_temp_dir()
  child.cmd("cd " .. vim.fn.fnameescape(sandbox_dir))
  child.lua [[vim.keymap.set("n", "gzq", "<cmd>echo 1<CR>")]]

  child.cmd "PrintRemaps"

  MiniTest.expect.equality(
    test_helpers.file_contains(
      vim.fs.joinpath(sandbox_dir, "remaps.txt"),
      "n gzq * <Cmd>echo 1<CR>"
    ),
    true
  )
end

T["Format"] = MiniTest.new_set()

T["Format"]["formats and writes the current buffer"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "a", "b", "c" })
  child.bo.equalprg = [[sed -e 's/^/x/']]

  child.cmd "silent Format"

  test_helpers.expect_lines(child, { "xa", "xb", "xc" })
  MiniTest.expect.equality(vim.fn.readfile(path), { "xa", "xb", "xc" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["Format"]["restores the cursor position"] = function()
  child.lua_func(test_helpers.open_file_buffer, { "a", "b", "c" })
  child.bo.equalprg = [[sed -e 's/^/x/']]
  child.api.nvim_win_set_cursor(0, { 3, 0 })

  child.cmd "silent Format"

  test_helpers.expect_cursor(child, { 3, 0 })
end

T["Format"]["aborts for readonly buffers"] = function()
  child.lua_func(test_helpers.open_file_buffer, { "a" })
  child.bo.equalprg = [[sed -e 's/^/x/']]
  child.bo.readonly = true
  child.lua_func(test_helpers.stub_notify)

  child.cmd "silent Format"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } },
  })
  test_helpers.expect_lines(child, { "a" })
end

T["Format"]["aborts for buffers with a non-normal buftype"] = function()
  child.lua_func(test_helpers.open_scratch_buffer, { "a" }, { 1, 0 })
  child.bo.equalprg = [[sed -e 's/^/x/']]
  child.lua_func(test_helpers.stub_notify)

  child.cmd "silent Format"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, buftype is not normal", vim.log.levels.WARN } },
  })
  test_helpers.expect_lines(child, { "a" })
end

T["Format"]["aborts for buffers with no name"] = function()
  child.lua_func(test_helpers.open_buffer, { "a" })
  child.lua_func(test_helpers.stub_notify)

  child.cmd "silent Format"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, buf has no name", vim.log.levels.WARN } },
  })
  test_helpers.expect_lines(child, { "a" })
end

T["Snippet"] = MiniTest.new_set()

T["Snippet"]["lists the available triggers when no trigger is given"] = function()
  child.lua [[require("tests._helpers").mock_child(_G, { print = function() end }, "prints")]]

  child.cmd "Snippet"

  local prints = test_helpers.get_calls(child, "prints")
  local triggers = vim.tbl_map(
    --- @param print_arg MockCall
    function(print_arg)
      return print_arg.args[1]
    end,
    vim.list_slice(prints, 2)
  )

  MiniTest.expect.equality(prints[1], { name = "print", args = { "Available snippet triggers:" } })
  MiniTest.expect.equality(vim.fn.sort(triggers), {
    "af",
    "bef",
    "cal",
    "des",
    "doc",
    "eff",
    "fin",
    "its",
    "mem",
    "ndoc",
    "wai",
  })
end

T["Snippet"]["warns about unknown triggers"] = function()
  child.lua_func(test_helpers.open_scratch_buffer, { "current" }, { 1, 0 })
  child.lua_func(test_helpers.stub_notify)

  child.cmd "Snippet nope"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "nope is not a valid snippet trigger!", vim.log.levels.WARN } },
  })
  test_helpers.expect_lines(child, { "current" })
end

T["Snippet"]["replaces the current line with the snippet content"] = function()
  child.lua_func(stub_snippets_config_dir, make_snippets_config_dir())
  child.lua_func(test_helpers.open_scratch_buffer, { "  click(\"x\")" }, { 1, 0 })

  child.cmd "Snippet its"

  test_helpers.expect_eventually(get_lines, { "it(\"\", () => {", "", "});" })
  test_helpers.expect_cursor(child, { 1, 4 })
end

T["Snippet"]["keeps the text before the cursor"] = function()
  child.lua_func(stub_snippets_config_dir, make_snippets_config_dir())
  child.lua_func(test_helpers.open_scratch_buffer, { "  click(\"x\")" }, { 1, 2 })

  child.cmd "Snippet its"

  test_helpers.expect_eventually(get_lines, { "  it(\"\", () => {", "", "});" })
  test_helpers.expect_cursor(child, { 1, 6 })
end

T["Snippet"]["warns when the snippet file is missing"] = function()
  local config_dir = test_helpers.make_temp_dir()
  child.lua_func(stub_snippets_config_dir, config_dir)
  child.lua_func(test_helpers.open_scratch_buffer, { "  click(\"x\")" }, { 1, 2 })
  child.lua_func(test_helpers.stub_notify)

  child.cmd "Snippet its"

  test_helpers.expect_eventually(function()
    return test_helpers.get_calls(child, "notifications")
  end, {
    {
      name = "notify",
      args = {
        "Could not read snippet file " .. vim.fs.joinpath(config_dir, "snippets", "it.ts"),
        vim.log.levels.WARN,
      },
    },
  })
  test_helpers.expect_lines(child, { "  click(\"x\")" })
  test_helpers.expect_cursor(child, { 1, 2 })
end

T["Snippet"]["moves the cursor according to the snippet trigger"] = function()
  child.lua_func(stub_snippets_config_dir, make_snippets_config_dir())
  child.lua_func(test_helpers.open_scratch_buffer, { "  abc" }, { 1, 0 })

  child.cmd "Snippet ndoc"

  test_helpers.expect_eventually(get_lines, { "expect().not.toBeInTheDocument();" })
  test_helpers.expect_cursor(child, { 1, 7 })
end

return T
