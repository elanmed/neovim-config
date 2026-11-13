local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

-- TODO: do I want to use bundled prettier in the test? more realistic, more fragile
local prettier_command =
  vim.fs.joinpath(vim.fn.stdpath "config", "language_servers", "node_modules", ".bin", "prettier")

local diagnostic_signs = { priority = 999, text = { "!!", "•", "?", "•" } }

--- @param fn_name string
--- @param arg any
local run_module_fn = function(fn_name, arg)
  local module = require "feature_complete.vim_plugins.lsp"

  return vim.async.run(module[fn_name], arg):wait()
end

--- @class StageableName
--- @field name string?

--- @return StageableName
local get_stageable_name = function()
  local module = require "feature_complete.vim_plugins.lsp"

  return { name = vim.async.run(module.get_stageable_buffer_name):wait() }
end

local add_pack_dirs_to_rtp = function()
  local pack_dirs = vim.fn.globpath(vim.fn.stdpath "data" .. "/site/pack/*/opt", "*", true, true)
  for _, pack_dir in ipairs(pack_dirs) do
    if vim.fn.isdirectory(pack_dir) == 1 then
      vim.opt.rtp:append(pack_dir)
    end
  end
end

--- @class LspRequest
--- @field method string
--- @field params table

--- @class FakeLspClient
--- @field request fun(self: FakeLspClient, method: string, params: table, callback: fun(err: string?, result: lsp.TextEdit[]?): nil)

local stub_lsp_client = function()
  --- @type LspRequest[]
  local requests = {}
  --- @type FakeLspClient
  local client = {
    --- @param _ table
    --- @param method string
    --- @param params table
    --- @param callback fun(err: string?, result: lsp.TextEdit[]?): nil
    request = function(_, method, params, callback)
      table.insert(requests, { method = method, params = params })
      _G.lsp_request_callback = callback
    end,
  }

  _G.lsp_requests = requests
  require("tests._helpers").mock_child(vim.lsp, {
    get_clients = function()
      return { client }
    end,
  }, "lsp_get_clients_calls")
end

--- @class FormattingResponse
--- @field err string?
--- @field result lsp.TextEdit[]?

--- @param response FormattingResponse
--- @param switch_to_bufnr integer?
local stub_formatting_response = function(response, switch_to_bufnr)
  --- @type FakeLspClient
  local client = {
    --- @param callback fun(err: string?, result: lsp.TextEdit[]?): nil
    request = function(_, _, _, callback)
      if switch_to_bufnr ~= nil then
        vim.api.nvim_set_current_buf(switch_to_bufnr)
      end
      callback(response.err, response.result)
    end,
  }

  require("tests._helpers").mock_child(vim.lsp, {
    get_clients = function()
      return { client }
    end,
  })
end

--- @class FakeHoverClient
--- @field supports_method fun(self: FakeHoverClient, method: string): boolean

local stub_hover_client = function()
  --- @type FakeHoverClient
  local client = {
    supports_method = function(_, method)
      return method == "textDocument/hover"
    end,
  }

  require("tests._helpers").mock_child(vim.lsp, {
    get_clients = function()
      return { client }
    end,
  }, "lsp_get_clients_calls")
  require("tests._helpers").mock_child(vim.lsp.buf, { hover = function() end }, "hover_calls")
end

--- @class DiagnosticSeed
--- @field lnum integer
--- @field col integer
--- @field severity vim.diagnostic.Severity
--- @field message string

--- @param diagnostics DiagnosticSeed[]
local seed_diagnostics = function(diagnostics)
  vim.diagnostic.set(vim.api.nvim_create_namespace "lsp_test", 0, diagnostics)
end

--- @return string[]
local get_lsp_request_methods = function()
  --- @diagnostic disable-next-line: undefined-field
  local requests = _G.lsp_requests

  --- @param request_arg LspRequest
  return vim.tbl_map(function(request_arg)
    return request_arg.method
  end, requests)
end

--- @class DiagnosticConfig
--- @field signs vim.diagnostic.Opts.Signs?
--- @field underline boolean?
--- @field update_in_insert boolean?
--- @field virtual_lines boolean?

--- @return DiagnosticConfig
local get_diagnostic_config = function()
  --- @type vim.diagnostic.Opts
  local config = vim.diagnostic.config() or {}

  return {
    signs = config.signs,
    underline = config.underline,
    update_in_insert = config.update_in_insert,
    virtual_lines = config.virtual_lines,
  }
