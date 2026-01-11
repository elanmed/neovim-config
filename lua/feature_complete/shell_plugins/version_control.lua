local lazygit_term_winnr = -1
local lazygit_term_bufnr = -1

vim.keymap.set("n", "<leader>g", function()
  local open_term = function()
    lazygit_term_winnr = vim.api.nvim_open_win(lazygit_term_bufnr, true, {
      split = "right",
      win = 0,
      width = math.floor(vim.o.columns * 3 / 4),
    })
  end

  if vim.api.nvim_buf_is_valid(lazygit_term_bufnr) then
    open_term()
  else
    lazygit_term_bufnr = vim.api.nvim_create_buf(false, true)

    open_term()
    vim.keymap.set("t", "<c-c>", function()
      vim.api.nvim_win_close(lazygit_term_winnr, true)
      vim.schedule(function()
        require "helpers".notify.doing "Closing the lazygit window, buffer saved"
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
