for _, arg in ipairs(vim.fn.argv()) do
  if vim.fn.isdirectory(arg) == 1 then
    vim.cmd.quit()
  end
end

-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "helpers".require_dir "shared"
require "feature_complete"
vim.g.loaded_netrw = 1
