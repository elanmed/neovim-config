local h = require "shared.helpers"
local mini_map = require "mini.map"

mini_map.setup({
  symbols = {
    encode = mini_map.gen_encode_symbols.dot("4x2"),
    scroll_line = "▶",
  }
})

-- TODO: find a better way to do this
local hide_mini = false

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    if h.table_contains({ "oil" }, vim.bo.filetype) or hide_mini then
      mini_map.close()
    else
      mini_map.open()
    end
  end
})

vim.api.nvim_create_autocmd({ "TabEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") > 2 then
      hide_mini = true
      mini_map.close()
    else
      hide_mini = false
      mini_map.open()
    end
  end
})

require("zen-mode").setup({
  window = {
    backdrop = 1,
    height = 0.5,
    options = {
      number = false,
      relativenumber = false,
    },
  },
  on_open = function()
    require("ibl").update({ enabled = false })
  end,
  on_close = function()
    require("ibl").update({ enabled = true })
  end,
})
h.nmap("<leader>zm", h.user_cmd_cb("ZenMode"), { desc = "Toggle zen mode" })
