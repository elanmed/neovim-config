local marks = require "marks"
vim.g.marks = {
  highlight_char_set = marks.char_sets.local_marks .. marks.char_sets.global_marks .. "<>^",
}

vim.keymap.set("n", "]a", function() marks.navigate_buffer_marks { direction = "next", } end)
vim.keymap.set("n", "[a", function() marks.navigate_buffer_marks { direction = "prev", } end)
vim.keymap.set("n", "]r", function() marks.navigate_global_marks { direction = "next", } end)
vim.keymap.set("n", "[r", function() marks.navigate_global_marks { direction = "prev", } end)
vim.keymap.set("n", "<leader>ml", marks.toggle_next_local_mark)
vim.keymap.set("n", "<leader>mg", marks.toggle_next_global_mark)
vim.keymap.set("n", "<leader>me", marks.refresh_signs)
vim.keymap.set("n", "<leader>md", marks.delete_buffer_marks)
vim.keymap.set("n", "<leader>mf", marks.global_marks_to_qf_list)

vim.keymap.set("n", "<leader>mt", function()
  local cursor_first = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_mark(0, "y", cursor_first[1], cursor_first[2], {})

  vim.cmd 'execute "normal \\<Plug>(MatchitNormalForward)"'

  local cursor_second = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_mark(0, "z", cursor_second[1], cursor_second[2], {})

  vim.cmd 'execute "normal \\<Plug>(MatchitNormalForward)"'

  require "marks".refresh_signs()
end)

vim.keymap.set("n", "<leader>s", function() require "seek".seek() end)