end

--- @class QuickfixListEntry
--- @field bufnr integer
--- @field lnum integer
--- @field end_lnum integer
--- @field text string

--- @class QuickfixListEntryWithFilename
--- @field filename string
--- @field lnum integer
--- @field end_lnum integer
--- @field text string

--- @param bufnr integer
--- @return string[]
local get_buffer_lines = function(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

--- @return QuickfixListEntryWithFilename[]
local get_quickfix_items = function()
  --- @param item_arg QuickfixListEntry
  return vim.tbl_map(function(item_arg)
    return {
      filename = vim.api.nvim_buf_get_name(item_arg.bufnr),
      lnum = item_arg.lnum,
      end_lnum = item_arg.end_lnum,
      text = item_arg.text,
    }
  end, vim.fn.getqflist())
end

--- @param what vim.fn.setqflist.what
local call_on_list = function(what)
  require("feature_complete.vim_plugins.lsp").on_list(what)
end

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.lua_func(add_pack_dirs_to_rtp)
      child.lua_func(test_helpers.stub_notify)
      child.lua [[require "feature_complete.vim_plugins.lsp"]]
    end,
    post_once = child.stop,
  },
}

--- @param unformatted string
--- @param formatted string
local apply_changes = function(unformatted, formatted)
  child.lua_func(run_module_fn, "apply_minimal_changes", {
    unformatted = unformatted,
    formatted = formatted,
    winnr = child.api.nvim_get_current_win(),
    bufnr = child.api.nvim_get_current_buf(),
  })
end

--- @param expected MockCall[]
local expect_notifications = function(expected)
  test_helpers.expect_eventually(function()
    return test_helpers.get_calls(child, "notifications")
  end, expected)
end

T["get_stageable_buffer_name"] = MiniTest.new_set()

T["get_stageable_buffer_name"]["returns the path of a readable normal buffer"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })

  MiniTest.expect.equality(child.lua_func(get_stageable_name), { name = path })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {})
end

T["get_stageable_buffer_name"]["warns and returns nil for an unnamed buffer"] = function()
  child.lua_func(test_helpers.open_buffer, { "first" })

  MiniTest.expect.equality(child.lua_func(get_stageable_name), {})
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Buffer has no name, cannot stage", vim.log.levels.WARN } },
  })
end

T["get_stageable_buffer_name"]["warns and returns nil for a buffer that is not normal"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/project/scratch.txt")
  child.bo.buftype = "nofile"

  MiniTest.expect.equality(child.lua_func(get_stageable_name), {})
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Not a normal buffer, cannot stage", vim.log.levels.WARN } },
  })
end

T["get_stageable_buffer_name"]["warns and returns nil when the file is not readable"] = function()
  child.lua_func(test_helpers.open_named_buffer, "/project/missing.lua")

  MiniTest.expect.equality(child.lua_func(get_stageable_name), {})
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "File is not readable, cannot stage", vim.log.levels.WARN } },
  })
end

T["get_stageable_buffer_name"]["writes a modified buffer before returning its name"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })

  MiniTest.expect.equality(child.lua_func(get_stageable_name), { name = path })
  MiniTest.expect.equality(
    { lines = child.fn.readfile(path), modified = child.bo.modified },
    { lines = { "first", "second" }, modified = false }
  )
end

T["write"] = MiniTest.new_set()

T["write"]["aborts for a readonly buffer"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.bo.readonly = true
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })

  MiniTest.expect.equality(child.lua_func(run_module_fn, "write"), false)
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } },
  })
  MiniTest.expect.equality(child.fn.readfile(path), { "first" })
end

T["write"]["aborts for a buffer that is not normal"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.bo.buftype = "nofile"
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })

  child.lua_func(run_module_fn, "write")

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Aborting, buftype is not normal", vim.log.levels.WARN } },
  })
  MiniTest.expect.equality(child.fn.readfile(path), { "first" })
end

T["write"]["writes a big file without formatting it"] = function()
  local path = test_helpers.make_files({ "big.lua" }, 20001)[1]
  child.lua_func(test_helpers.edit_file, path)
  child.api.nvim_buf_set_lines(0, 0, 1, false, { "replaced" })
  child.lua_func(test_helpers.stub_async_system, {})

  child.lua_func(run_module_fn, "write")

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Bigfile, writing", vim.log.levels.INFO } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {})
  MiniTest.expect.equality(child.fn.readfile(path, "", 1), { "replaced" })
