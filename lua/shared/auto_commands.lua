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

-- io.stdout:write "\x1b]1337;SetUserVar=IS_NVIM=MQo\007"

local function write_wezterm_var(var)
  io.stderr:write(var)
  io.stderr:flush()
  return true
end

local function format_wezterm_var(val)
  return string.format("\033]1337;SetUserVar=IS_NVIM=%s\007", vim.base64.encode(val))
end

write_wezterm_var(format_wezterm_var "true")
