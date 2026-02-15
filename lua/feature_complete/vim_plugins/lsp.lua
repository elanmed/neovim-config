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
      vim.cmd.write { mods = { silent = true, }, }
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
  opts.formatted = opts.formatted:gsub("\n$", "") .. "\n"
  opts.unformatted = opts.unformatted:gsub("\n$", "") .. "\n"

  --- @type integer[][]
  local indices = vim.text.diff(opts.unformatted, opts.formatted, { result_type = "indices", })
  local edits = {}
  local tbl_formatted = vim.split(opts.formatted, "\n")
  table.remove(tbl_formatted)

  for _, hunk in ipairs(indices) do
    local start_unformatted_1i, count_unformatted, start_formatted_1i, count_formatted = unpack(hunk)
    local end_formatted_1i_excl = start_formatted_1i + count_formatted
    local end_formatted_1i_incl = end_formatted_1i_excl - 1

    local start_unformatted_0i = start_unformatted_1i - 1
    local end_unformatted_0i_excl = start_unformatted_0i + count_unformatted

    local new_text_lines = vim.list_slice(tbl_formatted, start_formatted_1i, end_formatted_1i_incl)

    local is_deletion = count_formatted == 0
    local new_text = (function()
      if is_deletion then return "" end
      -- lsp expects that every line in `newText` will end with a newline
      return table.concat(new_text_lines, "\n") .. "\n"
    end)()

    -- for deletions/replacement, line_x is `starting from and including`
    -- for insertions, line_x is `after`
    local is_insertion = count_unformatted == 0

    local start_line = (function()
      if is_insertion then return start_unformatted_0i + 1 end
      return start_unformatted_0i
    end)()

    local end_line = (function()
      if is_insertion then return start_unformatted_0i + 1 end
      return end_unformatted_0i_excl
    end)()

    table.insert(edits, {
      range = {
        start = { line = start_line, character = 0, },
        ["end"] = { line = end_line, character = 0, },
      },
      newText = new_text,
    })
  end

  local view = vim.fn.winsaveview()
  vim.lsp.util.apply_text_edits(edits, opts.bufnr, "utf-8")
  call_write { bufnr = opts.bufnr, winnr = opts.winnr, view = view, }
end

local format_with_prettier = function()
  local unformatted = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local winnr = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.system(
    { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(0), },
    {
      stdin = unformatted,
      text = true,
    },
    function(result)
      if result.code ~= 0 then
        return vim.schedule(function()
          h.notify.doing "[prettier] non-zero exit code, writing"
          call_write { bufnr = bufnr, winnr = winnr, }
        end)
      end

      local formatted = result.stdout
      if formatted == nil then
        return vim.schedule(function()
          h.notify.doing "[prettier] no stdout, writing"
          call_write { bufnr = bufnr, winnr = winnr, }
        end)
      end

      vim.schedule(function()
        h.notify.doing "[prettier] applying minimal diff, writing"
        apply_minimal_changes { unformatted = unformatted, formatted = formatted, winnr = winnr, bufnr = bufnr, }
      end)
    end)
end

local format_with_lsp = function()
  local clients = vim.lsp.get_clients {
    bufnr = 0,
    method = "textDocument/formatting",
  }

  if #clients == 0 then
    h.notify.doing "No LSP client, writing"
    return vim.cmd.write { mods = { silent = true, }, }
  end

  local winnr = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  local client = clients[1]
  client:request("textDocument/formatting", vim.lsp.util.make_formatting_params(), function(err, result)
    if err then
      return vim.schedule(function()
        h.notify.doing "[textDocument/formatting] error, writing"
        call_write { bufnr = bufnr, winnr = winnr, }
      end)
    end

    if not result or #result == 0 then
      return vim.schedule(function()
        h.notify.doing "[textDocument/formatting] no result, writing"
        call_write { bufnr = bufnr, winnr = winnr, }
      end)
    end

    local is_full_replace = (function()
      if #result == 1 then
        local range = result[1].range
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        return range.start.line == 0 and range.start.character == 0 and range["end"].line >= line_count
      end
      return false
    end)()

    if is_full_replace then
      local unformatted = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      local formatted = result[1].newText

      vim.schedule(function()
        h.notify.doing "[textDocument/formatting] applying minimal diff, writing"
        apply_minimal_changes { unformatted = unformatted, formatted = formatted, winnr = winnr, bufnr = bufnr, }
      end)
    else
      vim.schedule(function()
        h.notify.doing "[textDocument/formatting] applying LSP edits directly, writing"
        vim.lsp.util.apply_text_edits(result, bufnr, "utf-8")
        call_write { bufnr = bufnr, winnr = winnr, }
      end)
    end
  end)
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