end

T["write"]["formats a prettier filetype with the bundled prettier"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "const a=1;" })
  child.bo.filetype = "typescript"
  child.lua_func(test_helpers.stub_async_system, {
    [prettier_command] = {
      stdout = [[
const a = 1;
]],
    },
  })

  child.lua_func(run_module_fn, "write")

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    {
      name = "system",
      args = {
        { prettier_command, "--stdin-filepath", path },
        {
          stdin = [[
const a=1;
]],
          text = true,
        },
      },
    },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    {
      name = "notify",
      args = {
        ("[%s] applying minimal diff, writing"):format(prettier_command),
        vim.log.levels.INFO,
      },
    },
  })
  test_helpers.expect_lines(child, { "const a = 1;" })
  MiniTest.expect.equality(child.fn.readfile(path), { "const a = 1;" })
end

T["write"]["formats a lua file with stylua"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "local  a=1" })
  child.bo.filetype = "lua"
  child.lua_func(test_helpers.stub_async_system, {
    stylua = {
      stdout = [[
local a = 1
]],
    },
  })

  child.lua_func(run_module_fn, "write")

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    {
      name = "system",
      args = {
        { "stylua", "-" },
        {
          stdin = [[
local  a=1
]],
          text = true,
        },
      },
    },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "[stylua] applying minimal diff, writing", vim.log.levels.INFO } },
  })
  test_helpers.expect_lines(child, { "local a = 1" })
  MiniTest.expect.equality(child.fn.readfile(path), { "local a = 1" })
end

T["write"]["asks the LSP client to format an lsp filetype"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "int a=1;" })
  child.bo.filetype = "c"
  child.lua_func(stub_lsp_client)

  child.lua_func(run_module_fn, "write")

  MiniTest.expect.equality(test_helpers.get_calls(child, "lsp_get_clients_calls"), {
    { name = "get_clients", args = { { bufnr = 0, method = "textDocument/formatting" } } },
  })
  MiniTest.expect.equality(child.lua_func(get_lsp_request_methods), { "textDocument/formatting" })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {})
  MiniTest.expect.equality(child.fn.readfile(path), { "int a=1;" })
end

T["write"]["writes other filetypes directly"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })

  MiniTest.expect.equality(child.lua_func(run_module_fn, "write"), true)
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {})
  MiniTest.expect.equality(child.fn.readfile(path), { "first", "second" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["call_write"] = MiniTest.new_set()

T["call_write"]["writes the buffer and restores the saved view"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first", "second", "third" })
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
  local winnr = child.api.nvim_get_current_win()
  local bufnr = child.api.nvim_get_current_buf()
  local view = child.lua_get "vim.fn.winsaveview()"
  child.api.nvim_win_set_cursor(0, { 3, 2 })

  child.lua_func(run_module_fn, "call_write", { winnr = winnr, bufnr = bufnr, view = view })

  MiniTest.expect.equality(child.fn.readfile(path), { "one", "two", "three" })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["apply_minimal_changes"] = MiniTest.new_set()

T["apply_minimal_changes"]["replaces changed lines"] = function()
  local path =
    child.lua_func(test_helpers.open_file_buffer, { "local a = 1", "local b=2", "local c = 3" })

  apply_changes(
    [[
local a = 1
local b=2
local c = 3
]],
    [[
local a = 1
local b = 2
local c = 3
]]
  )

  test_helpers.expect_lines(child, { "local a = 1", "local b = 2", "local c = 3" })
  MiniTest.expect.equality(child.fn.readfile(path), { "local a = 1", "local b = 2", "local c = 3" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["apply_minimal_changes"]["applies insertions and deletions"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "keep", "remove", "keep2" })

  apply_changes(
    [[
keep
remove
keep2
]],
    [[
keep
keep2
inserted
]]
  )

  test_helpers.expect_lines(child, { "keep", "keep2", "inserted" })
  MiniTest.expect.equality(child.fn.readfile(path), { "keep", "keep2", "inserted" })
end

T["apply_minimal_changes"]["writes the buffer when nothing changed"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })

  apply_changes(
    [[
first
second
]],
    [[
first
second
]]
  )

  MiniTest.expect.equality(child.fn.readfile(path), { "first", "second" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["format_with_cli"] = MiniTest.new_set()

T["format_with_cli"]["applies the formatter output as minimal edits"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "local  a=1" })
  child.lua_func(test_helpers.stub_async_system, {
    stylua = {
      stdout = [[
local a = 1
]],
    },
  })

  child.lua_func(run_module_fn, "format_with_cli", { "stylua", "-" })

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "[stylua] applying minimal diff, writing", vim.log.levels.INFO } },
  })
  test_helpers.expect_lines(child, { "local a = 1" })
  MiniTest.expect.equality(child.fn.readfile(path), { "local a = 1" })
