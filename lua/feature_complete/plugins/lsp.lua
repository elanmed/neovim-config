local h = require "shared.helpers"

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
  end,
})

vim.keymap.set("i", "<C-s>",
  function()
    vim.lsp.buf.signature_help { border = "single", }
  end,
  { desc = "LSP signature help", }
)
vim.keymap.set("n", "gry", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gri", vim.lsp.buf.definition, { desc = "LSP go to definition", })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single", } end, { desc = "LSP go to type definition", })
vim.keymap.set("n", "<leader>k", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- https://neovim.io/doc/user/api.html#floating-windows
    if vim.api.nvim_win_get_config(win).relative == "win" then
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end)


--- @param direction "next" | "prev"
local function next_prev_diagnostic(direction)
  local error_diagnostics = vim.diagnostic.get(h.curr.buffer, { severity = vim.diagnostic.severity.ERROR, })
  if #error_diagnostics == 0 then
    h.notify.warn "No error diagnostics"
    return
  end

  vim.diagnostic.jump { severity = vim.diagnostic.severity.ERROR, count = direction == "next" and 1 or -1, }
end
vim.keymap.set("n", "]d", function() next_prev_diagnostic "next" end)
vim.keymap.set("n", "[d", function() next_prev_diagnostic "prev" end)

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

vim.lsp.enable {
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

local blink = require "blink.cmp"
blink.setup {
  keymap = {
    preset = "none",
    ["<C-x>"] = { "show", },
    ["<C-y>"] = { "accept", },
    ["<C-c>"] = { "cancel", },
    ["<C-n>"] = { "select_next", "fallback", },
    ["<C-p>"] = { "select_prev", "fallback", },
    ["<C-d>"] = { "scroll_documentation_down", },
    ["<C-u>"] = { "scroll_documentation_up", },
  },
  completion = {
    documentation = { auto_show = true, window = { border = "single", }, },
    ghost_text = { enabled = true, },
    list = { selection = { auto_insert = false, }, },
  },
  sources = {
    default = { "lsp", "path", "buffer", },
  },
  fuzzy = { prebuilt_binaries = { force_version = "v1.3.1", }, },
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
