local h = require "shared.helpers"

-- https://github.com/samhvw8/mvim/blob/master/lua/core/coc.lua
h.let.coc_global_extensions = {
  "coc-tsserver",
  "coc-prettier",
  "coc-json",
  "coc-eslint",
  "coc-snippets",
  "coc-pairs",
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
  if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
    vim.cmd("h " .. cw)
  elseif vim.api.nvim_eval("coc#rpc#ready()") then
    vim.fn.CocActionAsync("doHover")
  else
    vim.cmd("!" .. vim.o.keywordprg .. " " .. cw)
  end
end

-- TODO: in progress
-- local function coc_handle_enter()
--   if vim.api.nvim_eval('coc#pum#visible()') then
--     vim.cmd('call coc#pum#confirm()')
--   else
--     vim.cmd("normal <C-g>u")
--     vim.cmd("call coc#on_enter()")
--   end
-- end

-- TODO: cleanup
h.imap("<c-space>", "coc#refresh()", { expr = true })
h.imap("<cr>", ([[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<cr>\<c-r>=coc#on_enter()\<CR>"]]), { expr = true })

h.nmap("gd", "<Plug>(coc-definition)zz")
h.nmap("gy", "<Plug>(coc-type-definition)")
h.nmap("gu", "<Plug>(coc-references)")
h.nmap("ga", "<Plug>(coc-codeaction-cursor)")
h.nmap("gm", "<Plug>(coc-rename)")
h.nmap("gh", coc_show_docs)
h.nmap("go", "<c-o>")
h.nmap("gi", "<c-i>")
h.nmap("<leader>gh", "<c-w>w<c-w>w") -- close hover documentation
h.nmap("<leader>cr", h.user_cmd_cb("CocRestart"))

h.set.updatetime = 100
h.set.signcolumn = "yes" -- needed for linting symbols

vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = "CocGroup",
  command = "silent call CocActionAsync('highlight')",
})
vim.api.nvim_set_hl(0, "CocFloating", { link = "Normal" })