end

T["format_with_cli"]["writes the buffer when the formatter fails"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })
  child.lua_func(
    test_helpers.stub_async_system,
    { stylua = { err = "stylua failed. Error: boom" } }
  )

  child.lua_func(run_module_fn, "format_with_cli", { "stylua", "-" })

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "[stylua] non-zero exit code, writing", vim.log.levels.INFO } },
  })
  MiniTest.expect.equality(child.fn.readfile(path), { "first", "second" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["format_with_cli"]["writes the buffer when the formatter prints nothing"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })
  child.lua_func(test_helpers.stub_async_system, { stylua = {} })

  child.lua_func(run_module_fn, "format_with_cli", { "stylua", "-" })

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "[stylua] no stdout, writing", vim.log.levels.INFO } },
  })
  MiniTest.expect.equality(child.fn.readfile(path), { "first", "second" })
  MiniTest.expect.equality(child.bo.modified, false)
end

T["format_with_lsp"] = MiniTest.new_set()

T["format_with_lsp"]["writes the buffer when no client is attached"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "int a=1;" })
  child.bo.filetype = "c"
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "int b=2;" })

  child.lua_func(run_module_fn, "format_with_lsp")

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No LSP client, writing", vim.log.levels.INFO } },
  })
  MiniTest.expect.equality(child.fn.readfile(path), { "int a=1;", "int b=2;" })
end

T["format_with_lsp"]["writes the buffer when the request fails"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "int a=1;" })
  child.bo.filetype = "c"
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "int b=2;" })
  child.lua_func(stub_formatting_response, { err = "boom" })

  child.lua_func(run_module_fn, "format_with_lsp")

  expect_notifications {
    { name = "notify", args = { "[textDocument/formatting] error, writing", vim.log.levels.INFO } },
  }
  MiniTest.expect.equality(child.fn.readfile(path), { "int a=1;", "int b=2;" })
end

T["format_with_lsp"]["writes the buffer when the client returns no edits"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "int a=1;" })
  child.bo.filetype = "c"
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "int b=2;" })
  child.lua_func(stub_formatting_response, {})

  child.lua_func(run_module_fn, "format_with_lsp")

  expect_notifications {
    {
      name = "notify",
      args = { "[textDocument/formatting] no result, writing", vim.log.levels.INFO },
    },
  }
  MiniTest.expect.equality(child.fn.readfile(path), { "int a=1;", "int b=2;" })
end

T["format_with_lsp"]["applies a full replacement as minimal edits"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "local  a=1", "local b=2" })
  child.bo.filetype = "c"
  child.lua_func(stub_formatting_response, {
    result = {
      {
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = 2, character = 0 },
        },
        newText = [[
local a = 1
local b = 2
]],
      },
    },
  })

  child.lua_func(run_module_fn, "format_with_lsp")

  test_helpers.expect_eventually(function()
    return child.lua_get [[vim.api.nvim_buf_get_lines(0, 0, -1, false)]]
  end, { "local a = 1", "local b = 2" })
  expect_notifications {
    {
      name = "notify",
      args = { "[textDocument/formatting] applying minimal diff, writing", vim.log.levels.INFO },
    },
  }
  MiniTest.expect.equality(child.fn.readfile(path), { "local a = 1", "local b = 2" })
end

T["format_with_lsp"]["diffs the requested buffer when the current buffer changed"] = function()
  local other_bufnr = child.lua_func(test_helpers.open_buffer, { "keep", "keep2" })
  local path = child.lua_func(test_helpers.open_file_buffer, { "keep", "local  a=1", "keep2" })
  local bufnr = child.api.nvim_get_current_buf()
  child.bo.filetype = "c"
  child.lua_func(stub_formatting_response, {
    result = {
      {
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = 3, character = 0 },
        },
        newText = [[
keep
local a = 1
keep2
]],
      },
    },
  }, other_bufnr)

  child.lua_func(run_module_fn, "format_with_lsp")

  test_helpers.expect_eventually(function()
    return child.lua_func(get_buffer_lines, bufnr)
  end, { "keep", "local a = 1", "keep2" })
  MiniTest.expect.equality(child.lua_func(get_buffer_lines, other_bufnr), { "keep", "keep2" })
  MiniTest.expect.equality(child.fn.readfile(path), { "keep", "local a = 1", "keep2" })
