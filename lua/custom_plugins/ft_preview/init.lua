local FTPreview = require "custom_plugins.ft_preview.class"
local char_occurrence_preview = FTPreview:new()

--- @param on_key_opts { key: "f"|"F"|"t"|"T", forward: boolean }
local function on_key(on_key_opts)
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

  char_occurrence_preview:highlight { forward = on_key_opts.forward, }
  return on_key_opts.key
end

local M = {}

--- @class FTPreviewOpts
--- @field enable boolean Enable the plugin, defaults to `false`

--- @param opts FTPreviewOpts
M.setup = function(opts)
  opts = opts or {}
  local enable = opts.enable or false
  if not enable then return end

  vim.api.nvim_set_hl(0, "FTPreviewFirst", { link = "Normal", })
  vim.api.nvim_set_hl(0, "FTPreviewSecond", { link = "DiagnosticWarn", })
  vim.api.nvim_set_hl(0, "FTPreviewThird", { link = "DiagnosticError", })
  vim.api.nvim_set_hl(0, "FTPreviewDimmed", { link = "Comment", })


  vim.keymap.set({ "n", "v", "o", }, "f", function() return on_key { key = "f", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "F", function() return on_key { key = "F", forward = false, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "t", function() return on_key { key = "t", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "T", function() return on_key { key = "T", forward = false, } end, { expr = true, })
end

return M
