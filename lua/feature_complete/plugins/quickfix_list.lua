local h = require "shared.helpers"
local bqf = require "bqf"

bqf.setup {
  auto_resize_height = true,
  func_map = {
    openc = "<cr>",
    open = "o",
  },
  preview = {
    winblend = 0,
  },
}

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.table_contains_value({ "qf", "aerial", }, vim.bo.filetype) then
      h.set.cursorline = true
      vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual", })
    else
      h.set.cursorline = false
    end
  end,
})
