local h = require "helpers"

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    if filetype == "tree" or filetype == "nvim-undotree" then return end
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

--- https://wezterm.org/recipes/passing-data.html#user-vars
--- @param val 'true'|'false'
local function format_is_nvim_var(val)
  return ("\033]1337;SetUserVar=IS_NVIM=%s\007"):format(vim.base64.encode(val))
end

local function write_var(var)
  if vim.fn.filewritable "/dev/fd/2" == 1 then
    vim.fn.writefile({ var, }, "/dev/fd/2", "b")
  else
    vim.fn.chansend(vim.v.stderr, var)
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() write_var(format_is_nvim_var "true") end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function() write_var(format_is_nvim_var "false") end,
})
