package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

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
}

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
      [[ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : ]] ..
      [[ v:lua.check_backspace() ? "\<TAB>" : ]] ..
      [[ coc#refresh() ]]
  ), { expr = true }
)

-- TODO: test these
-- h.nmap('<C-f>', [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]], { expr = true })
-- h.nmap('<C-b>', [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]], { expr = true })
-- h.imap('<C-f>', [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]], { expr = true })
-- h.imap('<C-b>', [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]], { expr = true })
-- h.vmap('<C-f>', [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]], { expr = true })
-- h.vmap('<C-b>', [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]], { expr = true })

h.imap('<c-space>', 'coc#refresh()', { expr = true })
h.imap('<cr>', ([[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]]), { expr = true })

h.nmap('gd', '<Plug>(coc-definition)')
h.nmap('gy', '<Plug>(coc-type-definition)')
h.nmap('gu', '<Plug>(coc-references)')
h.nmap('ga', '<Plug>(coc-codeaction)')
h.nmap('gh', ':call v:lua.show_docs()<cr>')
h.nmap("go", "<c-o>")
h.nmap("gi", "<c-i>")
h.nmap("<leader>gh", "<c-w>w:close<cr>") -- close hover documentation
