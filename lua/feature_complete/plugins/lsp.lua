local h = require "helpers"

--- @param unformatted string[]
--- @param formatted string[]
local apply_minimal_changes = function(unformatted, formatted)
  if formatted[#formatted] == "" then
    table.remove(formatted)
  end

  vim.schedule(function()
    local diff = h.utils.diff(unformatted, formatted)
    local view = vim.fn.winsaveview()
    local linenr = 0

    for _, record in ipairs(diff) do
      if record.type == "-" then
        vim.api.nvim_buf_set_lines(0, linenr, linenr + 1, false, {})
      elseif record.type == "+" then
        vim.api.nvim_buf_set_lines(0, linenr, linenr, false, { record.line, })
      end

      if record.type == "=" or record.type == "+" then
        linenr = linenr + 1
      end
    end
    vim.fn.winrestview(view)
    vim.cmd.write { mods = { silent = true, }, }
  end)
end

local format_with_prettier = function()
  local unformatted = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(unformatted, "\n")

  vim.system(
    { "npx", "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(0), },
    {
      stdin = content,
      text = true,
    },
    function(result)
      if result.code ~= 0 then return vim.schedule(vim.cmd.write) end
      if result.stdout == nil then return vim.schedule(vim.cmd.write) end

      local formatted = vim.split(result.stdout, "\n")
      apply_minimal_changes(unformatted, formatted)
    end)
end

local format_with_lsp = function()
  local clients = vim.lsp.get_clients {
    bufnr = 0,
    method = "textDocument/formatting",
  }

  if #clients == 0 then
    h.notify.error "No lua LSP client"
    return vim.cmd.write()
  end

  local client = clients[1]
  client:request("textDocument/formatting", vim.lsp.util.make_formatting_params(), function(err, result)
    if err then return vim.schedule(vim.cmd.write) end
    if not result or #result == 0 then return vim.schedule(vim.cmd.write) end

    local unformatted = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local formatted = vim.split(result[1].newText, "\n")
    apply_minimal_changes(unformatted, formatted)
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
}

vim.keymap.set("n", "<bs>", function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return h.notify.error "Aborting"
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  local one_pt_five_mb = 1.5 * 1024 * 1024
  if vim.fn.getfsize(bufname) > one_pt_five_mb or line_count > 5000 then
    vim.cmd.write()
  elseif vim.list_contains(prettier_ft, vim.bo.filetype) then
    format_with_prettier()
  elseif vim.bo.filetype == "lua" then
    format_with_lsp()
  else
    vim.cmd.write()
  end
end)
