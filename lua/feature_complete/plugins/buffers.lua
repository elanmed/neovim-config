local h = require "shared.helpers"
local bufferline = require "bufferline"

bufferline.setup {
  options = {
    diagnostics = "nvim_lsp",
    style_preset = bufferline.style_preset.no_italic,
    custom_filter = function(buf_number)
      local buf_name = vim.fn.bufname(buf_number)
      if buf_name == "" then return false end

      local excluded_filetypes = { "grug-far", "fugitive", }
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf_number, })
      if h.tbl.contains_value(excluded_filetypes, filetype) then
        return false
      end

      return true
    end,
  },
}

h.keys.map("n", "<leader>up", h.keys.vim_cmd_cb "BufferLinePick", { desc = "Pick a buffer", })
h.keys.map("n", "<leader>ui", h.keys.vim_cmd_cb "BufferLineTogglePin", { desc = "Pin a buffer", })
h.keys.map("n", "<leader>ul", h.keys.vim_cmd_cb "BufferLineMoveNext", { desc = "Move a buffer to the left", })
h.keys.map("n", "<leader>uh", h.keys.vim_cmd_cb "BufferLineMovePrev", { desc = "Move a buffer to the right", })
h.keys.map("n", "L", h.keys.vim_cmd_cb "BufferLineCycleNext", { desc = "Move to the buffer to the right", })
h.keys.map("n", "H", h.keys.vim_cmd_cb "BufferLineCyclePrev", { desc = "Move to the buffer to the left", })
