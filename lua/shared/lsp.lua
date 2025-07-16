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

    -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc
    if client:supports_method(methods.textDocument_completion) then
      --- @param keys string
      local function feedkeys(keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
      end

      local function pumvisible()
        return tonumber(vim.fn.pumvisible()) ~= 0
      end

      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false, })

      vim.keymap.set("i", "<cr>", function()
        return pumvisible() and "<C-y>" or "<cr>"
      end, { expr = true, })

      vim.keymap.set("i", "<C-n>", function()
        if pumvisible() then
          feedkeys "<C-n>"
        else
          if next(vim.lsp.get_clients { bufnr = 0, }) then
            vim.lsp.completion.get()
          else
            if vim.bo.omnifunc == "" then
              feedkeys "<C-x><C-n>"
            else
              feedkeys "<C-x><C-o>"
            end
          end
        end
      end)

      vim.keymap.set("i", "<C-u>", "<C-x><C-n>", { desc = "Buffer completions", })
    end

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
vim.keymap.set("n", "gry", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
vim.keymap.set("n", "gri", vim.lsp.buf.definition, { desc = "LSP go to definition", })
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
