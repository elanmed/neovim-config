package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

vim.cmd([[
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_global_extensions = [
\ 'coc-tsserver',
\ 'coc-prettier',
\ 'coc-json',
\ 'coc-eslint',
\ 'coc-snippets',
\ 'coc-pairs',
\ 'coc-sumneko-lua',
\ 'coc-sh',
\ ]
]])

-- TODO: convert these to lua
vim.cmd([[
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
inoremap <silent><expr> <c-space> coc#refresh()
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
nnoremap <silent>gd <Plug>(coc-definition)
nnoremap <silent>gy <Plug>(coc-type-definition)
nnoremap <silent>gu <Plug>(coc-references)
nnoremap <silent>ga <Plug>(coc-codeaction)
nnoremap <silent>gh :call ShowDocumentation()<cr>
]])

h.nmap("go", "<c-o>")
h.nmap("gi", "<c-i>")
h.nmap("<leader>gh", "<c-w>w:close<cr>") -- close hover documentation