end

T["format_with_lsp"]["applies partial edits directly"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "local a=1" })
  child.bo.filetype = "c"
  child.lua_func(stub_formatting_response, {
    result = {
      {
        range = {
          start = { line = 0, character = 7 },
          ["end"] = { line = 0, character = 8 },
        },
        newText = " = ",
      },
    },
  })

  child.lua_func(run_module_fn, "format_with_lsp")

  test_helpers.expect_eventually(function()
    return child.lua_get [[vim.api.nvim_buf_get_lines(0, 0, -1, false)]]
  end, { "local a = 1" })
  expect_notifications {
    {
      name = "notify",
      args = {
        "[textDocument/formatting] applying LSP edits directly, writing",
        vim.log.levels.INFO,
      },
    },
  }
  MiniTest.expect.equality(child.fn.readfile(path), { "local a = 1" })
end

T["Add"] = MiniTest.new_set()

T["Add"]["stages the current file with git add"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.lua_func(test_helpers.stub_async_system, { git = { stdout = "" } })

  child.cmd "Add"

  expect_notifications { { name = "notify", args = { "Staged", vim.log.levels.TRACE } } }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "add", "--", path } } },
  })
end

T["Add"]["does not stage a buffer without a name"] = function()
  child.lua_func(test_helpers.open_buffer, { "first" })
  child.lua_func(test_helpers.stub_async_system, {})

  child.cmd "Add"

  expect_notifications {
    { name = "notify", args = { "Buffer has no name, cannot stage", vim.log.levels.WARN } },
  }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {})
end

T["Add"]["notifies the error when git add fails"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.lua_func(test_helpers.stub_async_system, {
    git = { err = "git add failed. Error: boom" },
  })

  child.cmd "Add"

  expect_notifications {
    { name = "notify", args = { "git add failed. Error: boom", vim.log.levels.ERROR } },
  }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "add", "--", path } } },
  })
end

T["Add"]["does not stage a readonly buffer with unsaved changes"] = function()
  local path = child.lua_func(test_helpers.open_file_buffer, { "first" })
  child.bo.readonly = true
  child.api.nvim_buf_set_lines(0, 1, 1, false, { "second" })
  child.lua_func(test_helpers.stub_async_system, { git = { stdout = "" } })

  child.cmd "Add"

  expect_notifications {
    { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } },
  }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {})
  MiniTest.expect.equality(child.fn.readfile(path), { "first" })
end

T["Commit"] = MiniTest.new_set()

T["Commit"]["commits the current file with a prefixed message"] = function()
  local path = test_helpers.make_files({ "plugin.lua" })[1]
  child.lua_func(test_helpers.edit_file, path)
  child.lua_func(test_helpers.stub_async_system, {
    git = {
      stdout = [[
[:Commit] plugin.lua
 1 file changed, 1 insertion(+)
]],
    },
  })

  child.cmd "Commit"

  expect_notifications {
    { name = "notify", args = { "Committing…", vim.log.levels.INFO } },
    {
      name = "notify",
      args = {
        [[
[:Commit] plugin.lua
 1 file changed, 1 insertion(+)
]],
        vim.log.levels.TRACE,
      },
    },
  }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "add", "--", path } } },
    {
      name = "system",
      args = { { "git", "commit", "--only", "-m", "[:Commit] plugin.lua", "--", path } },
    },
  })
end

T["Commit"]["notifies the error when the commit fails"] = function()
  local path = test_helpers.make_files({ "plugin.lua" })[1]
  child.lua_func(test_helpers.edit_file, path)
  child.lua_func(test_helpers.stub_async_system, {
    git = { err = "git commit failed. Error: nothing to commit" },
  })

  child.cmd "Commit"

  expect_notifications {
    { name = "notify", args = { "Committing…", vim.log.levels.INFO } },
    {
      name = "notify",
      args = { "git commit failed. Error: nothing to commit", vim.log.levels.ERROR },
    },
  }
  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "add", "--", path } } },
    {
      name = "system",
      args = { { "git", "commit", "--only", "-m", "[:Commit] plugin.lua", "--", path } },
    },
  })
