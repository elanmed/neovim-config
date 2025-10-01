vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local bufnr = args.buf
    if vim.api.nvim_get_option_value("buftype", { buf = bufnr, }) ~= "" then
      return
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local size = vim.fn.getfsize(buf_name)
    local max_size = 1.5 * 1024 * 1024 -- 1.5MB

    if line_count > 5000 or size > max_size then
      require "helpers".notify.doing "bigfile detected"
      vim.keymap.set("n", "/", function()
        vim.api.nvim_feedkeys("/", "n", false)
      end, { buffer = bufnr, desc = "Disable fuzzy buffer search", })
      vim.cmd "NoMatchParen"
    end
  end,
})

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf, })
    if filetype == "tree" then return end
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
