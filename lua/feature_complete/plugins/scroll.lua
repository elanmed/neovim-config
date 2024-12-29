local h = require "shared.helpers"
local neoscroll = require "neoscroll"

local function is_neoscroll_override_filetype()
  return h.table_contains_value({ "oil", }, vim.bo.filetype)
end

neoscroll.setup {
  mappings = { "<C-u>", "<C-d>", },
  hide_cursor = false,
  pre_hook = function()
    if is_neoscroll_override_filetype() then return end

    h.set.cursorline = true
    vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual", })
  end,
  post_hook = function()
    if is_neoscroll_override_filetype() then return end
    h.set.cursorline = false
  end,
}
h.nmap("z", function() neoscroll.zz { half_win_duration = 250, } end)

local function get_current_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function is_first_line()
  local current_line = get_current_line()
  return current_line == 1
end

local function is_last_line()
  local current_line = get_current_line()
  local last_line = vim.fn.line "$"
  return current_line == last_line
end

local modes = { "n", "v", "i", }
for _, mode in pairs(modes) do
  h.map(mode, "<C-u>", function()
    h.send_normal_keys "0"
    if is_neoscroll_override_filetype() then
      neoscroll.ctrl_u { duration = 250, }
      return
    end

    if is_last_line() then
      h.send_normal_keys "M"
    else
      neoscroll.ctrl_u { duration = 250, }
    end
  end)

  h.map(mode, "<C-d>", function()
    h.send_normal_keys "0"
    if is_neoscroll_override_filetype() then
      neoscroll.ctrl_d { duration = 250, }
      return
    end

    if is_first_line() then
      h.send_normal_keys "M"
    else
      neoscroll.ctrl_d { duration = 250, }
    end
  end)
end

local mini_map = require "mini.map"

mini_map.setup {
  symbols = {
    encode = mini_map.gen_encode_symbols.dot "4x2",
    scroll_line = "▶",
  },
}

local function has_split()
  return vim.api.nvim_win_get_width(0) ~= vim.api.nvim_get_option "columns"
end

-- opening/closing a split triggers WinEnter, not BufEnter
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", }, {
  pattern = "*",
  callback = function()
    if h.table_contains_value({ "oil", "fugitive", "markdown", "markdown.mdx", }, vim.bo.filetype) or has_split() then
      mini_map.close()
    else
      mini_map.open()
    end
  end,
})

-- man doesn't fire the BufEnter event
vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "man",
  callback = function()
    mini_map.close()
  end,
})
