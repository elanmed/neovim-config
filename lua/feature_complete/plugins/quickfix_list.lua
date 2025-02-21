local h = require "shared.helpers"

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.table_contains_value({ "qf", "aerial", "undotree", }, vim.bo.filetype) then
      h.set.cursorline = true
    else
      h.set.cursorline = false
    end
  end,
})

-- WIP: quickfix preview
-- TODO: keep preview open with cnext, cprev

local PREVIEW_WIN_ID = nil
local PREVIEW_TOGGLED_OFF = false

local function maybe_close_preview()
  if PREVIEW_WIN_ID == nil then return end

  if vim.api.nvim_win_is_valid(PREVIEW_WIN_ID) then
    local force = true
    vim.api.nvim_win_close(PREVIEW_WIN_ID, force)
    PREVIEW_WIN_ID = nil
  end
end

local function open_preview()
  local qf_list = vim.fn.getqflist()
  if h.tbl.size(qf_list) == 0 then return end

  local qf_win_id = vim.api.nvim_get_current_win()
  maybe_close_preview()

  local preview_height                  = 10
  local preview_height_padding_bottom   = 2

  --- @class vim.api.keyset.win_config
  local win_opts                        = {
    relative = "win",
    win = qf_win_id,
    width = vim.api.nvim_win_get_width(h.curr.window),
    height = preview_height,
    row = -1 * (preview_height + preview_height_padding_bottom),
    col = 1,
    border = "rounded",
    title = "Preview",
    title_pos = "center",
    focusable = false,
    zindex = 200,
  }

  local curr_line                       = vim.fn.line "."
  local curr_qf_item                    = qf_list[curr_line]
  local enter_window                    = false
  PREVIEW_WIN_ID                        = vim.api.nvim_open_win(curr_qf_item.bufnr, enter_window, win_opts)

  vim.wo[PREVIEW_WIN_ID].relativenumber = false
  vim.wo[PREVIEW_WIN_ID].number         = true
  vim.wo[PREVIEW_WIN_ID].signcolumn     = "no"
  vim.wo[PREVIEW_WIN_ID].colorcolumn    = ""
  vim.wo[PREVIEW_WIN_ID].winblend       = 5
  vim.wo[PREVIEW_WIN_ID].cursorline     = true

  vim.api.nvim_buf_call(curr_qf_item.bufnr, function()
    vim.cmd "filetype detect"
    -- vim.cmd "syntax on"
    vim.treesitter.start(curr_qf_item.bufnr)
  end)

  vim.api.nvim_win_set_cursor(PREVIEW_WIN_ID, { curr_qf_item.lnum, curr_qf_item.col, })
end

vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end
    maybe_close_preview()
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end
    if PREVIEW_TOGGLED_OFF then return end
    open_preview()
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    h.keys.map({ "n", }, "t", function()
      if PREVIEW_WIN_ID == nil then
        open_preview()
        PREVIEW_TOGGLED_OFF = false
      else
        maybe_close_preview()
        PREVIEW_TOGGLED_OFF = true
      end
    end, { buffer = true, })

    h.keys.map({ "n", }, "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd "cclose"
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, })

    h.keys.map({ "n", }, "o", function()
      local curr_line = vim.fn.line "."
      maybe_close_preview()
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, })
  end,
})

h.set.quickfixtextfunc = "v:lua.GetQuickfixTextFunc"

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
  local longest_filename_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local items = {}
  for _, item in pairs(qf_list) do
    local curr_bufname = vim.fn.bufname(item.bufnr)
    if #curr_bufname > longest_filename_len then
      longest_filename_len = #curr_bufname
    end

    if #tostring(item.lnum) > longest_row_len then
      longest_row_len = #tostring(item.lnum)
    end

    if #tostring(item.col) > longest_col_len then
      longest_col_len = #tostring(item.col)
    end
  end

  local misc_win_padding = 10
  local win_width = vim.api.nvim_win_get_width(h.curr.window) - misc_win_padding

  for index, item in pairs(qf_list) do
    local curr_bufname = vim.fn.bufname(item.bufnr)
    local buffer_padding_right = longest_filename_len - #curr_bufname
    local formatted_item =
        curr_bufname ..
        string.rep(" ", buffer_padding_right) ..
        " || " ..
        pad_num(item.lnum, longest_row_len, "left") ..
        ":" ..
        pad_num(item.col, longest_col_len, "right") ..
        " || " ..
        vim.fn.trim(item.text)

    if #formatted_item > win_width then
      formatted_item = string.sub(formatted_item, 1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end
