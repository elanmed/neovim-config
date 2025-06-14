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
  local curr_qf_index = vim.fn.line "."

  local qf_list = vim.fn.getqflist()
  if curr_qf_index == vim.tbl_count(qf_list) then
    if circular then
      return 1
    else
      return curr_qf_index
    end
  end
  return curr_qf_index + 1
end

--- @param circular boolean
M.get_prev_qf_index = function(circular)
  local curr_qf_index = vim.fn.line "."

  local qf_list = vim.fn.getqflist()
  if curr_qf_index == 1 then
    if circular then
      return vim.tbl_count(qf_list)
    else
      return curr_qf_index
    end
  end
  return curr_qf_index - 1
end

M.send_cr = function()
  local from_part_legacy_vim_param = true
  local do_lt = false
  local escape_keycodes = true
  local double_escape_keycodes = false

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      "<CR>",
      from_part_legacy_vim_param,
      do_lt,
      escape_keycodes
    ),
    "n",
    double_escape_keycodes
  )
end

M.find_main_window = function()
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf_id, })
    local win_config = vim.api.nvim_win_get_config(win_id)

    if buf_type == "quickfix" then
      goto continue
    elseif win_config.relative ~= "" then
      goto continue
    else
      return win_id
    end

    ::continue::
  end

  return nil
end

return M
