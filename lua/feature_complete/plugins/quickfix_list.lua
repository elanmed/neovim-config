local h = require "helpers"

-- require "quickfix-preview".setup {
--   pedit_prefix = "vertical rightbelow",
--   pedit_postfix = "| wincmd =",
--   keymaps = {
--     select_close_preview = "o",
--     select_close_quickfix = "<cr>",
--     toggle = "t",
--     next = { key = "<C-n>", },
--     prev = { key = "<C-p>", },
--     cnext = { key = "]q", },
--     cprev = { key = "[q", },
--   },
--   preview_win_opts = {
--     relativenumber = false,
--     number = true,
--     signcolumn = "no",
--     cursorline = true,
--   },
-- }

local qf_preview = require "homegrown_plugins.quickfix_preview.init"
qf_preview.setup {
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "]q", },
    cprev = { key = "[q", },
  },
  get_preview_win_opts = function()
    return { relativenumber = false, number = true, signcolumn = "no", cursorline = true, winblend = 5, }
  end,
  get_open_win_opts = function()
    return { border = "rounded", }
  end,
}

--- @param predicate fun(curr_item, idx: number): boolean
--- @param list table
local function filter(predicate, list)
  local filtered_list = {}
  for index, val in pairs(list) do
    if (predicate(val, index)) then -- vim.tbl_filter doesn't pass the index
      table.insert(filtered_list, val)
    end
  end
  return filtered_list
end

vim.api.nvim_create_autocmd({ "FileType", }, {
  callback = function()
    if vim.bo.buftype ~= "quickfix" then return end

    vim.keymap.set("n", "<leader>d", function()
      qf_preview.close()
      vim.fn.setqflist({}, "f") -- clear all
      -- vim.fn.setqflist({}, "r") -- clear current
    end, { buffer = true, desc = "Clear all quickfix lists", })

    vim.keymap.set("n", "dd", function()
      local curr_line = vim.fn.line "."
      local qf_list = vim.fn.getqflist()
      local is_last_line = curr_line == #qf_list

      local filtered_qf_list = filter(function(_, idx)
        return idx ~= curr_line
      end, qf_list)

      vim.fn.setqflist(filtered_qf_list, "r")
      if #qf_list == 1 then
        qf_preview.close()
        return
      end
      vim.api.nvim_win_set_cursor(h.curr.window, { is_last_line and curr_line - 1 or curr_line, 0, })
    end, { buffer = true, desc = "Delete the current qf item", })
  end,
})
