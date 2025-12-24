local h = require "helpers"

vim.api.nvim_create_autocmd("CursorMoved", {
  group = vim.api.nvim_create_augroup("CenterScreen", { clear = true, }),
  callback = function(args)
    local excluded_fts = { "tree", "nvim-undotree", "rg-far", }
    if vim.list_contains(excluded_fts, vim.bo[args.buf].filetype) then return end
    vim.cmd.normal { "zz", bang = true, }
  end,
  desc = "Center the screen on movement",
})

vim.o.pumheight = 10
vim.api.nvim_create_autocmd("CmdlineEnter", { callback = function() vim.o.pumheight = 5 end, })
vim.api.nvim_create_autocmd("CmdlineLeave", { callback = function() vim.o.pumheight = 10 end, })
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", },
  callback = function()
    local cmdline = vim.fn.getcmdline()
    local cmdtype = vim.fn.getcmdtype()

    if cmdtype == "/" and cmdline:match "^\\V." then
      vim.fn.wildtrigger()
    elseif cmdtype == ":" then
      vim.fn.wildtrigger()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DisableAutoComments", { clear = true, }),
  callback = function()
    -- :h fo-table
    vim.o.formatoptions = "rl1j"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("SetYankRing", { clear = true, }),
  callback = function()
    if vim.v.event.operator == "y" then
      h.utils.rotate_registers()
    end
  end,
})

-- TODO convert to lua
-- https://github.com/mrjones2014/smart-splits.nvim/blob/6c7c64b6e1be6eb95fd9583c0969e0df625c6cd6/autoload/smart_splits.vim#L51-L62
vim.cmd [[
function! s:is_nvim_var(val)
  if a:val == "true"
    return printf("\033]1337;SetUserVar=IS_NVIM=dHJ1ZQ==\007")
  elseif a:val == "false"
    return printf("\033]1337;SetUserVar=IS_NVIM=ZmFsc2U=\007")
  endif
endfunction
]]

local function write_var(var)
  if vim.fn.filewritable "/dev/fd/2" == h.vimscript_true then
    vim.fn.writefile({ var, }, "/dev/fd/2", "b")
  else
    vim.fn.chansend(vim.v.stderr, var)
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("SetWeztermIsNvimVar", { clear = true, }),
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "true")
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("UnSetWeztermIsNvimVar", { clear = true, }),
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "false")
  end,
})
