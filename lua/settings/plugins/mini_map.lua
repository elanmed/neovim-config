local h = require "shared.helpers"
local mini_map = require "mini.map"

mini_map.setup({
  symbols = {
    encode = mini_map.gen_encode_symbols.dot("4x2"),
    scroll_line = "▶",
  }
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    if h.table_contains({ "oil" }, vim.bo.filetype) then
      require("mini.map").close()
    else
      require("mini.map").open()
    end
  end
})
