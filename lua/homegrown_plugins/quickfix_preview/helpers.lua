local M = {}

--- @param try string
--- @param catch string
M.try_catch = function(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
M.default = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

M.get_curr_qf_index = function()
  local info = vim.fn.getqflist { ["idx"] = 0, }
  if info.idx == nil then return nil end
  return info.idx
end

--- @param circular boolean
M.get_next_qf_index = function(circular)
  local curr_qf_index = M.get_curr_qf_index()
  if curr_qf_index == nil then return nil end
  local qf_list = vim.fn.getqflist()
  if curr_qf_index == #qf_list then
    if circular then return 1 else return curr_qf_index end
  end
  return curr_qf_index + 1
end

--- @param circular boolean
M.get_prev_qf_index = function(circular)
  local curr_qf_index = M.get_curr_qf_index()
  if curr_qf_index == nil then return nil end
  local qf_list = vim.fn.getqflist()
  if curr_qf_index == 1 then
    if circular then
      return #qf_list
    else
      return curr_qf_index
    end
  end
  return curr_qf_index - 1
end

M.find_main_window = function()
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf_id, })
    local win_config = vim.api.nvim_win_get_config(win_id)
    local is_preview_win = vim.api.nvim_get_option_value("previewwindow", { win = win_id, })

    if is_preview_win then goto continue end
    if buf_type == "quickfix" then goto continue end
    if win_config.relative ~= "" then goto continue end

    ::continue::
  end

  return nil
end

return M
