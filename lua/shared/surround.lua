local function get_pair(char)
  local pairs_map = {
    ["("] = { "(", ")", },
    [")"] = { "(", ")", },
    ["["] = { "[", "]", },
    ["]"] = { "[", "]", },
    ["{"] = { "{", "}", },
    ["}"] = { "{", "}", },
    ["<"] = { "<", ">", },
    [">"] = { "<", ">", },
  }
  local pair = pairs_map[char]
  if pair then
    return pair[1], pair[2]
  end
  return char, char
end

--- @param char string
local function find_surrounding_pair_0i(char)
  local saved_visual_hl = vim.api.nvim_get_hl(0, { name = "Visual", })
  local saved_cursor = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_buf_del_mark(0, "<")
  vim.api.nvim_buf_del_mark(0, ">")

  vim.api.nvim_set_hl(0, "Visual", { link = "Normal", })
  vim.cmd("normal! va" .. char)
  vim.cmd "normal! \x1b"
  vim.api.nvim_set_hl(0, "Visual", saved_visual_hl)
  vim.api.nvim_win_set_cursor(0, saved_cursor)

  local open_pos = vim.api.nvim_buf_get_mark(0, "<")
  if open_pos[1] == 0 and open_pos[2] == 0 then return nil end

  local close_pos = vim.api.nvim_buf_get_mark(0, ">")
  if close_pos[1] == 0 and close_pos[2] == 0 then return nil end

  if open_pos[1] == close_pos[1] and open_pos[2] == close_pos[2] then return nil end

  local one_idx_offset = 1

  return {
    open_row = open_pos[1] - one_idx_offset,
    open_col = open_pos[2],
    close_row = close_pos[1] - one_idx_offset,
    close_col = close_pos[2],
  }
end

vim.keymap.set("n", "ds", function()
  local char = vim.fn.nr2char(vim.fn.getchar())

  local pair_pos = find_surrounding_pair_0i(char)
  if pair_pos == nil then
    require "helpers".notify.error "No matching pair"
    return
  end

  vim.api.nvim_buf_set_text(0,
    pair_pos.close_row, pair_pos.close_col, pair_pos.close_row, pair_pos.close_col + 1,
    { "", }
  )
  vim.api.nvim_buf_set_text(0,
    pair_pos.open_row, pair_pos.open_col, pair_pos.open_row, pair_pos.open_col + 1,
    { "", }
  )
end)

vim.keymap.set("n", "cs", function()
  local old_char = vim.fn.nr2char(vim.fn.getchar())
  local new_char = vim.fn.nr2char(vim.fn.getchar())

  local old_pair_pos = find_surrounding_pair_0i(old_char)
  if old_pair_pos == nil then
    require "helpers".notify.error "No matching pair"
    return
  end

  local new_open, new_close = get_pair(new_char)

  vim.api.nvim_buf_set_text(0,
    old_pair_pos.close_row, old_pair_pos.close_col, old_pair_pos.close_row, old_pair_pos.close_col + 1,
    { new_close, }
  )
  vim.api.nvim_buf_set_text(0,
    old_pair_pos.open_row, old_pair_pos.open_col, old_pair_pos.open_row, old_pair_pos.open_col + 1,
    { new_open, }
  )
end)
