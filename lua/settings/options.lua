-- easymotion
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptBegin",
  callback = function() vim.b.coc_diagnostic_disable = 1 end
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptEnd",
  callback = function() vim.b.coc_diagnostic_disable = 0 end
})

-- uncomment for transparent terminals
-- for group, opts in pairs(vim.api.nvim_get_hl(0, {})) do
--   opts['bg'] = nil
--   vim.api.nvim_set_hl(0, group, opts)
-- end
