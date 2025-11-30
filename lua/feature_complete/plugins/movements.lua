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

vim.keymap.set("n", "<leader>s", function() require "seek".seek() end)
