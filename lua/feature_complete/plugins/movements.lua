local h = require "shared.helpers"
local flash = require "flash"

local ns_id = vim.api.nvim_create_namespace "Elan"

local DIMMED = false
local HIGHLIGHTED_LINE = nil


-- row and col params are expected to be already 0-indexed
--- @param opts { row: number, start_col: number, end_col: number, hl_group: string }
local function apply_highlight(opts)
  vim.hl.range(
    h.curr.buffer,
    ns_id,
    opts.hl_group,
    { opts.row, opts.start_col, },
    { opts.row, opts.end_col, }
  )
end

--- @param str string
local function get_orders(str)
  -- bee -> { "b" = 1, "e" = 2 }
  local char_to_num_occurrence = {}

  -- bee -> { 1 = 1, 2 = 1, 3 = 2 }
  local occurrence_as_str = {}

  for i = 1, #str do
    local char = str:sub(i, i)

    if string.match(char, "%a") then
      if char_to_num_occurrence[char] == nil then
        char_to_num_occurrence[char] = 0
      end

      char_to_num_occurrence[char] = char_to_num_occurrence[char] + 1
    else
      char_to_num_occurrence[char] = -1
    end

    occurrence_as_str[i] = char_to_num_occurrence[char]
  end

  return occurrence_as_str
end

--- @param opts { forward: boolean }
local function highlight(opts)
  local curr_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(h.curr.buffer)
  local curr_row_1_indexed = cursor_pos[1]
  local curr_col_0_indexed = cursor_pos[2]

  local row_0_indexed = curr_row_1_indexed - 1
  local col_1_indexed = curr_col_0_indexed + 1

  local forward_start_col_1_indexed = col_1_indexed + 1
  local forward_subbed = curr_line:sub(forward_start_col_1_indexed)

  local backward_start_col_1_indexed = col_1_indexed
  local backward_subbed = curr_line:sub(0, backward_start_col_1_indexed)

  local subbed = opts.forward and forward_subbed or backward_subbed

  -- bee
  -- 123
  -- bee -> { 1 = 1, 2 = 1, 3 = 2 }
  for offset, value in pairs(get_orders(subbed)) do
    local hl_group
    if value == 1 then
      hl_group = "ElanFirst"
    elseif value == 2 then
      hl_group = "ElanSecond"
    else
      hl_group = "ElanDimmed"
    end

    local highlight_col_1_indexed = col_1_indexed + offset
    local highlight_col_0_indexed = highlight_col_1_indexed - 1

    apply_highlight {
      row = row_0_indexed,
      start_col = highlight_col_0_indexed,
      end_col = highlight_col_0_indexed + 1,
      hl_group = hl_group,
    }
  end


  DIMMED = true
  HIGHLIGHTED_LINE = row_0_indexed
  vim.cmd "redraw"
end

local function cleanup_highlight()
  if HIGHLIGHTED_LINE == nil then
    h.notify.error "HIGHLIGHTED_LINE is nil!"
    return
  end
  vim.api.nvim_buf_clear_namespace(h.curr.buffer, ns_id, HIGHLIGHTED_LINE, HIGHLIGHTED_LINE + 1)
end

vim.api.nvim_create_autocmd({ "CursorMoved", }, {
  pattern = "*",
  callback = function()
    if DIMMED == true then
      cleanup_highlight()
      DIMMED = false
      HIGHLIGHTED_LINE = nil
    end
  end,
})

--- @param opts { key: "f"|"F"|"t"|"T", forward: boolean }
local function on_key(opts)
  highlight { forward = opts.forward, }
  return opts.key
end

h.keys.map({ "n", "x", "o", }, "f", function() on_key { key = "f", forward = true, } end,
  { buffer = h.curr.buffer, expr = true, })
h.keys.map({ "n", "x", "o", }, "F", function() on_key { key = "F", forward = false, } end,
  { buffer = h.curr.buffer, expr = true, })

flash.setup {
  modes = {
    char = {
      enabled = false,
    },
  },
  prompt = {
    prefix = { { "󱐋 ", "FlashPromptIcon", }, },
  },
}

h.keys.map("n", "s", function() flash.jump { forward = true, } end)
h.keys.map("n", "S", function() flash.jump { forward = false, } end)
h.keys.map("n", "<leader>sa", function()
  -- https://github.com/folke/flash.nvim#-examples
  flash.jump {
    forward = true,
    search = {
      mode = "search",
      max_length = 0,
    },
    label = {
      after = { 0, 0, },
    },
    pattern = "^",
  }
end)

local harpoon = require "harpoon"
harpoon:setup {
  settings = {
    save_on_toggle = true,
  },
}

h.keys.map("n", "<leader>th",
  function()
    harpoon.ui:toggle_quick_menu(harpoon:list(), { ui_max_width = 80, })
  end,
  { desc = "Toggle the harpoon window", })
h.keys.map("n", "<leader>yo", function() harpoon:list():add() end, { desc = "Yank an file into harpoon", })

require "marks".setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "me",         -- nExt
    prev = "mr",         -- pRev
    delete_line = "dml", -- delete mark on the current Line
    delete_buf = "dma",  -- delete All
  },
}
