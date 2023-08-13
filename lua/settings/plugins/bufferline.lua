local bufferline = require "bufferline"
bufferline.setup({
  options = {
    diagnostics = "coc",
    close_command = "Bdelete",
    right_mouse_command = nil,
    left_mouse_command = nil,
    middle_mouse_command = nil,
  }
})
