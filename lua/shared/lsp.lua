local h = require "helpers"

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "!!",
    [vim.diagnostic.severity.INFO] = "?",
    [vim.diagnostic.severity.HINT] = "•",
    [vim.diagnostic.severity.WARN] = "•",
  },
}

vim.diagnostic.config {
  underline = false,
  virtual_lines = false,
  signs = signs,
}

local function toggle_virtual_lines()
  local current_virtual_lines = vim.diagnostic.config().virtual_lines

  vim.diagnostic.config {
    underline = false,
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
    vim.lsp.buf.signature_help { border = "single", }
  end,
  { desc = "LSP signature help", }
)
vim.keymap.set("n", "glr", vim.lsp.buf.references, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gla", vim.lsp.buf.code_action, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gly", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP hover", })
vim.keymap.set({ "n", "i", }, "<C-k>", function()
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
