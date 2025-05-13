local h = require "shared.helpers"

local actions = require "diffview.actions"
local diffview = require "diffview"
diffview.setup {
  view = {
    default = {
      disable_diagnostics = true,
    },
    file_history = {
      disable_diagnostics = true,
    },
  },
  file_panel = {
    listing_style = "list",
    win_config = {
      position = "bottom",
      height = 10,
    },
  },
  keymaps = {
    disable_defaults = true,
    diff1 = {
      { "n", "g?", actions.help { "view", "diff1", }, { desc = "Open the help panel", }, },
    },
    diff2 = {
      { "n", "g?", actions.help { "view", "diff2", }, { desc = "Open the help panel", }, },
    },
    diff3 = {
      { "n", "<leader>go", actions.diffget "ours", { desc = "Use the diff hunk from the OURS version of the file", }, },
      { "n", "<leader>gt", actions.diffget "theirs", { desc = "Use the diff hunk from the THEIRS version of the file", }, },
      { "n", "g?", actions.help { "view", "diff3", }, { desc = "Open the help panel", }, },
    },
    file_panel = {
      { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side", }, },
      { "n", "<leader>go", actions.conflict_choose_all "ours", { desc = "Use the OURS version of a conflict for the whole file", }, },
      { "n", "<leader>gt", actions.conflict_choose_all "theirs", { desc = "Use the THEIRS version of a conflict for the whole file", }, },
      { "n", "<leader>ga", actions.conflict_choose_all "all", { desc = "Use all the versions of a conflict for the whole file", }, },
      { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry", }, },
      { "n", "o", actions.goto_file_edit, { desc = "Open the file in the previous tabpage", }, },
      { "n", "<leader>e", actions.refresh_files, { desc = "Refresh files", }, },

      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry", }, },
      { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file", }, },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file", }, },
      { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file", }, },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file", }, },
      { "n", "gg", actions.select_first_entry, { desc = "Open the diff for the next file", }, },
      { "n", "G", actions.select_last_entry, { desc = "Open the diff for the previous file", }, },
    },
    file_history_panel = {
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry", }, },
      { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file", }, },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file", }, },
      { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file", }, },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file", }, },
      { "n", "gg", actions.select_first_entry, { desc = "Open the diff for the next file", }, },
      { "n", "G", actions.select_last_entry, { desc = "Open the diff for the previous file", }, },
    },
  },
}

local gitsigns = require "gitsigns"
gitsigns.setup {
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
  preview_config = {
    border = "rounded",
  },
}

-- gitsigns
-- https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file#keymaps
vim.keymap.set("n", ")", function()
  if vim.wo.diff then
    vim.cmd.normal { "]c", bang = true, }
  else
    gitsigns.nav_hunk "next"
  end
end, { desc = "Go to the next git hunk", })
vim.keymap.set("n", "(", function()
  if vim.wo.diff then
    vim.cmd.normal { "[c", bang = true, }
  else
    gitsigns.nav_hunk "prev"
  end
end, { desc = "Go to the prev git hunk", })
vim.keymap.set("n", "<leader>ge", function()
  gitsigns.reset_hunk()
  vim.cmd "w"
end, { desc = "Reset the current hunk", })
vim.keymap.set("v", "<leader>ge", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v", }
  vim.cmd "w"
end, { desc = "Reset the current hunk", })
vim.keymap.set("n", "<leader>gu", function()
  gitsigns.reset_buffer()
  vim.cmd "w"
end, { desc = "Reset the current bUffer", })
vim.keymap.set("n", "<leader>gw", gitsigns.preview_hunk, { desc = "Preview the current hunk", })
vim.keymap.set("n", "<leader>gl", gitsigns.toggle_current_line_blame,
  { desc = "Toggle git blame for the current line", })

-- fugitive
vim.keymap.set("n", "<leader>gp", h.keys.vim_cmd_cb "Git push origin HEAD")
vim.keymap.set("n", "<leader>gi", function()
    local current_buf = vim.api.nvim_get_current_buf()
    vim.cmd "tabnew"
    vim.api.nvim_set_current_buf(current_buf)
    vim.cmd "Gdiffsplit"
  end,
  { desc = "Open the dIff for the current buffer", })
vim.keymap.set("n", "<leader>gs", h.keys.vim_cmd_cb "Gedit :",
  { desc = "Open the fugitive status in the current tab", })

-- diffview
vim.keymap.set("n", "<leader>gh", h.keys.vim_cmd_cb "DiffviewFileHistory %", { desc = "", })
vim.keymap.set("n", "<leader>gd", h.keys.vim_cmd_cb "DiffviewOpen", { desc = "Open the diff for all buffers", })
