local helpers = require "homegrown_plugins.quickfix_preview.helpers"

--- @class QuickfixItem
--- @field bufnr number the buffer number
--- @field lnum number the 1-indexed line number in the corresponding buffer
--- @field col number the 1-indexed column number in the corresponding buffer

local QuickfixPreview = {}
QuickfixPreview.__index = QuickfixPreview

function QuickfixPreview:new()
  local this = { preview_win_id = nil, preview_disabled = false, parsed_buffers = {}, }
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
function QuickfixPreview:_highlight(opts)
  --- @type QuickfixItem[]
  local qf_list = vim.fn.getqflist()
  local curr_qf_item = qf_list[opts.qf_item_index]

  if not self.parsed_buffers[curr_qf_item.bufnr] then
    local filetype = vim.filetype.match { buf = curr_qf_item.bufnr, }
    if filetype == nil then return end

    local lang_ok, lang = pcall(vim.treesitter.language.get_lang, filetype)
    if not lang_ok then return end

    pcall(vim.treesitter.start, curr_qf_item.bufnr, lang)
    self.parsed_buffers[curr_qf_item.bufnr] = true
  end

  vim.api.nvim_win_set_cursor(opts.preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })
end

--- @class QuickfixPreviewOpenOpts
--- @field get_preview_win_opts? fun(qf_item: QuickfixItem):vim.wo
--- @field get_open_win_opts? fun(qf_item):vim.api.keyset.win_config

--- @param opts QuickfixPreviewOpenOpts | nil
function QuickfixPreview:_open(opts)
  opts = helpers.default(opts, {})
  local get_preview_win_opts = helpers.default(opts.get_preview_win_opts, function() return {} end)
  local get_open_win_opts = helpers.default(opts.get_open_win_opts, function() return {} end)

  --- @type QuickfixItem[]
  local qf_list = vim.fn.getqflist()
  if vim.tbl_count(qf_list) == 0 then return end

  local preview_height = 10
  local preview_height_padding_bottom = 3
  local curr_line_nr = vim.fn.line "."
  local curr_qf_item = qf_list[curr_line_nr]

  --- @type vim.api.keyset.win_config
  local default_open_win_opts = {
    relative = "win",
    win = vim.api.nvim_get_current_win(),
    width = vim.api.nvim_win_get_width(0),
    height = preview_height,
    row = -1 * (preview_height + preview_height_padding_bottom),
    col = 1,
    border = "single",
    title = vim.api.nvim_buf_get_name(curr_qf_item.bufnr),
    title_pos = "center",
    focusable = false,
  }
  local merged_open_win_opts = vim.tbl_extend("force", default_open_win_opts, get_open_win_opts(curr_qf_item))

  local enter_window = false
  self.preview_win_id = vim.api.nvim_open_win(curr_qf_item.bufnr, enter_window, merged_open_win_opts)

  for win_opt_key, win_opt_val in pairs(get_preview_win_opts(curr_qf_item)) do
    vim.wo[self.preview_win_id][win_opt_key] = win_opt_val
  end

  self:_highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line_nr, }
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

--- @param opts QuickfixPreviewOpenOpts | nil
function QuickfixPreview:open_or_refresh(opts)
  if self.preview_disabled then return end

  if self:is_closed() then
    self:_open(opts)
    return
  end

  --- @type QuickfixItem[]
  local qf_list = vim.fn.getqflist()
  local curr_line_nr = vim.fn.line "."
  local curr_qf_item = qf_list[curr_line_nr]

  -- avoid creating a new window, reuse the existing one
  vim.api.nvim_win_set_buf(self.preview_win_id, curr_qf_item.bufnr)

  local buf_name = vim.api.nvim_buf_get_name(curr_qf_item.bufnr)
  vim.api.nvim_win_set_config(self.preview_win_id, { title = buf_name, title_pos = "center", })
  vim.api.nvim_win_set_cursor(self.preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })

  self:_highlight { preview_win_id = self.preview_win_id, qf_item_index = curr_line_nr, }
end

return QuickfixPreview
