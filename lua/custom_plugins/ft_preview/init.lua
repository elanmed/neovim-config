local M = {}

M.setup = function()
  vim.api.nvim_set_hl(0, "FTPreviewFirst", { link = "Normal", })
  vim.api.nvim_set_hl(0, "FTPreviewSecond", { link = "DiagnosticWarn", })
  vim.api.nvim_set_hl(0, "FTPreviewThird", { link = "DiagnosticError", })
  vim.api.nvim_set_hl(0, "FTPreviewDimmed", { link = "Comment", })

  local FTPreview = {}
  FTPreview.__index = FTPreview

  function FTPreview:new()
    local ns_id = vim.api.nvim_create_namespace "FTPreview"

    local this = {
      is_highlighted = false,
      highlighted_line = nil,
      ns_id = ns_id,
    }
    return setmetatable(this, FTPreview)
  end

  --- @param opts { highlighted_line: number }
  function FTPreview:toggle_on(opts)
    self.is_highlighted = true
    self.highlighted_line = opts.highlighted_line
  end

  function FTPreview:toggle_off()
    self.is_highlighted = false
    self.highlighted_line = nil
  end

  -- row and col params are expected to be already 0-indexed
  --- @param opts { row: number, start_col: number, end_col: number, hl_group: string }
  function FTPreview:apply_highlight(opts)
    vim.hl.range(
      0,
      self.ns_id,
      opts.hl_group,
      { opts.row, opts.start_col, },
      { opts.row, opts.end_col, }
    )
  end

  --- @param str string
  function FTPreview:get_char_occurrence_at_position(str)
    -- bee -> { "b" = 1, "e" = 2 }
    local char_to_num_occurrence = {}
    -- bee -> { 1 = 1, 2 = 1, 3 = 2 }
    local char_occurrence_at_position = {}

    for i = 1, #str do
      local char = str:sub(i, i)

      if char_to_num_occurrence[char] == nil then
        char_to_num_occurrence[char] = 0
      end
      char_to_num_occurrence[char] = char_to_num_occurrence[char] + 1

      char_occurrence_at_position[i] = char_to_num_occurrence[char]
    end

    return char_occurrence_at_position
  end

  --- @param opts { forward: boolean }
  function FTPreview:highlight(opts)
    local curr_line = vim.api.nvim_get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    local row_1_indexed = cursor_pos[1]
    local row_0_indexed = row_1_indexed - 1

    local col_0_indexed = cursor_pos[2]
    local col_1_indexed = col_0_indexed + 1

    local orders = nil
    if opts.forward then
      -- highlight starting with the char after the cursor
      local forward_start = col_1_indexed + 1
      local forward_subbed = curr_line:sub(forward_start)

      orders = self:get_char_occurrence_at_position(forward_subbed)
    else
      -- highlight starting with the char before the cursor
      local backward_start = col_1_indexed - 1
      local backward_subbed = curr_line:sub(1, backward_start + 1) -- exclusive
      local backward_subbed_reversed = backward_subbed:reverse()

      orders = self:get_char_occurrence_at_position(backward_subbed_reversed)
    end

    for offset, value in pairs(orders) do
      local hl_group
      if value == 1 then
        hl_group = "FTPreviewFirst"
      elseif value == 2 then
        hl_group = "FTPreviewSecond"
      elseif value == 3 then
        hl_group = "FTPreviewThird"
      else
        hl_group = "FTPreviewDimmed"
      end

      local highlight_col_1_indexed
      if opts.forward then
        highlight_col_1_indexed = col_1_indexed + offset
      else
        highlight_col_1_indexed = col_1_indexed - offset
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

  function FTPreview:maybe_clear_highlight()
    if self.highlighted_line == nil then
      return
    end
    vim.api.nvim_buf_clear_namespace(0, self.ns_id, self.highlighted_line, self.highlighted_line + 1)
  end

  local char_occurrence_preview = FTPreview:new()

  --- @param opts { key: "f"|"F"|"t"|"T", forward: boolean }
  local function on_key(opts)
    -- the `schedule` ensures that the highlight is cleared after operator pending mode is complete
    -- example:
    -- - in normal mode, `f` is pressed
    -- - on_key begins to run
    -- - the highlight is added
    -- - the clearing cb is scheduled, but not run
    -- - on_key waits for `f`'s operator before finishing
    -- - an operator is pressed
    -- - on_key finishes running
    -- - the clearing cb is run
    vim.schedule(function()
      if char_occurrence_preview.is_highlighted then
        char_occurrence_preview:maybe_clear_highlight()
        char_occurrence_preview:toggle_off()
      end
    end)

    char_occurrence_preview:highlight { forward = opts.forward, }
    return opts.key
  end

  vim.keymap.set({ "n", "v", "o", }, "f", function() return on_key { key = "f", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "F", function() return on_key { key = "F", forward = false, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "t", function() return on_key { key = "t", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "T", function() return on_key { key = "T", forward = false, } end, { expr = true, })
end

return M
