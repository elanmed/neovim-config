local h = require "helpers"
local fzf = require "shared.fzf"

vim.cmd "set wildchar=<C-n>"

vim.opt.scrolloff = 999
vim.opt.completeopt = "menuone,noselect,fuzzy"
vim.keymap.set("i", "<C-x>", "<C-x><C-o>")
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Enable inlay hints",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local methods = vim.lsp.protocol.Methods
    if client:supports_method(methods.textDocument_completion) then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true, })

      vim.keymap.set("i", "<C-x>", function()
        if next(vim.lsp.get_clients { bufnr = 0, }) then
          vim.lsp.completion.get()
        else
          if vim.bo.omnifunc == "" then
            vim.cmd [[ call feedkeys("\<C-x>\<C-n>", 'n') ]]
          else
            vim.cmd [[ call feedkeys("\<C-x>\<C-o>", 'n') ]]
          end
        end
      end)
    end
  end,
})

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    while vim.bo.filetype == "netrw" do
      vim.cmd "bdelete"
    end
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<leader>f", function()
  fzf.fzf {
    source = "fd --hidden --type f --exclude .git --exclude node_modules --exclude dist",
    height = "half",
    options = fzf.extend(fzf.default_opts, fzf.multi_select_opts),
    sinklist = function(entries)
      for _, entry in ipairs(entries) do
        vim.cmd("edit " .. entry)
      end
    end,
  }
end)

vim.keymap.set("n", "<C-n>", h.keys.vim_cmd_cb "cnext")
vim.keymap.set("n", "<C-p>", h.keys.vim_cmd_cb "cprev")
