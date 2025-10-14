vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf, })
    if filetype == "tree" or filetype == "nvim-undotree" then return end
    vim.cmd "normal! zz"
  end,
  desc = "Center the screen on movement",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" then
      vim.bo[args.buf].buflisted = false
    end
  end,
  desc = "Avoid listing unnamed buffers",
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
