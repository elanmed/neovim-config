local mini_cmp = require "mini.completion"
require "nvim-autopairs".setup {}

mini_cmp.setup {
  delay = { completion = 10 ^ 7, },
  lsp_completion = {
    process_items = function(items, base)
      return mini_cmp.default_process_items(items, base, { filtersort = "fuzzy", kind_priority = { Snippet = -1, }, })
    end,
  },
  mappings = {
    force_twostep = "<C-x><C-o>",
    force_fallback = "<C-x><C-n>",
  },
}

-- vim.api.nvim_create_autocmd("LspAttach", {
--   desc = "Enable inlay hints",
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if not client then return end
--     local methods = vim.lsp.protocol.Methods
--     if client:supports_method(methods.textDocument_completion) then
--       vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true, })
--
--       vim.keymap.set("i", "<C-x>", function()
--         if next(vim.lsp.get_clients { bufnr = 0, }) then
--           vim.lsp.completion.get()
--         else
--           if vim.bo.omnifunc == "" then
--             vim.cmd [[ call feedkeys("\<C-x>\<C-n>", 'n') ]]
--           else
--             vim.cmd [[ call feedkeys("\<C-x>\<C-o>", 'n') ]]
--           end
--         end
--       end)
--     end
--   end,
-- })