end

T["on_list"] = MiniTest.new_set()

T["on_list"]["keeps entries outside the current line, test files and imports"] = function()
  child.lua_func(test_helpers.open_buffer, { "local a = 1" })

  child.lua_func(call_on_list, {
    title = "References",
    items = {
      { filename = "/project/current.lua", lnum = 1, end_lnum = 1, text = "local a = 1" },
      { filename = "/project/other.test.lua", lnum = 2, end_lnum = 2, text = "local a = 1" },
      { filename = "/project/other.spec.lua", lnum = 2, end_lnum = 2, text = "local a = 1" },
      { filename = "/project/init.lua", lnum = 2, end_lnum = 2, text = "import a" },
      { filename = "/project/init.lua", lnum = 3, end_lnum = 3, text = "local a = require(" },
      { lnum = 2, end_lnum = 2, text = "local a = 1" },
      { filename = "/project/no_text.lua", lnum = 2, end_lnum = 2 },
      { filename = "/project/no_end_lnum.lua", lnum = 2, text = "local a = 1" },
      { filename = "/project/kept.lua", lnum = 2, end_lnum = 2, text = "local a = 1" },
      { filename = "/project/kept2.lua", lnum = 7, end_lnum = 8, text = "local b = 2" },
    },
  })

  MiniTest.expect.equality(child.lua_func(get_quickfix_items), {
    { filename = "/project/kept.lua", lnum = 2, end_lnum = 2, text = "local a = 1" },
    { filename = "/project/kept2.lua", lnum = 7, end_lnum = 8, text = "local b = 2" },
  })
  MiniTest.expect.equality(child.lua_get [[vim.fn.getqflist({ title = 0 }).title]], "References")
  MiniTest.expect.equality(child.bo.buftype, "quickfix")
end

T["on_list"]["warns when every entry is filtered out"] = function()
  child.lua_func(test_helpers.open_buffer, { "local a = 1" })

  child.lua_func(call_on_list, {
    items = {
      { filename = "/project/other.test.lua", lnum = 2, end_lnum = 2, text = "local a = 1" },
    },
  })

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No (filtered) references found", vim.log.levels.WARN } },
  })
  MiniTest.expect.equality(child.lua_func(get_quickfix_items), {})
  MiniTest.expect.equality(#child.api.nvim_list_wins(), 1)
end

T["<C-t>"] = MiniTest.new_set()

T["<C-t>"]["toggles virtual lines on and off"] = function()
  child.type_keys "<C-t>"

  MiniTest.expect.equality(child.lua_func(get_diagnostic_config), {
    signs = diagnostic_signs,
    underline = false,
    update_in_insert = false,
    virtual_lines = true,
  })

  child.type_keys "<C-t>"

  MiniTest.expect.equality(child.lua_func(get_diagnostic_config), {
    signs = diagnostic_signs,
    underline = false,
    update_in_insert = false,
    virtual_lines = false,
  })
end

T["<C-t>"]["notifies enabled over the VimEnter default"] = function()
  child.type_keys "<C-t>"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Virtual lines enabled", vim.log.levels.TRACE } },
  })
end

T["<C-t>"]["notifies disabled when turning them off"] = function()
  child.type_keys "<C-t>"
  child.type_keys "<C-t>"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "Virtual lines enabled", vim.log.levels.TRACE } },
    { name = "notify", args = { "Virtual lines disabled", vim.log.levels.OFF } },
  })
end

T["]d"] = MiniTest.new_set()

T["]d"]["jumps to the next diagnostic and wraps"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "first" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.WARN, message = "second" },
  })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]d"

  test_helpers.expect_cursor(child, { 4, 0 })

  child.type_keys "]d"

  test_helpers.expect_cursor(child, { 1, 0 })
end

T["]d"]["warns when the buffer has no diagnostics"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two" })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]d"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No ANY diagnostics", vim.log.levels.WARN } },
  })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["[d"] = MiniTest.new_set()

T["[d"]["jumps to the previous diagnostic"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "first" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.WARN, message = "second" },
  })
  child.api.nvim_win_set_cursor(0, { 5, 0 })

  child.type_keys "[d"

  test_helpers.expect_cursor(child, { 4, 0 })

  child.type_keys "[d"

  test_helpers.expect_cursor(child, { 1, 0 })
