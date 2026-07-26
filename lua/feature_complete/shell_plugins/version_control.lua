local lazygit_term_winnr = -1
local lazygit_term_bufnr = -1

vim.keymap.set("n", "<leader>g", function()
  local tabline_height = 1
  local statusline_height = 1
  local cmdline_height = 1

  local cover_statusline = 1
  local cover_cmdline = 1

  local row_1i = 2
  local row_0i = row_1i - 1

  local get_avail_height = function()
    local avail_height = vim.o.lines - tabline_height - row_0i - statusline_height - cmdline_height
    return avail_height + cover_statusline + cover_cmdline
  end

  local open_term = function()
    lazygit_term_winnr = vim.api.nvim_open_win(lazygit_term_bufnr, true, {
      relative = "editor",
      row = row_0i,
      col = 0,
      width = vim.o.columns,
      height = get_avail_height(),
    })
  end

  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not vim.api.nvim_win_is_valid(lazygit_term_winnr) then return end
      vim.api.nvim_win_set_config(lazygit_term_winnr, {
        width = vim.o.columns,
        height = get_avail_height(),
      })
    end,
  })


  if vim.api.nvim_buf_is_valid(lazygit_term_bufnr) then
    open_term()
  else
    lazygit_term_bufnr = vim.api.nvim_create_buf(false, true)

    open_term()
    vim.keymap.set("t", "<c-c>", function()
      vim.api.nvim_win_close(lazygit_term_winnr, true)
      vim.schedule(function()
        vim.notify("Closing the lazygit window, buffer saved", vim.log.levels.INFO)
      end)
    end, { buffer = lazygit_term_bufnr, })

    vim.fn.jobstart("lazygit", {
      term = true,
      on_exit = function()
        vim.api.nvim_win_close(lazygit_term_winnr, true)
        vim.cmd.bdelete(lazygit_term_bufnr)
      end,
    })
  end
  vim.cmd.startinsert()
end, { desc = "Open lazygit", })
