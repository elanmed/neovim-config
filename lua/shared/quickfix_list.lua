local h = require "helpers"

--- @param bufnr number
local function shorten_bufname(bufnr)
  return vim.fs.basename(vim.fn.bufname(bufnr))
end

vim.opt.quickfixtextfunc = "v:lua.GetQuickfixTextFunc"

--- @param num number
--- @param num_digits number
--- @param side 'left' | 'right'
local function pad_num(num, num_digits, side)
  if #tostring(num) >= num_digits then
    return tostring(num)
  end

  local num_spaces = num_digits - #tostring(num)
  if side == "left" then
    return string.rep(" ", num_spaces) .. tostring(num)
  end
  return tostring(num) .. string.rep(" ", num_spaces)
end

function _G.GetQuickfixTextFunc()
  local longest_bufname_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local function has_preview_win()
    for _, winnr in ipairs(vim.api.nvim_list_wins()) do
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      if vim.api.nvim_get_option_value("filetype", { buf = bufnr, }) == "quickfix-preview" then
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
        pad_num(item.lnum, longest_row_len, "left") ..
        ":" ..
        pad_num(item.col, longest_col_len, "right") ..
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
  h.utils.try_catch("cnext", "cfirst")
end)
vim.keymap.set("n", "<C-p>", function()
  h.utils.try_catch("cprev", "clast")
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<Esc>", h.keys.vim_cmd_cb "cclose", { buffer = true, })
    vim.keymap.set("n", "<C-c>", h.keys.vim_cmd_cb "cclose", { buffer = true, })
    vim.keymap.set("n", "q", h.keys.vim_cmd_cb "cclose", { buffer = true, nowait = true, })
    vim.keymap.set("n", "o", h.keys.vim_cmd_cb("cc " .. vim.fn.line "."), { buffer = true, })
    vim.keymap.set("n", "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd "cclose"
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, })

    local next = function()
      local next_qf_index = (function()
        local curr_qf_index = vim.fn.line "."
        local qf_list = vim.fn.getqflist()
        if curr_qf_index == #qf_list then
          return 1
        end
        return curr_qf_index + 1
      end)()

      if next_qf_index == nil then return end
      vim.fn.setqflist({}, "a", { ["idx"] = next_qf_index, })
    end
    vim.keymap.set("n", "<C-n>", next, { buffer = true, })

    local prev = function()
      local prev_qf_index = (function()
        local curr_qf_index = vim.fn.line "."
        local qf_list = vim.fn.getqflist()
        if curr_qf_index == 1 then
          return #qf_list
        end
        return curr_qf_index - 1
      end)()

      if prev_qf_index == nil then return end
      vim.fn.setqflist({}, "a", { ["idx"] = prev_qf_index, })
    end
    vim.keymap.set("n", "<C-p>", prev, { buffer = true, })

    vim.keymap.set("n", ">", function()
      local success = pcall(vim.cmd, "cnewer")
      if not success then
        h.notify.error "No newer list!"
      end
    end, { buffer = true, desc = "Go to the next quickfix list", })

    vim.keymap.set("n", "<", function()
      local success = pcall(vim.cmd, "colder")
      if not success then
        h.notify.error "No older list!"
      end
    end, { buffer = true, desc = "Go to the pre quickfix list", })

    vim.keymap.set("n", "<C-o>", "<nop>", { buffer = true, })
    vim.keymap.set("n", "<C-i>", "<nop>", { buffer = true, })
  end,
})
