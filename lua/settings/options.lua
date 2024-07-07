-- easymotion
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptBegin",
  callback = function() vim.b.coc_diagnostic_disable = 1 end
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptEnd",
  callback = function() vim.b.coc_diagnostic_disable = 0 end
})

-- clever_f
vim.g.clever_f_across_no_line = 1
