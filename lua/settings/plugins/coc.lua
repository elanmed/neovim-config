local h = require "shared.helpers"

-- https://github.com/samhvw8/mvim/blob/master/lua/core/coc.lua
h.let.coc_global_extensions = {
  "coc-tsserver",
  "coc-prettier",
  "coc-json",
  "coc-eslint",
  "coc-snippets",
  "coc-lua",
  "coc-sh",
  "@yaegassy/coc-tailwindcss3",
  "coc-cssmodules",
  "coc-deno",
  "coc-stylelint",
  "coc-css",
}

local function coc_show_docs()
  local cw = vim.fn.expand("<cword>")
  if h.table_contains({ "vim", "help" }, vim.bo.filetype) then
    vim.cmd("h " .. cw)
  elseif vim.api.nvim_eval("coc#rpc#ready()") then
    vim.fn.CocActionAsync("doHover")
  else
    vim.cmd("!" .. vim.o.keywordprg .. " " .. cw)
  end
end

h.imap("<c-space>", "coc#refresh()", { expr = true, desc = "Show autocompletion options" })
h.imap("<c-f>", "coc#pum#confirm()", { expr = true })

h.nmap("gd", "<Plug>(coc-definition)zz", { desc = "Go to definition" })
h.nmap("gy", "<Plug>(coc-type-definition)", { desc = "Go to type definition" })
h.nmap("gu", "<Plug>(coc-references)", { desc = "Go to references" })
h.nmap("ga", "<Plug>(coc-codeaction-cursor)", { desc = "Open code actions" })
h.nmap("gn", "<Plug>(coc-rename)", { desc = "Rename symbol" })
h.nmap("gh", coc_show_docs, { desc = "Open docs" })
h.nmap("go", "<c-o>", { desc = "Go backwards" })
h.nmap("gi", "<c-i>", { desc = "Go forwards" })
h.nmap("<leader>gh", "<c-w>w:q<cr>", { desc = "Close docs" }) -- close hover documentation
h.nmap("<leader>cr", h.user_cmd_cb("CocRestart"), { desc = "Restart coc" })

h.set.updatetime = 100
h.set.signcolumn = "yes" -- needed for linting symbols

vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = "CocGroup",
  command = "silent call CocActionAsync('highlight')",
})
vim.api.nvim_set_hl(0, "CocFloating", { link = "Normal" })
