local h = require "helpers"
local flash = require "flash"
local marks = require "marks"

local function get_bottom_half_start_line()
  local height = vim.api.nvim_win_get_height(0)
  local bottom_half_start_line = vim.fn.line "$" - math.floor(height / 2)
  return bottom_half_start_line
end

local scroll_duration = 175
local neoscroll = require "neoscroll"
neoscroll.setup { mappings = {}, post_hook = function()
  local bottom_half_start_line = get_bottom_half_start_line()
  if vim.fn.line "." == bottom_half_start_line then
    vim.opt.scrolloff = 999
  end
end, }

vim.opt.scrolloff = 999
vim.api.nvim_create_autocmd({ "CursorMoved", }, {
  callback = function()
    local zero_scrolloff_filetypes = { "snacks_picker_list", }
    if vim.tbl_contains(zero_scrolloff_filetypes, vim.bo.filetype) then
      vim.opt.scrolloff = 0
    end

    local bottom_half_start_line = get_bottom_half_start_line()

    if vim.fn.line "." > bottom_half_start_line then
      vim.opt.scrolloff = 0
    elseif vim.fn.line "." < bottom_half_start_line then
      vim.opt.scrolloff = 999
    elseif vim.fn.line "." == bottom_half_start_line then
      neoscroll.zz { half_win_duration = scroll_duration, }
      -- vim.opt.scrolloff set in post_hook
    end
  end,
})

require "ft-highlight".setup()
-- require "nvim-surround".setup {
--   keymaps = {
--     normal = "ys",
--     visual = "S",
--     delete = "ds",
--     change = "cs",
--   },
-- }

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

-- flash.setup {
--   modes = {
--     char = {
--       enabled = false,
--     },
--   },
--   prompt = {
--     prefix = { { "󱐋 ", "FlashPromptIcon", }, },
--   },
-- }

local mini_jump2d = require "mini.jump2d"
mini_jump2d.setup()

vim.keymap.set("n", "s", function()
  mini_jump2d.start {
    spotter = mini_jump2d.gen_spotter.vimpattern "\\k\\+",
    allowed_lines = { cursor_before = false, cursor_after = true, },
    allowed_windows = { not_current = false, },
  }
end)
vim.keymap.set("n", "S", function()
  mini_jump2d.start {
    spotter = mini_jump2d.gen_spotter.vimpattern "\\k\\+",
    allowed_lines = { cursor_before = true, cursor_after = false, },
    allowed_windows = { not_current = false, },
  }
end)
vim.keymap.set("n", "<leader>s", function() mini_jump2d.start(mini_jump2d.builtin_opts.line_start) end)

vim.keymap.set("n", "<leader>v", function() flash.treesitter() end)
-- vim.keymap.set("n", "s", function() flash.jump { forward = true, } end)
-- vim.keymap.set("n", "S", function() flash.jump { forward = false, } end)
-- vim.keymap.set("n", "<leader>s", function()
--   -- https://github.com/folke/flash.nvim#-examples
--   flash.jump {
--     forward = true,
--     search = {
--       mode = "search",
--       max_length = 0,
--     },
--     label = {
--       after = { 0, 0, },
--     },
--     pattern = "^",
--   }
-- end)

marks.setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "<leader>mt",
    next = "]a",
    prev = "[a",
    delete_buf = "<leader>md",
  },
}
