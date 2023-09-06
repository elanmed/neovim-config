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

h.nmap("<leader>gd", function()
  vim.cmd("NvimTreeClose")
  vim.cmd("DiffviewOpen")
end)
h.nmap("<leader>gq", h.user_cmd_cb("DiffviewClose"))
h.nmap("<leader>gi", h.user_cmd_cb("DiffviewFileHistory %"))
h.nmap("T", h.user_cmd_cb("tabnext"))
