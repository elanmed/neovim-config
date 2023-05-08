vim.cmd("colorscheme slate")
vim.g.netrw_winsize = 40
vim.g.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd('filetype', {
  pattern = 'netrw',
  callback = function()
    local nmap = function(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { remap = true, buffer = true })
    end

    nmap("h", "-^")                     -- go up a directory
    nmap("l", "<cr>")
    nmap("P", "<C-w>z")                 -- close preview
    nmap("<leader>re", ":Lexplore<cr>") -- close netrw
  end
})
