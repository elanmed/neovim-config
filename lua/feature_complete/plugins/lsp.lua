local h = require "shared.helpers"
local lspconfig = require "lspconfig"

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
      vim.opt.updatetime = 100 -- how long until the cursor events fire
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

    -- :h vim.lsp.foldexpr()
    if client:supports_method "textDocument/foldingRange" then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})

vim.keymap.set("i", "<C-b>", function() vim.lsp.buf.signature_help { border = "single", } end,
  { desc = "LSP signature help", })
vim.keymap.set("n", "gry", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP go to type definition", })

vim.keymap.set("n", "gh", function() h.notify.warn "use K!" end, { desc = "LSP hover", })
vim.keymap.set("n", "gd", function() h.notify.warn "use gri!" end, { desc = "LSP go to definition", })
vim.keymap.set("n", "gs", function() h.notify.warn "use gry!" end, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gu", function() h.notify.warn "use grr!" end, { desc = "LSP go to references", })
vim.keymap.set("n", "ga", function() h.notify.warn "use gra!" end, { desc = "LSP code action", })

vim.keymap.set("n", "gi", function()
    local error_diagnostics = vim.diagnostic.get(h.curr.buffer, { severity = vim.diagnostic.severity.ERROR, })
    if #error_diagnostics == 0 then
      h.notify.warn "No diagnostics"
      return
    end

    vim.diagnostic.setqflist { severity = vim.diagnostic.severity.ERROR, }
    vim.cmd "copen"
  end,
  { desc = "Open LSP diagnostics with the quickfix list", })

vim.keymap.set("n", "gl", function()
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
  vim.lsp.enable "denols"
else
  vim.lsp.config("ts_ls", {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
        jsxAttributeCompletionStyle = "braces",
      },
    },
  })
  vim.lsp.enable "ts_ls"
  vim.lsp.enable "eslint"
end

vim.lsp.config("bashls", {
  settings = {
    bashIde = {
      shellcheckArguments = "--extended-analysis=false",
      shfmt = {
        simplifyCode = true,
        caseIndent = true,
      },
    },
  },
})
vim.lsp.enable "bashls"

vim.lsp.enable {
  "jsonls",
  "lua_ls",
  "css_variables",
  "cssls",
  "cssmodules_ls",
  "stylelint_lsp",
  "tailwindcss",
  "vimls",
}

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
    { name = "path", },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-s>"] = cmp.mapping.complete(),
    ["<C-c>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true, },
  },
}

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
