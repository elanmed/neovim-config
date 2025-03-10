local h = require "shared.helpers"
local bufferline = require "bufferline"
bufferline.setup {
  options = {
    diagnostics = "nvim_lsp",
    style_preset = bufferline.style_preset.no_italic,
    right_mouse_command = nil,
    left_mouse_command = nil,
    indicator = {
      style = "underline",
    },
    custom_filter = function(buf_number)
      local buf_name = vim.fn.bufname(buf_number)

      if buf_name == "" then return false end

      local excluded_buf_names = { "Grug FAR", }
      for _, str in pairs(excluded_buf_names) do
        if string.find(buf_name, str) then
          return false
        end

        return true
      end
    end,
  },
}

h.keys.map({ "n", }, "<leader>tp", h.keys.user_cmd_cb "BufferLinePick", { desc = "Pick a buffer", })
h.keys.map({ "n", }, "<leader>ti", h.keys.user_cmd_cb "BufferLineTogglePin", { desc = "Pin a buffer", })
h.keys.map({ "n", }, "<leader>tl", h.keys.user_cmd_cb "BufferLineMoveNext", { desc = "Move a buffer to the left", })
h.keys.map({ "n", }, "<leader>th", h.keys.user_cmd_cb "BufferLineMovePrev", { desc = "Move a buffer to the right", })
h.keys.map({ "n", }, "L", h.keys.user_cmd_cb "BufferLineCycleNext", { desc = "Move to the buffer to the right", })
h.keys.map({ "n", }, "H", h.keys.user_cmd_cb "BufferLineCyclePrev", { desc = "Move to the buffer to the left", })
