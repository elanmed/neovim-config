local h = require "helpers"

require "quickfix-preview".setup {
  pedit_prefix = "vertical rightbelow",
  pedit_postfix = "| wincmd =",
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "]q", },
    cprev = { key = "[q", },
  },
  preview_win_opts = {
    relativenumber = false,
    number = true,
    signcolumn = "no",
    cursorline = true,
  },
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  callback = function()
    if vim.bo.buftype ~= "quickfix" then return end

    vim.keymap.set("n", "<leader>d", function()
      vim.cmd "pclose"
      vim.fn.setqflist({}, "f") -- clear all
      -- vim.fn.setqflist({}, "r") -- clear current
    end, { buffer = true, desc = "Clear all quickfix lists", })

    vim.keymap.set("n", "dd", function()
      local curr_line = vim.fn.line "."
      local qf_list = vim.fn.getqflist()
      local is_last_line = curr_line == vim.tbl_count(qf_list)

      local filtered_qf_list = h.tbl.filter(function(_, idx)
        return idx ~= curr_line
      end, qf_list)

      vim.fn.setqflist(filtered_qf_list, "r")
      if vim.tbl_count(qf_list) == 1 then
        vim.cmd "pclose"
        return
      end
      vim.api.nvim_win_set_cursor(h.curr.window, { is_last_line and curr_line - 1 or curr_line, 0, })
    end, { buffer = true, desc = "Delete the current qf item", })
  end,
})
