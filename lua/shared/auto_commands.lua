local h = require "helpers"

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local excluded_fts = { "tree", "nvim-undotree", "rg-far", }
    if vim.list_contains(excluded_fts, vim.bo[args.buf].filetype) then return end
    vim.cmd.normal { "zz", bang = true, }
  end,
  desc = "Center the screen on movement",
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.keymap.set("i", "<Cr>", function()
      local current_line = vim.api.nvim_get_current_line()
      local patterns = {
        "%s*local%s+function%(%s*%)%s*$",
        "%s*function%(%s*%)%s*$",
        "%s+do%s*$",
        "%s+then%s*$",
      }
      local has_match = false
      for _, pattern in ipairs(patterns) do
        if current_line:match(pattern) then
          has_match = true
          break
        end
      end

      if not has_match then return "<Cr>" end
      if current_line:match "end%s*$" then return "<Cr>" end

      return "\r" .. "end<C-o>O"
    end, { expr = true, buffer = true, })
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
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "true")
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "false")
  end,
})
