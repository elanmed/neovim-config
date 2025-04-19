local M = {}

--- @class QuickfixItem
--- @field bufnr number the buffer number
--- @field module string the module name
--- @field lnum number the 1-indexed line number in the corresponding buffer
--- @field end_lnum number the 1-indexed end line number in the corresponding buffer, if multi-line
--- @field col number the 1-indexed column number in the corresponding buffer
--- @field end_col number the 1-indexed end column number in the corresponding buffer, if multi-line
--- @field vcol boolean
--- @field pattern any search pattern used to locate the error
--- @field text string description of the error
--- @field type string type of the error, 'E', '1', etc.
--- @field valid boolean recognized error message
--- @field user_data any custom data associated with the item, can be any type

M.setup = function()
  local QuickfixPreview = {}
  QuickfixPreview.__index = QuickfixPreview

  function QuickfixPreview:new()
    local this = {
      preview_win_id = nil,
      preview_disabled = false,
      parsed_buffers = {},
    }
    return setmetatable(this, QuickfixPreview)
  end

  function QuickfixPreview:is_closed()
    return self.preview_win_id == nil
  end

  --- @param disabled boolean
  function QuickfixPreview:set_preview_disabled(disabled)
    self.preview_disabled = disabled
  end

  --- @param opts { preview_win_id: number, qf_item_index: number}
  function QuickfixPreview:highlight(opts)
    local curr_line_nr = vim.fn.line "."
    if curr_line_nr ~= opts.qf_item_index then return end
    if self.preview_win_id ~= opts.preview_win_id then return end

    --- @type QuickfixItem[]
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

  function QuickfixPreview:open()
    --- @type QuickfixItem[]
    local qf_list = vim.fn.getqflist()
    if #qf_list == 0 then return end

    local preview_height                       = 10
    local preview_height_padding_bottom        = 3
    local curr_line_nr                         = vim.fn.line "."
    local curr_qf_item                         = qf_list[curr_line_nr]

    local enter_window                         = false
    self.preview_win_id                        = vim.api.nvim_open_win(curr_qf_item.bufnr, enter_window, {
      relative = "win",
      win = vim.api.nvim_get_current_win(),
      width = vim.api.nvim_win_get_width(0),
      height = preview_height,
      row = -1 * (preview_height + preview_height_padding_bottom),
      col = 1,
      border = "rounded",
      title = vim.api.nvim_buf_get_name(curr_qf_item.bufnr),
      title_pos = "center",
      focusable = false,
    })

    vim.wo[self.preview_win_id].relativenumber = false
    vim.wo[self.preview_win_id].number         = true
    vim.wo[self.preview_win_id].signcolumn     = "no"
    vim.wo[self.preview_win_id].colorcolumn    = ""
    vim.wo[self.preview_win_id].winblend       = 5
    vim.wo[self.preview_win_id].cursorline     = true

    self:highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line_nr, }
  end

  function QuickfixPreview:close()
    if self:is_closed() then
      return
    end

    if vim.api.nvim_win_is_valid(self.preview_win_id) then
      local force = true
      vim.api.nvim_win_close(self.preview_win_id, force)
      self.preview_win_id = nil
    end
  end

  function QuickfixPreview:refresh()
    if self.preview_disabled then return end

    if self:is_closed() then
      self:open()
      return
    end

    --- @type QuickfixItem[]
    local qf_list = vim.fn.getqflist()
    local curr_line_nr = vim.fn.line "."
    local curr_qf_item = qf_list[curr_line_nr]

    -- avoid creating a new window, reuse the existing one
    vim.api.nvim_win_set_buf(self.preview_win_id, curr_qf_item.bufnr)

    local buf_name = vim.api.nvim_buf_get_name(curr_qf_item.bufnr)
    vim.api.nvim_win_set_config(self.preview_win_id, {
      title = buf_name,
      title_pos = "center",
    })
    vim.api.nvim_win_set_cursor(self.preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })

    self:highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line_nr, }
  end

  local qf_preview = QuickfixPreview:new()

  vim.keymap.set("n", "gy", function()
    qf_preview:close()
    -- vim.fn.setqflist({}, "r") -- clear current
    vim.fn.setqflist({}, "f")
  end, { desc = "Clear all quickfix lists", })

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

  vim.api.nvim_create_autocmd({ "FileType", }, {
    pattern = "*",
    callback = function()
      if vim.bo.filetype ~= "qf" then return end

      vim.keymap.set("n", "t", function()
        if qf_preview:is_closed() then
          qf_preview:open()
          qf_preview:set_preview_disabled(false)
        else
          qf_preview:close()
          qf_preview:set_preview_disabled(true)
        end
      end, { buffer = true, })

      vim.keymap.set("n", "o", function()
        local curr_line_nr = vim.fn.line "."
        qf_preview:close()
        vim.cmd("cc " .. curr_line_nr)
      end, { buffer = true, })
    end,
  })
end

return M
