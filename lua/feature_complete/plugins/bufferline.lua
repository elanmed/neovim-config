local h = require "shared.helpers"
local colors = require "feature_complete.colors.named_colors"

h.nmap("<leader>tp", h.user_cmd_cb("BufferLinePick"), { desc = "Pick a buffer" })
h.nmap("<leader>ti", h.user_cmd_cb("BufferLineTogglePin"), { desc = "Pin a buffer" })
h.nmap("<leader>tl", h.user_cmd_cb("BufferLineMoveNext"), { desc = "Move a buffer to the left" })
h.nmap("<leader>th", h.user_cmd_cb("BufferLineMovePrev"), { desc = "Move a buffer to the right" })
h.nmap("L", h.user_cmd_cb("BufferLineCycleNext"), { desc = "Move to the buffer to the right" })
h.nmap("H", h.user_cmd_cb("BufferLineCyclePrev"), { desc = "Move to the buffer to the left" })
h.nmap("<leader>to", h.user_cmd_cb("BufOnly"), { desc = "Close all buffers, except the open one" })

return {
  "akinsho/bufferline.nvim",
  commit = "0b2fd86",
  config = function()
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
  end,
  dependencies = {
    { "numtostr/BufOnly.nvim", cmd = "BufOnly", commit = "30579c2" },
  }
}
