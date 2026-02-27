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

--- @param open string
--- @param close string
local function find_surrounding_pair_0i(open, close)
  local open_row_1i, open_col_1i = unpack(vim.fn.searchpairpos(open, "", close, "bnW"))
  local close_row_1i, close_col_1i = unpack(vim.fn.searchpairpos(open, "", close, "nW"))
  if open_row_1i == 0 or close_row_1i == 0 or open_row_1i == -1 or close_row_1i == -1 then
    return nil
  end
  return {
    open_row = open_row_1i - 1,
    open_col = open_col_1i - 1,
    close_row = close_row_1i - 1,
    close_col = close_col_1i - 1,
  }
end

vim.keymap.set("n", "ds", function()
  local char = vim.fn.nr2char(vim.fn.getchar())
  local pair_pos = find_surrounding_pair_0i(get_pair(char))
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

  local old_pair_pos = find_surrounding_pair_0i(get_pair(old_char))
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
