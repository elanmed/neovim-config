--- @param bufnr number
local function shorten_bufname(bufnr)
  return vim.fs.basename(vim.fn.bufname(bufnr))
end

vim.o.quickfixtextfunc = "v:lua.GetQuickfixTextFunc"

function _G.GetQuickfixTextFunc()
  local h = require "helpers"
  local longest_bufname_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local function has_preview_win()
    for _, winnr in ipairs(vim.api.nvim_list_wins()) do
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      if vim.bo[bufnr].filetype == "quickfix-preview" then
        return true
      end
    end
    return false
  end

  local items = {}
  for _, item in pairs(qf_list) do
    local bufname = shorten_bufname(item.bufnr)
    longest_bufname_len = math.max(#bufname, longest_bufname_len)
    longest_row_len = math.max(#tostring(item.lnum), longest_row_len)
    longest_col_len = math.max(#tostring(item.col), longest_col_len)
  end

  for index, item in pairs(qf_list) do
    local bufname = shorten_bufname(item.bufnr)
    local buffer_padding_right = longest_bufname_len - #bufname
    local formatted_item =
        bufname ..
        string.rep(" ", buffer_padding_right) ..
        " | " ..
        h.str.pad { val = item.lnum, max_len = longest_row_len, side = "left", } ..
        ":" ..
        h.str.pad { val = item.col, max_len = longest_col_len, side = "right", } ..
        " | " .. vim.fn.trim(item.text)

    local misc_padding = 10
    local win_width = (
      vim.api.nvim_win_get_width(0) / (has_preview_win() and 1 or 2)
    ) - misc_padding
    if #formatted_item > win_width then
      formatted_item = formatted_item:sub(1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end

vim.keymap.set("n", "<C-n>", function()
  require "helpers".utils.try_catch("cnext", "cfirst")
end, { desc = ":cnext", })
vim.keymap.set("n", "<C-p>", function()
  require "helpers".utils.try_catch("cprev", "clast")
end, { desc = ":cprev", })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("QfListRemaps", { clear = true, }),
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<leader>c", vim.cmd.cclose, { buffer = true, })
    vim.keymap.set("n", "o", function() vim.cmd.cc(vim.fn.line ".") end, { buffer = true, })
    vim.keymap.set("n", "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd.cclose()
      vim.cmd.cc(curr_line)
    end, { buffer = true, })

    vim.keymap.set("n", ">", function()
      local success = pcall(vim.cmd, "cnewer")
      if not success then
        require "helpers".notify.error "No newer list!"
      end
    end, { buffer = true, })

    vim.keymap.set("n", "<", function()
      local success = pcall(vim.cmd, "colder")
      if not success then
        require "helpers".notify.error "No older list!"
      end
    end, { buffer = true, })

    vim.keymap.set("n", "<C-o>", "<nop>", { buffer = true, })
    vim.keymap.set("n", "<C-i>", "<nop>", { buffer = true, })
    vim.keymap.set("n", "q", "<nop>", { buffer = true, })
  end,
})
