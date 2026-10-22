vim.g.markdown_fenced_languages = {
  "bash",
  "css",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "lua",
  "ruby",
  "typescript",
  "typescriptreact",
}

vim.treesitter.start = function() end

local h = require "helpers"

--- @class CallWriteOpts
--- @field winnr number
--- @field bufnr number
--- @field view? vim.fn.winsaveview.ret

--- @param opts CallWriteOpts
local call_write = function(opts)
  vim.api.nvim_win_call(opts.winnr, function()
    vim.api.nvim_buf_call(opts.bufnr, function()
      if opts.view then
        vim.fn.winrestview(opts.view)
      end
      vim.cmd.write { mods = { silent = true } }
    end)
  end)
end

--- @class ApplyMinimalChangesOpts
--- @field unformatted string
--- @field formatted string
--- @field winnr number
--- @field bufnr number

--- @param opts ApplyMinimalChangesOpts
local apply_minimal_changes = function(opts)
  opts.formatted = opts.formatted:gsub("\n+$", "") .. "\n"

  --- @type DiffHunk[]
  local indices = vim.text.diff(opts.unformatted, opts.formatted, { result_type = "indices" })
  local edits = {}
  local formatted_lines = vim.split(opts.formatted, "\n")
  table.remove(formatted_lines)

  for _, raw_hunk in ipairs(indices) do
    local hunk = require("helpers").diff.unpack_hunk(raw_hunk)
    local new_text_lines = vim.list_slice(formatted_lines, hunk.start_new_1i, hunk.end_new_1i_incl)

    local new_text = (function()
      if hunk.is_deletion then
        return ""
      end
      -- lsp expects that every line in newText will end with a newline
      return table.concat(new_text_lines, "\n") .. "\n"
    end)()

    -- for deletions/replacement, line_x is starting from and including
    -- for insertions, line_x is after

    local start_line = (function()
      if hunk.is_insertion then
        return hunk.start_old_0i + 1
      end
      return hunk.start_old_0i
    end)()

    local end_line = (function()
      if hunk.is_insertion then
        return hunk.start_old_0i + 1
      end
      return hunk.end_old_0i_excl
    end)()

    table.insert(edits, {
      range = {
        start = { line = start_line, character = 0 },
        ["end"] = { line = end_line, character = 0 },
      },
      newText = new_text,
    })
  end
  local view = vim.fn.winsaveview()
  vim.lsp.util.apply_text_edits(edits, opts.bufnr, "utf-8")
  call_write { bufnr = opts.bufnr, winnr = opts.winnr, view = view }
end

--- @param cmd table
local format_with_cli = function(cmd)
  local unformatted = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n"
  local winnr = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  local result = h.async.system(cmd, {
    stdin = unformatted,
    text = true,
  })
  vim.async.sleep(1)

  if result.code ~= 0 then
    vim.notify(("[%s] non-zero exit code, writing"):format(cmd[1]), vim.log.levels.INFO)
    call_write { bufnr = bufnr, winnr = winnr }
    return
  end

  local formatted = result.stdout
  if formatted == nil then
    vim.notify(("[%s] no stdout, writing"):format(cmd[1]), vim.log.levels.INFO)
    call_write { bufnr = bufnr, winnr = winnr }
    return
  end

  vim.notify(("[%s] applying minimal diff, writing"):format(cmd[1]), vim.log.levels.INFO)
  apply_minimal_changes {
    unformatted = unformatted,
    formatted = formatted,
    winnr = winnr,
    bufnr = bufnr,
  }
end

local format_with_lsp = function()
  local clients = vim.lsp.get_clients {
    bufnr = 0,
    method = "textDocument/formatting",
  }

  if #clients == 0 then
    vim.notify("No LSP client, writing", vim.log.levels.INFO)
    return vim.cmd.write { mods = { silent = true } }
  end

  local winnr = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  local client = clients[1]
  client:request(
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params(),
    function(err, result)
      if err then
        return vim.schedule(function()
          vim.notify("[textDocument/formatting] error, writing", vim.log.levels.INFO)
          call_write { bufnr = bufnr, winnr = winnr }
        end)
      end

      if result == nil or #result == 0 then
        return vim.schedule(function()
          vim.notify("[textDocument/formatting] no result, writing", vim.log.levels.INFO)
          call_write { bufnr = bufnr, winnr = winnr }
        end)
      end

      local is_full_replace = (function()
        if #result == 1 then
          local range = result[1].range
          local line_count = vim.api.nvim_buf_line_count(bufnr)
          return range.start.line == 0
            and range.start.character == 0
            and range["end"].line >= line_count
        end
        return false
      end)()

      if is_full_replace then
        local unformatted = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n"
        local formatted = result[1].newText

        vim.schedule(function()
          vim.notify(
            "[textDocument/formatting] applying minimal diff, writing",
            vim.log.levels.INFO
          )
          apply_minimal_changes {
            unformatted = unformatted,
            formatted = formatted,
            winnr = winnr,
            bufnr = bufnr,
          }
        end)
      else
        vim.schedule(function()
          vim.notify(
            "[textDocument/formatting] applying LSP edits directly, writing",
            vim.log.levels.INFO
          )
          vim.lsp.util.apply_text_edits(result, bufnr, "utf-8")
          call_write { bufnr = bufnr, winnr = winnr }
        end)
      end
    end
  )
