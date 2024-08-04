local h = require "shared.helpers"
local colors = require "settings.plugins.base16"

local bufferline = require "bufferline"
bufferline.setup({
  options = {
    diagnostics = "coc",
    style_preset = bufferline.style_preset.no_italic,
    right_mouse_command = nil,
    left_mouse_command = nil,
    indicator = {
      style = "underline"
    },
  }
})

vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.cyan, underline = true })

h.nmap("<leader>tp", h.user_cmd_cb("BufferLinePick"), { desc = "Pick a buffer" })
h.nmap("<leader>ti", h.user_cmd_cb("BufferLineTogglePin"), { desc = "Pin a buffer" })
h.nmap("<leader>tl", h.user_cmd_cb("BufferLineMoveNext"), { desc = "Move a buffer to the left" })
h.nmap("<leader>th", h.user_cmd_cb("BufferLineMovePrev"), { desc = "Move a buffer to the right" })
h.nmap("I", h.user_cmd_cb("BufferLineCycleNext"), { desc = "Move to the buffer to the right" })
h.nmap("U", h.user_cmd_cb("BufferLineCyclePrev"), { desc = "Move to the buffer to the left" })
h.nmap("Y", h.user_cmd_cb("bdelete"), { desc = "Close the current buffer" })
h.nmap("<leader>tw", function() print "use Y instead!" end)
h.nmap("<leader>ta", h.user_cmd_cb("bufdo bdelete"), { desc = "Close all buffers" })
h.nmap("<leader>to", h.user_cmd_cb("BufOnly"), { desc = "Close all buffers, except the open one" })
