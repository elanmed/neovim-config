local h = require "shared.helpers"
local neoscroll = require "neoscroll"

local function is_neoscroll_override_filetype()
  return h.tbl.contains_value({ "oil", }, vim.bo.filetype)
end

neoscroll.setup {
  mappings = { "<C-u>", "<C-d>", },
  hide_cursor = false,
  pre_hook = function()
    if is_neoscroll_override_filetype() then return end
    h.set.cursorline = true
  end,
  post_hook = function()
    if is_neoscroll_override_filetype() then return end
    h.set.cursorline = false
  end,
}
h.keys.map("n", "z.", function() neoscroll.zz { half_win_duration = 250, } end)

h.keys.map({ "n", "v", "i", }, "<C-u>", function()
  h.keys.send_keys("n", "0")
  if is_neoscroll_override_filetype() then
    neoscroll.ctrl_u { duration = 250, }
    return
  end

  if vim.fn.line "$" == vim.fn.line "." then
    h.keys.send_keys("n", "M")
  else
    neoscroll.ctrl_u { duration = 250, }
  end
end)

h.keys.map({ "n", "v", "i", }, "<C-d>", function()
  h.keys.send_keys("n", "0")
  if is_neoscroll_override_filetype() then
    neoscroll.ctrl_d { duration = 250, }
    return
  end

  if vim.fn.line "." == 1 then
    h.keys.send_keys("n", "M")
  else
    neoscroll.ctrl_d { duration = 250, }
  end
end)

local mini_map = require "mini.map"

mini_map.setup {
  symbols = {
    encode = mini_map.gen_encode_symbols.dot "4x2",
    scroll_line = "▶",
  },
}

-- opening/closing a split triggers WinEnter, not BufEnter
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.contains_value({ "oil", "fugitive", "markdown", "markdown.mdx", "qf", }, vim.bo.filetype) or h.screen.has_split() then
      mini_map.close()
    else
      mini_map.open()
    end
  end,
})

-- man doesn't fire the BufEnter event
vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "man",
  callback = function()
    mini_map.close()
  end,
})
