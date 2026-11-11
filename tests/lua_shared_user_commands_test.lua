local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local T = MiniTest.new_set {
  hooks = {
    pre_once = function()
      require "shared.user_commands"
    end,
  },
}

local snippet_files = {
  ["it.ts"] = { "it(\"\", () => {", "", "});" },
  ["notToBeInTheDocument.ts"] = { "expect().not.toBeInTheDocument();" },
}

local stub_snippets_config_dir = function()
  local config_dir = test_helpers.make_temp_dir()
  local snippets_dir = vim.fs.joinpath(config_dir, "snippets")
  vim.fn.mkdir(snippets_dir, "p")
  for file, lines in pairs(snippet_files) do
    vim.fn.writefile(lines, vim.fs.joinpath(snippets_dir, file))
  end

  local original_stdpath = vim.fn.stdpath
  test_helpers.mock(vim.fn, {
    stdpath = function(what_arg)
      if what_arg == "config" then
        return config_dir
      end
      return original_stdpath(what_arg)
    end,
  })
end

T["defines the user commands"] = function()
  local commands = vim.api.nvim_get_commands {}

  MiniTest.expect.equality(commands.Format.name, "Format")
  MiniTest.expect.equality(commands.Format.nargs, "0")
  MiniTest.expect.equality(commands.PrintHighlights.name, "PrintHighlights")
  MiniTest.expect.equality(commands.PrintHighlights.nargs, "0")
  MiniTest.expect.equality(commands.PrintRemaps.name, "PrintRemaps")
  MiniTest.expect.equality(commands.PrintRemaps.nargs, "0")
  MiniTest.expect.equality(commands.Snippet.name, "Snippet")
  MiniTest.expect.equality(commands.Snippet.nargs, "*")
end

T["PrintHighlights"] = function()
  local sandbox_dir = test_helpers.chdir_to_sandbox()
  vim.api.nvim_set_hl(0, "UserCommandsTest", { bold = true })

  vim.cmd "PrintHighlights"

  MiniTest.expect.equality(
    test_helpers.file_contains(
      vim.fs.joinpath(sandbox_dir, "highlights.txt"),
      "UserCommandsTest xxx cterm=bold gui=bold"
    ),
    true
  )
end

T["PrintRemaps"] = function()
  local sandbox_dir = test_helpers.chdir_to_sandbox()
  vim.keymap.set("n", "gzq", "<cmd>echo 1<CR>")
  MiniTest.finally(function()
    vim.keymap.del("n", "gzq")
  end)

  vim.cmd "PrintRemaps"

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
  local path = test_helpers.open_file_buffer { "a", "b", "c" }
  vim.bo.equalprg = [[sed -e 's/^/x/']]

  vim.cmd "silent Format"

  MiniTest.expect.equality(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "xa", "xb", "xc" })
  MiniTest.expect.equality(vim.fn.readfile(path), { "xa", "xb", "xc" })
  MiniTest.expect.equality(vim.bo.modified, false)
end

T["Format"]["restores the cursor position"] = function()
  test_helpers.open_file_buffer { "a", "b", "c" }
  vim.bo.equalprg = [[sed -e 's/^/x/']]
  vim.api.nvim_win_set_cursor(0, { 3, 0 })

  vim.cmd "silent Format"

  MiniTest.expect.equality(vim.api.nvim_win_get_cursor(0), { 3, 0 })
end

T["Format"]["aborts for readonly buffers"] = function()
  test_helpers.open_file_buffer { "a" }
  vim.bo.equalprg = [[sed -e 's/^/x/']]
  vim.bo.readonly = true
  local notifications = test_helpers.mock(vim, { notify = function() end })

  vim.cmd "silent Format"

  MiniTest.expect.equality(notifications, {
    { name = "notify", args = { "Aborting, readonly", 3 } },
  })
  MiniTest.expect.equality(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "a" })
end

T["Format"]["aborts for buffers with a non-normal buftype"] = function()
  local buf_id = test_helpers.open_scratch_buffer({ "a" }, { 1, 0 })
  vim.bo[buf_id].equalprg = [[sed -e 's/^/x/']]
  local notifications = test_helpers.mock(vim, { notify = function() end })

  vim.cmd "silent Format"

  MiniTest.expect.equality(notifications, {
    { name = "notify", args = { "Aborting, buftype is not normal", 3 } },
  })
  MiniTest.expect.equality(vim.api.nvim_buf_get_lines(buf_id, 0, -1, false), { "a" })
end

T["Snippet"] = MiniTest.new_set()

T["Snippet"]["lists the available triggers when no trigger is given"] = function()
  local prints = test_helpers.mock(_G, { print = function() end })

  vim.cmd "Snippet"

  local triggers = {}
  for index = 2, #prints do
    table.insert(triggers, prints[index].args[1])
  end
  table.sort(triggers)

  MiniTest.expect.equality(prints[1], { name = "print", args = { "Available snippet triggers:" } })
  MiniTest.expect.equality(
    triggers,
    { "af", "bef", "cal", "des", "doc", "eff", "fin", "its", "mem", "ndoc", "wai" }
  )
end

T["Snippet"]["warns about unknown triggers"] = function()
  local buf_id = test_helpers.open_scratch_buffer({ "current" }, { 1, 0 })
  local notifications = test_helpers.mock(vim, { notify = function() end })

  vim.cmd "Snippet nope"

  MiniTest.expect.equality(notifications, {
    { name = "notify", args = { "nope is not a valid snippet trigger!", 3 } },
  })
  MiniTest.expect.equality(vim.api.nvim_buf_get_lines(buf_id, 0, -1, false), { "current" })
end

T["Snippet"]["replaces the current line with the snippet content"] = function()
  stub_snippets_config_dir()
  local buf_id = test_helpers.open_scratch_buffer({ "  click(\"x\")" }, { 1, 0 })

  vim.cmd "Snippet its"

  MiniTest.expect.equality(vim.api.nvim_buf_get_lines(buf_id, 0, -1, false), {
    "  it(\"\", () => {",
    "",
    "});",
  })
  MiniTest.expect.equality(vim.api.nvim_win_get_cursor(0), { 1, 6 })
end

T["Snippet"]["moves the cursor according to the snippet trigger"] = function()
  stub_snippets_config_dir()
  local buf_id = test_helpers.open_scratch_buffer({ "  abc" }, { 1, 0 })

  vim.cmd "Snippet ndoc"

  MiniTest.expect.equality(
    vim.api.nvim_buf_get_lines(buf_id, 0, -1, false),
    { "  expect().not.toBeInTheDocument();" }
  )
  MiniTest.expect.equality(vim.api.nvim_win_get_cursor(0), { 1, 9 })
end

return T
