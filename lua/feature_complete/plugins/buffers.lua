local h = require "shared.helpers"
local colors = require "feature_complete.plugins.colorscheme"
local bufferline = require "bufferline"
bufferline.setup {
  options = {
    diagnostics = "coc",
    style_preset = bufferline.style_preset.no_italic,
    right_mouse_command = nil,
    left_mouse_command = nil,
    indicator = {
      style = "underline",
    },
  },
}
vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.cyan, underline = true, })

h.keys.map({ "n", }, "<leader>tp", h.keys.user_cmd_cb "BufferLinePick", { desc = "Pick a buffer", })
h.keys.map({ "n", }, "<leader>ti", h.keys.user_cmd_cb "BufferLineTogglePin", { desc = "Pin a buffer", })
h.keys.map({ "n", }, "<leader>tl", h.keys.user_cmd_cb "BufferLineMoveNext", { desc = "Move a buffer to the left", })
h.keys.map({ "n", }, "<leader>th", h.keys.user_cmd_cb "BufferLineMovePrev", { desc = "Move a buffer to the right", })
h.keys.map({ "n", }, "L", h.keys.user_cmd_cb "BufferLineCycleNext", { desc = "Move to the buffer to the right", })
h.keys.map({ "n", }, "H", h.keys.user_cmd_cb "BufferLineCyclePrev", { desc = "Move to the buffer to the left", })
h.keys.map({ "n", }, "<leader>to", h.keys.user_cmd_cb "BufOnly", { desc = "Close all buffers, except the open one", })