end

local prettier_ft = {
  "css",
  "graphql",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "less",
  "markdown",
  "scss",
  "typescript",
  "typescriptreact",
  "yaml",
  "mdx",
}

local stylua_ft = {
  "lua",
}

local lsp_ft = {
  "c",
  "cpp",
  "sh",
  "zsh",
}

local write = function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return vim.notify("Aborting", vim.log.levels.ERROR)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  if h.utils.is_big_file { bname = bufname, line_count = line_count } then
    vim.notify("Bigfile, writing", vim.log.levels.INFO)
    vim.cmd.write { mods = { silent = true } }
  elseif vim.list_contains(prettier_ft, vim.bo.filetype) then
    format_with_cli {
      vim.fs.joinpath(
        vim.fn.stdpath "config",
        "language_servers",
        "node_modules",
        ".bin",
        "prettier"
      ),
      "--stdin-filepath",
      vim.api.nvim_buf_get_name(0),
    }
  elseif vim.list_contains(stylua_ft, vim.bo.filetype) then
    format_with_cli { "stylua", "-" }
  elseif vim.list_contains(lsp_ft, vim.bo.filetype) then
    format_with_lsp()
  else
    vim.cmd.write()
  end
end

vim.keymap.set("n", "s", function()
  vim.async.run("s_keymap_task", write)
end)

local function get_stageable_buffer_name()
  local name = vim.api.nvim_buf_get_name(0)

  if name == "" then
    vim.notify("Buffer has no name, cannot stage", vim.log.levels.WARN)
    return nil
  end

  if vim.bo.buftype ~= "" then
    vim.notify("Not a normal buffer, cannot stage", vim.log.levels.WARN)
    return nil
  end

  if vim.fn.filereadable(name) == require("helpers").vimscript_false then
    vim.notify("File is not readable, cannot stage", vim.log.levels.WARN)
    return nil
  end

  if vim.bo.modified then
    write()
  end

  return name
end

local function stage_file(name)
  h.async.system { "git", "add", "--", name }
end

vim.api.nvim_create_user_command("Add", function()
  vim.async.run("git_add_task", function()
    local name = get_stageable_buffer_name()

    if name == nil then
      return
    end

    stage_file(name)
    vim.notify("Staged", vim.log.levels.TRACE)
  end)
end, {})

vim.api.nvim_create_user_command("Commit", function()
  vim.async.run("git_stage_commit_task", function()
    local name = get_stageable_buffer_name()
    if name == nil then
      return
    end

    local commit_message = h.async.ui_input { prompt = "Commit message: " }

    if commit_message == nil or commit_message == "" then
      vim.notify("[Commit aborted]", vim.log.levels.INFO)
      return
    end

    stage_file(name)

    vim.notify("Committing…", vim.log.levels.INFO)
    local commit_result =
      h.async.system { "git", "commit", "--only", "-m", commit_message, "--", name }
    local commit_succeeded = commit_result.code == 0

    vim.notify(
      commit_succeeded and commit_result.stdout or commit_result.stderr,
      commit_succeeded and vim.log.levels.TRACE or vim.log.levels.ERROR
    )
  end)
end, {})

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "!!",
    [vim.diagnostic.severity.INFO] = "?",
    [vim.diagnostic.severity.HINT] = "•",
    [vim.diagnostic.severity.WARN] = "•",
  },
  priority = 999,
}

local base_diagnostic_config = {
  underline = false,
  signs = signs,
  update_in_insert = false,
}

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.diagnostic.config(
      vim.tbl_extend("error", base_diagnostic_config, { virtual_lines = false })
    )
  end,
})

