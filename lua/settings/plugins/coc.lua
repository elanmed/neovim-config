package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

-- https://github.com/samhvw8/mvim/blob/master/lua/core/coc.lua
vim.g.coc_global_extensions = {
  'coc-tsserver',
  'coc-prettier',
  'coc-json',
  'coc-eslint',
  'coc-snippets',
  'coc-pairs',
  'coc-sumneko-lua',
  'coc-sh',
  '@yaegassy/coc-tailwindcss3',
  'coc-cssmodules',
  'coc-deno',
  'coc-stylelint',
  'coc-solargraph',
  'coc-css'
}

vim.cmd("autocmd FileType scss setl iskeyword+=@-@")

function _G.check_backspace()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.cmd('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.cmd('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

h.imap('<TAB>', (
  [[ coc#pum#visible() ? coc#_select_confirm() : ]] ..
  [[ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<cr>" : ]] ..
  [[ v:lua.check_backspace() ? "\<TAB>" : ]] ..
  [[ coc#refresh() ]]
), { expr = true }
)

h.imap('<c-space>', 'coc#refresh()', { expr = true })
h.imap('<cr>', ([[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<cr>\<c-r>=coc#on_enter()\<CR>"]]), { expr = true })

h.nmap('gd', '<Plug>(coc-definition)zz')
h.nmap('gy', '<Plug>(coc-type-definition)')
h.nmap('gu', '<Plug>(coc-references)')
h.nmap('ga', '<Plug>(coc-codeaction-cursor)')
h.nmap('gh', '<cmd>call v:lua.show_docs()<cr>')
h.nmap("go", "<c-o>")
h.nmap("gi", "<c-i>")
h.nmap("<leader>gh", "<c-w>w<c-w>w") -- close hover documentation

h.set.updatetime = 100
vim.cmd([[autocmd CursorHold * silent call CocActionAsync('highlight')]])
