-- easymotion
vim.cmd([[
  autocmd User EasyMotionPromptBegin :let b:coc_diagnostic_disable = 1
  autocmd User EasyMotionPromptEnd :let b:coc_diagnostic_disable = 0
]])

-- markdown preview
vim.g.mkdp_filetypes = {
  "markdown"
}
