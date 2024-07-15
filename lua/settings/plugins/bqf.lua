local h = require "shared.helpers"
local bqf = require "bqf"
local color_helpers = require "settings.plugins.bufferline"

bqf.setup({
  auto_resize_height = true,
  func_map = {
    openc = "<cr>",
  },
  preview = {
    winblend = 0
  }
})

-- TODO: figure out a way to clear only one list, not all
-- delete all quickfix lists
h.nmap("gc", h.user_cmd_cb("cex \"\""), { desc = "Clear all quickfix lists" })

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function(e)
    h.dump(e)
    if h.table_contains({ "qf", "DiffviewFiles" }, vim.bo.filetype) then
      h.set.cursorline = true
      vim.api.nvim_set_hl(0, "CursorLine",
        { fg = color_helpers.colors.base09, bg = color_helpers.colors.base02, underline = true })
    else
      h.set.cursorline = false
    end
  end
})
