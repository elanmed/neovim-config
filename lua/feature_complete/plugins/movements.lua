local h = require "shared.helpers"
local flash = require "flash"
local marks = require "marks"

local neoscroll = require "neoscroll"
neoscroll.setup { mappings = {}, }

require "ft-highlight".setup { enabled = true, }
require "nvim-surround".setup {
  keymaps = {
    normal = "ys",
    visual = "S",
    delete = "ds",
    change = "cs",
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
--- @param mark string
local function is_global_mark_unset(mark)
  local maybe_mark = vim.api.nvim_get_mark(mark, {})
  return maybe_mark[1] == 0 and maybe_mark[2] == 0 and maybe_mark[3] == 0 and maybe_mark[4] == ""
end

--- @param mark string
local function is_buffer_mark_unset(mark)
  local maybe_mark = vim.api.nvim_buf_get_mark(h.curr.buffer, mark)
  return maybe_mark[1] == 0 and maybe_mark[2] == 0
end

local global_marks = ("abcdefghijklmnopqrstuvwxyz"):upper()

-- TODO: better remaps
vim.keymap.set("n", "mg", function()
  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      h.notify.warn("Mark " .. letter .. " is already set for this buffer!")
      return
    end
  end

  local next_avail_mark = nil
  for letter in global_marks:gmatch "." do
    if is_global_mark_unset(letter) then
      next_avail_mark = letter
      break
    end
  end

  if next_avail_mark == nil then
    h.notify.error "No global marks available!"
    return
  end

  local line_one_indexed = 1
  local col_zero_indexed = 0
  vim.api.nvim_buf_set_mark(h.curr.buffer, next_avail_mark, line_one_indexed, col_zero_indexed, {})
  h.notify.doing("Set global mark " .. next_avail_mark)
end, { desc = "Set a global mark for the buffer", })

vim.keymap.set("n", "dmg", function()
  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      vim.api.nvim_del_mark(letter)
      h.notify.doing("Deleted global mark " .. letter)
      return
    end
  end
  h.notify.warn "No global mark in the buffer"
end, { desc = "Delete a global mark for the buffer", })
vim.keymap.set("n", "dmG", function()
  vim.cmd "delmarks A-Z"
  h.notify.doing "Deleted all global marks"
end, { desc = "Delete all global marks", })
vim.keymap.set("n", "dma", function()
  vim.cmd "delmarks a-zA-Z"
  h.notify.doing "Deleted all marks"
end, { desc = "Delete all marks", })
