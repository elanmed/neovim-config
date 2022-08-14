call plug#begin('~/.config/nvim/plugged')
if exists('g:vscode')
  Plug 'ggandor/lightspeed.nvim'
endif
call plug#end()

if exists('g:vscode')
  let mapleader=" "

  nnoremap W 0
  vnoremap W 0
  nnoremap E $
  vnoremap E $

  nnoremap H L
  vnoremap H L
  nnoremap L H
  vnoremap L H

  vnoremap < <gv
  vnoremap > >gv
  nnoremap <leader>o o<esc>
  nnoremap <leader>O O<esc>
  nnoremap <leader>rr viwp

  hi LightspeedCursor gui=reverse
  else
    lua require('init')
endif
