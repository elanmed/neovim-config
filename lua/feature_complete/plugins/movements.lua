local h = require "shared.helpers"
local flash = require "flash"

local CharOccurrencePreview = {}
CharOccurrencePreview.__index = CharOccurrencePreview

function CharOccurrencePreview:new()
  local ns_id = vim.api.nvim_create_namespace "CharOccurrencePreview"

  local this = {
    is_dimmed = false,
    highlighted_line = nil,
    ns_id = ns_id,
  }
  return setmetatable(this, CharOccurrencePreview)
end

--- @param opts { highlighted_line: number }
function CharOccurrencePreview:toggle_on(opts)
  self.is_dimmed = true
  self.highlighted_line = opts.highlighted_line
end

function CharOccurrencePreview:toggle_off()
  self.is_dimmed = false
  self.highlighted_line = nil
end

-- row and col params are expected to be already 0-indexed
--- @param opts { row: number, start_col: number, end_col: number, hl_group: string }
function CharOccurrencePreview:apply_highlight(opts)
  vim.hl.range(
    h.curr.buffer,
    self.ns_id,
    opts.hl_group,
    { opts.row, opts.start_col, },
    { opts.row, opts.end_col, }
  )
end

--- @param str string
function CharOccurrencePreview:get_char_occurrences(str)
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
function CharOccurrencePreview:highlight(opts)
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
  local backward_subbed_reversed = backward_subbed:reverse()

  local forward_orders = self:get_char_occurrences(forward_subbed)
  local backward_orders = self:get_char_occurrences(backward_subbed_reversed)
  local orders = opts.forward and forward_orders or backward_orders
  for offset, value in pairs(orders) do
    local hl_group
    if value == 1 then
      hl_group = "CharOccurrencePreviewFirst"
    elseif value == 2 then
      hl_group = "CharOccurrencePreviewSecond"
    elseif value == 3 then
      hl_group = "CharOccurrencePreviewThird"
    else
      hl_group = "CharOccurrencePreviewDimmed"
    end

    local highlight_col_1_indexed
    if opts.forward then
      highlight_col_1_indexed = col_1_indexed + offset
    else
      highlight_col_1_indexed = col_1_indexed - offset + 1 -- TODO: why do I need + 1
    end

    local highlight_col_0_indexed = highlight_col_1_indexed - 1

    self:apply_highlight {
      row = row_0_indexed,
      start_col = highlight_col_0_indexed,
      end_col = highlight_col_0_indexed + 1,
      hl_group = hl_group,
    }
  end

  self:toggle_on { highlighted_line = row_0_indexed, }
  vim.cmd "redraw"
end

function CharOccurrencePreview:maybe_clear_highlight()
  if self.highlighted_line == nil then
    return
  end
  vim.api.nvim_buf_clear_namespace(h.curr.buffer, self.ns_id, self.highlighted_line, self.highlighted_line + 1)
end

local char_occurrence_preview = CharOccurrencePreview:new()

--- @param opts { key: "f"|"F"|"t"|"T", forward: boolean }
local function on_key(opts)
  -- the `schedule` ensures that the highlight is cleared after operator pending mode is complete
  -- example:
  -- - in normal mode, `f` is pressed
  -- - on_key begins to run
  -- - the highlight is added
  -- - the clearing cb is scheduled, but not run
  -- - on_key waits for `f`'s operator before finishing
  -- - an operator is pressed, i.e. `l`
  -- - on_key finishes running
  -- - the clearing cb is run
  vim.schedule(function()
    if char_occurrence_preview.is_dimmed then
      char_occurrence_preview:maybe_clear_highlight()
      char_occurrence_preview:toggle_off()
    end
  end)

  char_occurrence_preview:highlight { forward = opts.forward, }
  return opts.key
end

h.keys.map({ "n", "v", "o", }, "f", function() return on_key { key = "f", forward = true, } end, { expr = true, })
h.keys.map({ "n", "v", "o", }, "F", function() return on_key { key = "F", forward = false, } end, { expr = true, })
h.keys.map({ "n", "v", "o", }, "t", function() return on_key { key = "t", forward = true, } end, { expr = true, })
h.keys.map({ "n", "v", "o", }, "T", function() return on_key { key = "T", forward = false, } end, { expr = true, })

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
