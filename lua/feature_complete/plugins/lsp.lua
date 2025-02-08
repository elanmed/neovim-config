local h = require "shared.helpers"

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
    -- "solargraph"
  },
}

vim.diagnostic.config {
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
}

local last_cursor = { nil, nil, }
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
  pattern = "*",
  callback = function()
    local current_cursor = vim.api.nvim_win_get_cursor(h.curr.window)

    -- when holding, don't force open the diagnostics unless the cursor has moved
    -- allows opening another float with hover
    if not (current_cursor[1] == last_cursor[1] and current_cursor[2] == last_cursor[2]) then
      vim.diagnostic.open_float { border = "single", focus = false, scope = "line", }
    end

    last_cursor = current_cursor
  end,
})

local cmp_capabilities = require "cmp_nvim_lsp".default_capabilities()
-- https://github.com/hrsh7th/nvim-cmp/discussions/759
cmp_capabilities.textDocument.completion.completionItem.snippetSupport = false

-- https://lsp-zero.netlify.app/docs/getting-started.html#extend-nvim-lspconfig
local lspconfig_defaults = require "lspconfig".util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults.capabilities,
  cmp_capabilities
)

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format { id = client.id, bufnr = args.buf, async = false, }
          -- https://github.com/neovim/neovim/issues/25014#issuecomment-2312672119
          vim.diagnostic.enable(args.buf)
        end,
      })
    end

    if client.supports_method "textDocument/documentHighlight" then
      vim.o.updatetime = 100 -- how long until the cursor events fire
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
        buffer = h.curr.buffer,
        callback = function()
          if not h.tbl.table_contains_value({ "qf", "DiffviewFiles", "oil", "harpoon", }, vim.bo.filetype) then
            vim.lsp.buf.document_highlight()
          end
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

h.keys.map({ "n", }, "gh", vim.lsp.buf.hover, { desc = "LSP hover", })
h.keys.map({ "n", }, "gd", vim.lsp.buf.definition, { desc = "LSP go to definition", })
h.keys.map({ "n", }, "gy", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
h.keys.map({ "n", }, "gu", vim.lsp.buf.references, { desc = "LSP go to references", })
h.keys.map({ "n", }, "ga", vim.lsp.buf.code_action, { desc = "LSP code action", })
h.keys.map({ "n", }, "<leader>ld", vim.diagnostic.setloclist, { desc = "Open LSP diagnostics with the quickfix list", })
h.keys.map({ "n", }, "gl", function()
  -- https://www.reddit.com/r/neovim/comments/1335pfc/comment/ji918lo/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
})

require "lspconfig".ts_ls.setup {}
require "lspconfig".eslint.setup {}
require "lspconfig".jsonls.setup {}
require "lspconfig".lua_ls.setup {
  settings = {
    Lua = { diagnostics = { globals = { "vim", }, }, },
  },
}
require "lspconfig".bashls.setup {
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
require "lspconfig".css_variables.setup {}
require "lspconfig".cssls.setup {}
require "lspconfig".cssmodules_ls.setup {}
require "lspconfig".stylelint_lsp.setup {}
require "lspconfig".tailwindcss.setup {}
require "lspconfig".solargraph.setup {}
require "lspconfig".denols.setup {}
require "lspconfig".vimls.setup {}

local cmp = require "cmp"
cmp.setup {
  sources = {
    { name = "nvim_lsp", },
    { name = "buffer", },
    { name = "lazydev", group_index = 0, },
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
