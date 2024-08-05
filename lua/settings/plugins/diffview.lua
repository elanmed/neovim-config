local h = require "shared.helpers"
local diffview = require "diffview"
local actions = require "diffview.actions"

diffview.setup({
  file_panel = {
    win_config = {
      position = "bottom",
      height = 10,
    },
  },
  keymaps = {
    file_panel = {
      { "n", "j",       actions.next_entry },
      { "n", "k",       actions.prev_entry },
      { "n", "<cr>",    actions.goto_file_edit },
      { "n", "<tab>",   actions.select_next_entry },
      { "n", "<s-tab>", actions.select_prev_entry },
      { "n", "X",       actions.restore_entry },
    }
  }
})

h.nmap("<leader>gd", h.user_cmd_cb("DiffviewOpen"), { desc = "Open diffview" })
h.nmap("<leader>gq", h.user_cmd_cb("DiffviewClose"), { desc = "Close diffview" })
h.nmap("<leader>gi", h.user_cmd_cb("DiffviewFileHistory %"), { desc = "View the file's git history with diffview" })
h.nmap("<C-b>", h.user_cmd_cb("tabnext"), { desc = "Move to the next tab" })