local lsp_ft = {
  "lua",
  "sh",
  "zsh",
}

vim.keymap.set("n", "<bs>", function() h.notify.error "Use s instead!" end)
vim.keymap.set("n", "s", function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return h.notify.error "Aborting"
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  local one_pt_five_mb = 1.5 * 1024 * 1024
  if vim.fn.getfsize(bufname) > one_pt_five_mb or line_count > 5000 then
    h.notify.doing "Bigfile, writing"
    vim.cmd.write { mods = { silent = true, }, }
  elseif vim.list_contains(prettier_ft, vim.bo.filetype) then
    format_with_prettier()
  elseif vim.list_contains(lsp_ft, vim.bo.filetype) then
    format_with_lsp()
  else
    vim.cmd.write()
  end
end)

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "!!",
    [vim.diagnostic.severity.INFO] = "?",
    [vim.diagnostic.severity.HINT] = "•",
    [vim.diagnostic.severity.WARN] = "•",
  },
  priority = 9999,
}

local base_diagnostic_config = {
  underline = false,
  signs = signs,
  update_in_insert = false,
}

vim.diagnostic.config(
  vim.tbl_extend("error", base_diagnostic_config, { virtual_lines = false, })
)

local function toggle_virtual_lines()
  local current_virtual_lines = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config(
    vim.tbl_extend("error", base_diagnostic_config, { virtual_lines = not current_virtual_lines, })
  )

  if not current_virtual_lines then
    h.notify.toggle_on "Virtual lines enabled"
  else
    h.notify.toggle_off "Virtual lines disabled"
  end
end

vim.keymap.set({ "i", "n", }, "<C-t>", toggle_virtual_lines, { desc = "Toggle virtual lines", })
vim.keymap.set("i", "<C-s>", function() vim.lsp.buf.signature_help { border = "single", } end,
  { desc = "LSP signature help", }
)
vim.keymap.set("n", "glr", vim.lsp.buf.references, { desc = "LSP go to references", })
vim.keymap.set("n", "gli", vim.lsp.buf.definition, { desc = "LSP go to definition", })
vim.keymap.set("n", "gla", vim.lsp.buf.code_action, { desc = "LSP code action", })
vim.keymap.set("n", "gly", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP hover", })
vim.keymap.set({ "n", "i", }, "<C-c>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local is_floating = vim.api.nvim_win_get_config(win).relative == "win"
    if is_floating then vim.api.nvim_win_close(win, false) end
  end
end, { desc = "Close floating windows", })

--- @param direction "next" | "prev"
--- @param severity? vim.diagnostic.Severity
local function next_prev_diagnostic(direction, severity)
  local diagnostics = vim.diagnostic.get(0, severity and { severity = severity, } or nil)

  if vim.tbl_count(diagnostics) == 0 then
    h.notify.error(string.format("No %s diagnostics", vim.diagnostic.severity[severity] or "ANY"))
    return
  end

  vim.diagnostic.jump { severity = severity, count = direction == "next" and 1 or -1, }
end
vim.keymap.set("n", "]d",
  function() next_prev_diagnostic "next" end,
  { desc = "Next diagnostic", }
)
vim.keymap.set("n", "[d",
  function() next_prev_diagnostic "prev" end,
  { desc = "Next diagnostic", }
)
vim.keymap.set("n", "]w",
  function() next_prev_diagnostic("next", vim.diagnostic.severity.WARN) end,
  { desc = "Next warning diagnostic", })
vim.keymap.set("n", "[w",
  function() next_prev_diagnostic("prev", vim.diagnostic.severity.WARN) end,
  { desc = "Next warning diagnostic", })
vim.keymap.set("n", "]e",
  function() next_prev_diagnostic("next", vim.diagnostic.severity.ERROR) end,
  { desc = "Next error diagnostic", }
)
vim.keymap.set("n", "[e",
  function() next_prev_diagnostic("prev", vim.diagnostic.severity.ERROR) end,
  { desc = "Next error diagnostic", }
)

local function enable_deno_lsp()
  return vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), ".deno-enable-lsp")) == h.vimscript_true
end

if enable_deno_lsp() then
  vim.lsp.enable "denols"
else
  vim.lsp.enable "ts_ls"
  vim.lsp.enable "eslint"
end

-- TODO: why doesn't this work in bashls.lua
vim.lsp.config("bashls", {
  filetypes = { "bash", "sh", "zsh", },
})
vim.lsp.enable {
  "ruby_lsp",
  "bashls",
  "lua_ls",
  "vimls",
}
