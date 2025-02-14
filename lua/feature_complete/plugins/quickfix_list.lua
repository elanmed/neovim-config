local h = require "shared.helpers"
-- local bqf = require "bqf"

-- bqf.setup {
--   auto_resize_height = true,
--   func_map = {
--     openc = "<cr>",
--     open = "o",
--   },
--   preview = {
--     winblend = 0,
--   },
-- }

local quicker = require "quicker"

quicker.setup {
  keys = {
    {
      ">",
      function()
        quicker.expand { before = 2, after = 2, add_to_existing = true, }
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        quicker.collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
}

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.table_contains_value({ "aerial", "undotree", }, vim.bo.filetype) then
      h.set.cursorline = true
    else
      h.set.cursorline = false
    end
  end,
})
