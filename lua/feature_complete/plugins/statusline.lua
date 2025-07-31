-- vim.g.scrollstatus_symbol_track = "-"
-- vim.g.scrollstatus_symbol_bar = ""

-- vim.opt.showmode = false -- disrupts lualine
-- require "lualine".setup {
--   options = {
--     component_separators = { left = "", right = "", },
--     section_separators = { left = "", right = "", },
--     globalstatus = true,
--   },
--   sections = {
--     lualine_a = { "mode", },
--     lualine_b = { "filename", },
--     lualine_c = { "lsp_status", },
--     lualine_x = { "ScrollStatus", "progress", },
--     lualine_y = { "branch", },
--     lualine_z = { "filetype", },
--   },
-- }

vim.opt.statusline = table.concat({
  " ", "%f", "%=",
  "%l:%c | ", "%p%%", " ",
}, "")
