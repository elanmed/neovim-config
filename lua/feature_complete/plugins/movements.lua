local h = require "helpers"
local flash = require "flash"
local marks = require "marks"

local neoscroll = require "neoscroll"
neoscroll.setup { mappings = {}, }

require "ft-highlight".setup()
require "mini.surround".setup {
  mappings = {
    add = "ys",
    delete = "ds",
    replace = "cs",

    find = "",
    find_left = "",
    highlight = "",
    update_n_lines = "",
    suffix_last = "",
    suffix_next = "",
  },
}

local scroll_duration = 175

vim.keymap.set({ "n", "v", "i", }, "<C-u>", function()
  if vim.fn.line "." == vim.fn.line "$" then
    h.keys.send_keys("n", "M")
  else
    neoscroll.ctrl_u { duration = scroll_duration, }
  end
end)
vim.keymap.set({ "n", "v", "i", }, "<C-d>", function()
  if vim.fn.line "." == 1 then
    h.keys.send_keys("n", "M")
  else
    neoscroll.ctrl_d { duration = scroll_duration, }
  end
end)
vim.keymap.set("n", "z.", function()
  neoscroll.zz { half_win_duration = scroll_duration, }
end)

vim.opt.scrolloff = 999
vim.api.nvim_create_autocmd({ "CursorMoved", }, {
  callback = function()
    local height = vim.api.nvim_win_get_height(h.curr.window)
    local bot_half_height_ln = vim.fn.line "$" - math.floor(height / 2)

    if vim.fn.line "." > bot_half_height_ln then
      vim.opt.scrolloff = 0
    elseif vim.fn.line "." == bot_half_height_ln then
      neoscroll.zz { half_win_duration = scroll_duration, }
      -- TODO: ideally I would set to 999 after the scroll is finished
      vim.opt.scrolloff = 0
    else
      vim.opt.scrolloff = 999
    end
  end,
})

flash.setup {
  modes = {
    char = {
      enabled = false,
    },
  },
  prompt = {
    prefix = { { "󱐋 ", "FlashPromptIcon", }, },
  },
}

vim.keymap.set("n", "s", function() flash.jump { forward = true, } end)
vim.keymap.set("n", "S", function() flash.jump { forward = false, } end)
vim.keymap.set("n", "<leader>v", function() flash.treesitter() end)
vim.keymap.set("n", "<leader>s", function()
  -- https://github.com/folke/flash.nvim#-examples
  flash.jump {
    forward = true,
    search = {
      mode = "search",
      max_length = 0,
    },
    label = {
      after = { 0, 0, },
    },
    pattern = "^",
  }
end)

marks.setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "]a",
    prev = "[a",
    delete_line = "dml",
    delete_buf = "dmb",
  },
}
