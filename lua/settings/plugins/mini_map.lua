local mini_map = require('mini.map')

mini_map.setup({
  symbols = {
    encode = mini_map.gen_encode_symbols.dot('4x2'),
    scroll_line = '▶',
  }
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == 'oil' then
      print('in oil')
      require('mini.map').close()
    else
      print('NOT in oil')
      require('mini.map').open()
    end
  end
})
