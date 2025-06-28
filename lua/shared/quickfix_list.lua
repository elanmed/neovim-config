local h = require "helpers"

--- @param bufname string
local function shorten_bufname(bufname)
  return vim.fs.basename(vim.fs.dirname(bufname)) .. "/" .. vim.fs.basename(bufname)
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
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_get_option_value("previewwindow", { win = win_id, }) then
        return true
      end
    end
    return false
  end

  local items = {}
  for _, item in pairs(qf_list) do
    local bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
    if #bufname > longest_bufname_len then
      longest_bufname_len = #bufname
    end

    if #tostring(item.lnum) > longest_row_len then
      longest_row_len = #tostring(item.lnum)
    end

    if #tostring(item.col) > longest_col_len then
      longest_col_len = #tostring(item.col)
    end
  end

  for index, item in pairs(qf_list) do
    local bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
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
      vim.api.nvim_win_get_width(h.curr.window) / (has_preview_win() and 1 or 2)
    ) - misc_padding
    if #formatted_item > win_width then
      formatted_item = formatted_item:sub(1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end

vim.api.nvim_create_autocmd({ "FileType", }, {
  callback = function()
    if vim.bo.buftype ~= "quickfix" then return end

    -- TODO: why does this require vim.schedule, and why can't it be in colorscheme.lua
    vim.schedule(function()
      vim.api.nvim_set_hl(h.curr.namespace, "qfLineNr", {})
      vim.api.nvim_set_hl(h.curr.namespace, "qfText", {})
    end)

    vim.keymap.set("n", "<Esc>", h.keys.vim_cmd_cb "cclose", { buffer = true, })
    vim.keymap.set("n", "<C-c>", h.keys.vim_cmd_cb "cclose", { buffer = true, })
    vim.keymap.set("n", "q", h.keys.vim_cmd_cb "cclose", { buffer = true, nowait = true, })

    vim.keymap.set("n", ">", function()
      local success = pcall(vim.cmd, "cnewer")
      if not success then
        h.notify.warn "No newer list!"
      end
    end, { buffer = true, desc = "Go to the next quickfix list", })

    vim.keymap.set("n", "<", function()
      local success = pcall(vim.cmd, "colder")
      if not success then
        h.notify.warn "No older list!"
      end
    end, { buffer = true, desc = "Go to the pre quickfix list", })
  end,
})
