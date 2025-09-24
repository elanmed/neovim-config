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

vim.keymap.set({ "i", "n", }, "<C-g>", toggle_virtual_lines, { desc = "Toggle virtual lines", })
vim.keymap.set("i", "<C-s>", function()
    vim.lsp.buf.signature_help { border = "rounded", }
  end,
  { desc = "LSP signature help", }
)
vim.keymap.set("n", "glr", vim.lsp.buf.references, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gla", vim.lsp.buf.code_action, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gly", function()
  vim.lsp.buf.type_definition()
  -- vim.cmd "normal! zz"
end, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gli", function()
  vim.lsp.buf.definition()
  -- vim.cmd "normal! zz"
end, { desc = "LSP go to definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "rounded", } end, { desc = "LSP hover", })
vim.keymap.set("n", "<leader>k", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local is_floating = vim.api.nvim_win_get_config(win).relative == "win"
    if is_floating then vim.api.nvim_win_close(win, false) end
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
  return vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), ".deno-enable-lsp")) == h.vimscript_true
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