local function toggle_virtual_lines()
  local current_virtual_lines = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config(
    vim.tbl_extend("error", base_diagnostic_config, { virtual_lines = not current_virtual_lines })
  )

  if current_virtual_lines == nil then
    vim.notify("Virtual lines enabled", vim.log.levels.TRACE)
  else
    vim.notify("Virtual lines disabled", vim.log.levels.OFF)
  end
end

vim.keymap.set({ "i", "n" }, "<C-t>", toggle_virtual_lines, { desc = "Toggle virtual lines" })
vim.keymap.set("i", "<C-s>", function()
  vim.lsp.buf.signature_help { border = "single" }
end, { desc = "LSP signature help" })

--- @param what vim.fn.setqflist.what
local on_list = function(what)
  local row_1i = unpack(vim.api.nvim_win_get_cursor(0))

  local basename_regs = { "%.test%.", "%.spec%." }
  local text_regs = { "^import ", " = require%(*$" }

  local filtered = vim.tbl_filter(function(entry)
    -- ignore col, lsp references will include entries from the same line but shift the col
    -- to the beginning of the fn
    local start_row_1i = entry.lnum
    local end_row_1i_incl = entry.end_lnum

    if start_row_1i == nil or end_row_1i_incl == nil then
      return false
    end
    if row_1i >= start_row_1i and row_1i <= end_row_1i_incl then
      return false
    end

    if entry.filename == nil then
      return false
    end

    local basename = vim.fs.basename(entry.filename)
    if basename == nil then
      return false
    end

    for _, reg in ipairs(basename_regs) do
      if basename:match(reg) ~= nil then
        return false
      end
    end

    if entry.text == nil then
      return false
    end
    for _, reg in ipairs(text_regs) do
      if entry.text:match(reg) ~= nil then
        return false
      end
    end

    return true
  end, what.items)
  what.items = filtered

  if #what.items == 0 then
    return vim.notify("No (filtered) references found", vim.log.levels.WARN)
  end

  vim.fn.setqflist({}, " ", what)
  vim.cmd.copen()
end

vim.keymap.set("n", "glr", function()
  vim.lsp.buf.references(nil, { on_list = on_list })
end, { desc = "LSP go to filtered references" })
vim.keymap.set("n", "gle", function()
  vim.lsp.buf.references()
end, { desc = "LSP go to default references" })
vim.keymap.set("n", "gla", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP code action" })
vim.keymap.set("n", "gly", function()
  vim.lsp.buf.type_definition()
end, { desc = "LSP go to type definition" })
vim.keymap.set("n", "K", function()
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client:supports_method "textDocument/hover" then
      return vim.lsp.buf.hover { border = "single", max_width = 60 }
    end
  end
  vim.notify("No LSP, falling back to ctags", vim.log.levels.INFO)
  vim.cmd.wincmd "]"
end, { desc = "LSP hover" })
vim.keymap.set({ "n", "i" }, "<C-c>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
    if is_floating then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "Close floating windows" })

--- @param direction "next" | "prev"
--- @param severity? vim.diagnostic.Severity
local function next_prev_diagnostic(direction, severity)
  local diagnostics = vim.diagnostic.get(0, severity and { severity = severity } or nil)

  if vim.tbl_count(diagnostics) == 0 then
    vim.notify(
      string.format("No %s diagnostics", vim.diagnostic.severity[severity] or "ANY"),
      vim.log.levels.ERROR
    )
    return
  end

  vim.diagnostic.jump { severity = severity, count = direction == "next" and 1 or -1 }
end
vim.keymap.set("n", "]d", function()
  next_prev_diagnostic "next"
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
  next_prev_diagnostic "prev"
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "]w", function()
  next_prev_diagnostic("next", vim.diagnostic.severity.WARN)
end, { desc = "Next warning diagnostic" })
vim.keymap.set("n", "[w", function()
  next_prev_diagnostic("prev", vim.diagnostic.severity.WARN)
end, { desc = "Next warning diagnostic" })
vim.keymap.set("n", "]e", function()
  next_prev_diagnostic("next", vim.diagnostic.severity.ERROR)
end, { desc = "Next error diagnostic" })
vim.keymap.set("n", "[e", function()
  next_prev_diagnostic("prev", vim.diagnostic.severity.ERROR)
end, { desc = "Next error diagnostic" })

vim.lsp.enable {
  "ruby_lsp",
  "bashls",
  "lua_ls",
  "vimls",
  "clangd",
  "ts_ls",
  "eslint",
}
