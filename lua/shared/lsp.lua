local h = require "helpers"

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.INFO] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.HINT] = "",
  },
}

vim.diagnostic.config {
  virtual_lines = false,
  signs = signs,
}

local function toggle_virtual_lines()
  local current_virtual_lines = vim.diagnostic.config().virtual_lines

  vim.diagnostic.config {
    virtual_lines = not current_virtual_lines,
    signs = signs,
  }

  if not current_virtual_lines then
    h.notify.toggle_on "Virtual lines enabled"
  else
    h.notify.toggle_off "Virtual lines disabled"
  end
end

vim.keymap.set({ "i", "n", "v", }, "<C-g>", toggle_virtual_lines, { desc = "Toggle virtual lines", })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local methods = vim.lsp.protocol.Methods
    local bufnr = args.buf

    if client:supports_method(methods.textDocument_documentHighlight) then
      vim.opt.updatetime = 100 -- how long until the cursor events fire
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", }, {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})

vim.keymap.set("i", "<C-s>",
  function()
    vim.lsp.buf.signature_help { border = "single", }
  end,
  { desc = "LSP signature help", }
)
vim.keymap.set("n", "glr", vim.lsp.buf.references, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gla", vim.lsp.buf.code_action, { desc = "LSP go to type definition", })
vim.keymap.set("n", "glt", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gli", vim.lsp.buf.definition, { desc = "LSP go to definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP go to type definition", })
vim.keymap.set("n", "<leader>k", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- :h floating-windows
    if vim.api.nvim_win_get_config(win).relative == "win" then
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end)


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
vim.keymap.set("n", "]d", function() next_prev_diagnostic "next" end)
vim.keymap.set("n", "[d", function() next_prev_diagnostic "prev" end)
vim.keymap.set("n", "]w", function() next_prev_diagnostic("next", vim.diagnostic.severity.WARN) end)
vim.keymap.set("n", "[w", function() next_prev_diagnostic("prev", vim.diagnostic.severity.WARN) end)
vim.keymap.set("n", "]e", function() next_prev_diagnostic("next", vim.diagnostic.severity.ERROR) end)
vim.keymap.set("n", "[e", function() next_prev_diagnostic("prev", vim.diagnostic.severity.ERROR) end)

local function enable_deno_lsp()
  return h.os.file_exists(vim.fn.getcwd() .. "/.deno-enable-lsp")
end

if enable_deno_lsp() then
  vim.lsp.enable "denols"
else
  vim.lsp.config("ts_ls", {
    init_options = {
      preferences = { importModuleSpecifierPreference = "non-relative", jsxAttributeCompletionStyle = "braces", },
    },
  })
  vim.lsp.enable "ts_ls"
  vim.lsp.enable "eslint"
end

vim.lsp.config("bashls", {
  settings = {
    bashIde = { shellcheckArguments = "--extended-analysis=false", shfmt = { simplifyCode = true, caseIndent = true, }, },
  },
})

vim.lsp.enable {
  "ruby_lsp",
  "bashls",
  "jsonls",
  "lua_ls",
  "css_variables",
  "cssls",
  "cssmodules_ls",
  "stylelint_lsp",
  "tailwindcss",
  "vimls",
}
