local h = require "shared.helpers"

--- @param str string
--- @param start string
local function starts_with(str, start)
  -- http://lua-users.org/wiki/StringRecipes
  return str:sub(1, #start) == start
end

--- @param item_text string
local function shorten_bufname(item_text)
  local cwd_name = vim.fn.getcwd()

  if starts_with(item_text, cwd_name) then
    local slash_offset = 1
    return item_text:sub(#cwd_name + 1 + slash_offset)
  end

  return item_text
end

local QfPreview = {}
QfPreview.__index = QfPreview

function QfPreview:new()
  local this = {
    preview_win_id = nil,
    preview_disabled = false,
    parsed_buffers = {},
    highlighting = false,
  }
  return setmetatable(this, QfPreview)
end

function QfPreview:is_closed()
  return self.preview_win_id == nil
end

--- @param opts { preview_win_id: number, qf_item_index: number}
function QfPreview:highlight(opts)
  local curr_line = vim.fn.line "."
  if curr_line ~= opts.qf_item_index then return end
  if self.preview_win_id ~= opts.preview_win_id then return end

  local qf_list      = vim.fn.getqflist()
  local curr_qf_item = qf_list[opts.qf_item_index]

  if not self.parsed_buffers[curr_qf_item.bufnr] then
    vim.api.nvim_buf_call(curr_qf_item.bufnr, function()
      vim.cmd "filetype detect"
      vim.treesitter.start(curr_qf_item.bufnr)
    end)
    self.parsed_buffers[curr_qf_item.bufnr] = true
  end

  vim.api.nvim_win_set_cursor(opts.preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })
end

--- @param disabled boolean
function QfPreview:set_preview_disabled(disabled)
  self.preview_disabled = disabled
end

function QfPreview:open()
  local qf_list = vim.fn.getqflist()
  if #qf_list == 0 then return end

  local qf_win_id                            = vim.api.nvim_get_current_win()

  local preview_height                       = 10
  local preview_height_padding_bottom        = 2
  local curr_line                            = vim.fn.line "."
  local curr_qf_item                         = qf_list[curr_line]
  local buf_name                             = vim.api.nvim_buf_get_name(curr_qf_item.bufnr)

  local enter_window                         = false
  self.preview_win_id                        = vim.api.nvim_open_win(curr_qf_item.bufnr, enter_window, {
    relative = "win",
    win = qf_win_id,
    width = vim.api.nvim_win_get_width(h.curr.window),
    height = preview_height,
    row = -1 * (preview_height + preview_height_padding_bottom),
    col = 1,
    border = "rounded",
    title = shorten_bufname(buf_name),
    title_pos = "center",
    focusable = false,
  })

  vim.wo[self.preview_win_id].relativenumber = false
  vim.wo[self.preview_win_id].number         = true
  vim.wo[self.preview_win_id].signcolumn     = "no"
  vim.wo[self.preview_win_id].colorcolumn    = ""
  vim.wo[self.preview_win_id].winblend       = 5
  vim.wo[self.preview_win_id].cursorline     = true

  self:highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line, }
end

function QfPreview:close()
  if self:is_closed() then
    return
  end

  if vim.api.nvim_win_is_valid(self.preview_win_id) then
    local force = true
    vim.api.nvim_win_close(self.preview_win_id, force)
    self.preview_win_id = nil
  end
end

function QfPreview:refresh()
  if self.preview_disabled then return end

  if self:is_closed() then
    self:open()
    return
  end

  local qf_list = vim.fn.getqflist()
  local curr_line = vim.fn.line "."
  local curr_qf_item = qf_list[curr_line]

  vim.api.nvim_win_set_buf(self.preview_win_id, curr_qf_item.bufnr)

  local buf_name = vim.api.nvim_buf_get_name(curr_qf_item.bufnr)
  vim.api.nvim_win_set_config(self.preview_win_id, {
    title = shorten_bufname(buf_name),
    title_pos = "center",
  })

  vim.api.nvim_win_set_cursor(self.preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })

  self:highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line, }
end

local qf_preview = QfPreview:new()

h.keys.map("n", "gy", function()
  qf_preview:close()
  -- vim.fn.setqflist({}, "r") -- clear current
  vim.fn.setqflist({}, "f")
end, { desc = "Clear the current quickfix list", })

vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end
    qf_preview:close()
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end
    qf_preview:refresh()
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end

    local qf_list = vim.fn.getqflist()

    if #qf_list > 100 then
      local truncated_list = {}
      for i = 1, 100 do
        truncated_list[i] = qf_list[i]
      end

      local replace = "r"
      vim.fn.setqflist(truncated_list, replace)
      h.notify.info "truncated the quickfix list to 100 items"
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    h.keys.map("n", "gdu", function()
      vim.fn.setqflist(vim.fn.getqflist())
      h.notify.info "Created a new list!"
    end, { buffer = true, })

    h.keys.map("n", "t", function()
      if qf_preview:is_closed() then
        qf_preview:open()
        qf_preview:set_preview_disabled(false)
      else
        qf_preview:close()
        qf_preview:set_preview_disabled(true)
      end
    end, { buffer = true, })

    h.keys.map("n", "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd "cclose"
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, })

    h.keys.map("n", "o", function()
      local curr_line = vim.fn.line "."
      qf_preview:close()
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, })

    h.keys.map("n", "<C-n>", function()
      vim.cmd "Cnext"
      vim.cmd "copen"
    end, { buffer = true, })

    h.keys.map("n", "<C-p>", function()
      vim.cmd "Cprev"
      vim.cmd "copen"
    end, { buffer = true, })

    h.keys.map("n", ">", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      local success = pcall(vim.cmd, "cnewer")
      if not success then
        h.notify.warn "No newer list!"
      end
    end, { buffer = true, })
    h.keys.map("n", "<", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      local success = pcall(vim.cmd, "colder")
      if not success then
        h.notify.warn "No older list!"
      end
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
  local longest_bufname_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local items = {}
  for _, item in pairs(qf_list) do
    local curr_bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
    if #curr_bufname > longest_bufname_len then
      longest_bufname_len = #curr_bufname
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
    local curr_bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
    local buffer_padding_right = longest_bufname_len - #curr_bufname
    local formatted_item =
        curr_bufname ..
        string.rep(" ", buffer_padding_right) ..
        " | " ..
        pad_num(item.lnum, longest_row_len, "left") ..
        ":" ..
        pad_num(item.col, longest_col_len, "right") ..
        " | " ..
        vim.fn.trim(item.text)

    if #formatted_item > win_width then
      formatted_item = string.sub(formatted_item, 1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end
