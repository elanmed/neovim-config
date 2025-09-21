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
      end, { buffer = bufnr, })
      vim.cmd "NoMatchParen"
      vim.cmd "NeoscrollEnableBufferPM"
    end
  end,
})
