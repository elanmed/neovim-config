local h = require "shared.helpers"
local lspconfig = require "lspconfig"
local snacks = require "snacks"

vim.opt.signcolumn = "yes" -- reserve a space in the gutter

require "mason".setup()
require "mason-lspconfig".setup {
  ensure_installed = {
    "ts_ls",
    "eslint",
    "jsonls",
    "lua_ls",
    "bashls",
    "css_variables",
    "cssls",
    "cssmodules_ls",
    "stylelint_lsp",
    "tailwindcss",
    "denols",
    "vimls",
  },
}

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.INFO] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.HINT] = "",
  },
}

vim.diagnostic.config {
  virtual_lines = true,
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

h.keys.map({ "n", "v", }, "<C-g>", toggle_virtual_lines, { desc = "toggle virtual lines", })
h.keys.map({ "i", }, "<C-g>s", "<nop>", { desc = "disable vim surround remap", })
h.keys.map({ "i", }, "<C-g>S", "<nop>", { desc = "disable vim surround remap", })
h.keys.map({ "i", }, "<C-g>", toggle_virtual_lines, { desc = "toggle virtual lines", })


local lspconfig_defaults = lspconfig.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults.capabilities,
  require "cmp_nvim_lsp".default_capabilities()
)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    if client:supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true)
    end

    if client:supports_method "textDocument/documentHighlight" then
      h.set.updatetime = 100 -- how long until the cursor events fire
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
        buffer = h.curr.buffer,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", }, {
        buffer = h.curr.buffer,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})

h.keys.map({ "n", }, "gh", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP hover", })
h.keys.map({ "n", }, "gd", vim.lsp.buf.definition, { desc = "LSP go to definition", })
h.keys.map({ "n", }, "gs", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
h.keys.map({ "n", }, "gu", vim.lsp.buf.references, { desc = "LSP go to references", })
h.keys.map({ "n", }, "ga", vim.lsp.buf.code_action, { desc = "LSP code action", })
h.keys.map({ "n", }, "<leader>ld", function()
    vim.diagnostic.setqflist { severity = vim.diagnostic.severity.ERROR, }
    vim.cmd "copen"
  end,
  { desc = "Open LSP diagnostics with the quickfix list", })

h.keys.map({ "n", }, "gl", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- https://neovim.io/doc/user/api.html#floating-windows
    if vim.api.nvim_win_get_config(win).relative == "win" then
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end)

local function enable_deno_lsp()
  return h.os.file_exists(vim.fn.getcwd() .. "/.deno-enable-lsp")
end

if enable_deno_lsp() then
  lspconfig.denols.setup {}
else
  lspconfig.ts_ls.setup {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
        jsxAttributeCompletionStyle = "braces",
      },
    },
  }
  lspconfig.eslint.setup {}
end

lspconfig.jsonls.setup {}
lspconfig.lua_ls.setup {}
lspconfig.bashls.setup {
  settings = {
    bashIde = {
      shellcheckArguments = "--extended-analysis=false",
      shfmt = {
        simplifyCode = true,
        caseIndent = true,
      },
    },
  },
}
lspconfig.css_variables.setup {}
lspconfig.cssls.setup {}
lspconfig.cssmodules_ls.setup {}
lspconfig.stylelint_lsp.setup {}
lspconfig.tailwindcss.setup {}
lspconfig.vimls.setup {}

local cmp = require "cmp"
cmp.setup {
  sources = {
    {
      name = "nvim_lsp",
      -- https://github.com/hrsh7th/nvim-cmp/discussions/759#discussioncomment-9875581
      entry_filter = function(entry)
        return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Snippet
      end,
    },
    { name = "buffer", },
    { name = "lazydev", group_index = 0, },
    { name = "path", },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-s>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true, },
  },
}

require "lazydev".setup {}
require "nvim-autopairs".setup {}
require "conform".setup {
  formatters_by_ft = {
    css = { "prettier", },
    graphql = { "prettier", },
    html = { "prettier", },
    javascript = { "prettier", },
    javascriptreact = { "prettier", },
    json = { "prettier", },
    less = { "prettier", },
    markdown = { "prettier", },
    scss = { "prettier", },
    typescript = { "prettier", },
    typescriptreact = { "prettier", },
    yaml = { "prettier", },
  },
  format_after_save = {
    lsp_format = "fallback",
    async = true,
  },
}