end

T["]w"] = MiniTest.new_set()

T["]w"]["skips errors when jumping to the next warning"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 1, col = 0, severity = vim.diagnostic.severity.ERROR, message = "error" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.WARN, message = "warning" },
  })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]w"

  test_helpers.expect_cursor(child, { 4, 0 })
end

T["]w"]["warns when the buffer has no warning diagnostics"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two" })
  child.lua_func(seed_diagnostics, {
    { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "error" },
  })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]w"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No WARN diagnostics", vim.log.levels.WARN } },
  })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["[w"] = MiniTest.new_set()

T["[w"]["skips errors when jumping to the previous warning"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 2, col = 0, severity = vim.diagnostic.severity.WARN, message = "warning" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.ERROR, message = "error" },
  })
  child.api.nvim_win_set_cursor(0, { 5, 0 })

  child.type_keys "[w"

  test_helpers.expect_cursor(child, { 3, 0 })
end

T["]e"] = MiniTest.new_set()

T["]e"]["skips warnings when jumping to the next error"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 1, col = 0, severity = vim.diagnostic.severity.WARN, message = "warning" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.ERROR, message = "error" },
  })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]e"

  test_helpers.expect_cursor(child, { 4, 0 })
end

T["]e"]["warns when the buffer has no error diagnostics"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two" })
  child.lua_func(seed_diagnostics, {
    { lnum = 0, col = 0, severity = vim.diagnostic.severity.WARN, message = "warning" },
  })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "]e"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No ERROR diagnostics", vim.log.levels.WARN } },
  })
  test_helpers.expect_cursor(child, { 1, 0 })
end

T["[e"] = MiniTest.new_set()

T["[e"]["skips warnings when jumping to the previous error"] = function()
  child.lua_func(test_helpers.open_buffer, { "one", "two", "three", "four", "five" })
  child.lua_func(seed_diagnostics, {
    { lnum = 2, col = 0, severity = vim.diagnostic.severity.ERROR, message = "error" },
    { lnum = 3, col = 0, severity = vim.diagnostic.severity.WARN, message = "warning" },
  })
  child.api.nvim_win_set_cursor(0, { 5, 0 })

  child.type_keys "[e"

  test_helpers.expect_cursor(child, { 3, 0 })
end

T["K"] = MiniTest.new_set()

T["K"]["asks the client for hover with a bordered float"] = function()
  child.lua_func(stub_hover_client)
  child.lua_func(test_helpers.open_file_buffer, { "foo" })

  child.type_keys "K"

  MiniTest.expect.equality(test_helpers.get_calls(child, "lsp_get_clients_calls"), {
    { name = "get_clients", args = { { bufnr = 0 } } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "hover_calls"), {
    { name = "hover", args = { { border = "single", max_width = 60 } } },
  })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {})
end

T["K"]["falls back to the tag under the cursor"] = function()
  local definition_path = test_helpers.write_temp_file [[
first
second
]]
  local source_path = test_helpers.write_temp_file [[
foo
bar
]]
  child.o.tags = test_helpers.write_temp_file("foo\t" .. definition_path .. "\t2\n")
  child.lua_func(test_helpers.edit_file, source_path)
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "K"

  MiniTest.expect.equality(child.api.nvim_buf_get_name(0), definition_path)
  test_helpers.expect_cursor(child, { 2, 0 })
  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "No LSP, falling back to ctags", vim.log.levels.INFO } },
  })
end

T["K"]["notifies the tag error when the fallback fails"] = function()
  child.lua_func(test_helpers.open_file_buffer, { "foo", "bar" })
  child.api.nvim_win_set_cursor(0, { 1, 0 })

  child.type_keys "K"

  local notifications = test_helpers.get_calls(child, "notifications")
  MiniTest.expect.equality(notifications[1], {
    name = "notify",
    args = { "No LSP, falling back to ctags", vim.log.levels.INFO },
  })
  MiniTest.expect.equality(notifications[2].name, "notify")
  MiniTest.expect.equality(notifications[2].args[2], vim.log.levels.ERROR)
  MiniTest.expect.equality(
    vim.endswith(notifications[2].args[1], "Vim(tag):E426: Tag not found: foo"),
    true
  )
end

return T
