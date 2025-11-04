local h = require "helpers"

-- require "conform".setup {
--   formatters_by_ft = {
--     css = { "prettier", },
--     graphql = { "prettier", },
--     html = { "prettier", },
--     javascript = { "prettier", },
--     javascriptreact = { "prettier", },
--     json = { "prettier", },
--     less = { "prettier", },
--     markdown = { "prettier", },
--     scss = { "prettier", },
--     typescript = { "prettier", },
--     typescriptreact = { "prettier", },
--     yaml = { "prettier", },
--     java = {},
--     lua = { lsp_format = "fallback", },
--   },
--   format_after_save = {
--     async = true,
--   },
-- }


--- @param unformatted string[]
--- @param formatted string[]
local apply_minimal_changes = function(unformatted, formatted)
  if formatted[#formatted] == "" then
    table.remove(formatted)
  end

  local start_time = os.clock()
  local diff = require "lcs-diff".diff(unformatted, formatted)
  local end_time = os.clock()
  vim.print(("lcs-diff: %ss"):format((end_time - start_time) * 1000))

  vim.schedule(function()
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
    vim.cmd.write()
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
      if result.code ~= 0 then
        vim.schedule(function() h.notify.error("[prettier] " .. (result.stderr or "")) end)
        return
      end

      if result.stdout == nil then
        vim.schedule(function() h.notify.error "[prettier] `result.stdout` is `nil`" end)
        return
      end

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
    return h.notify.error "No lua LSP client"
  end

  local client = clients[1]
  client:request("textDocument/formatting", vim.lsp.util.make_formatting_params(), function(err, result)
    if err then
      return h.notify.error("[lua_ls] " .. err.message)
    end

    if not result or #result == 0 then
      return h.notify.error("[lua_ls] " .. "textDocument/formatting result is `nil`")
    end

    local unformatted = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local formatted = vim.split(result[1].newText, "\n")
    apply_minimal_changes(unformatted, formatted)
  end)
end

local format_with_vim = function()
  local view = vim.fn.winsaveview()
  vim.cmd "keepjumps normal! gg=G"
  vim.fn.winrestview(view)
  vim.cmd.write()
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
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

    vim.keymap.set("n", "<leader>w", function()
      if vim.bo.readonly then
        h.notify.error "Buffer is readonly, aborting"
        return
      end

      if vim.bo.buftype ~= "" then
        h.notify.error "`buftype` is set, aborting"
        return
      end

      if vim.list_contains(prettier_ft, vim.bo.filetype) then
        format_with_prettier()
      elseif vim.bo.filetype == "lua" then
        format_with_lsp()
      else
        format_with_vim()
      end
    end, { buffer = true, })
  end,
})
