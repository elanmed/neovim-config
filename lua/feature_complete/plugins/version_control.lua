local h = require "shared.helpers"
local gitsigns = require "gitsigns"
gitsigns.setup {
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
}

-- gitsigns
-- https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file#keymaps
h.keys.map({ "n", }, ")", function()
  if vim.wo.diff then
    vim.cmd.normal { "]c", bang = true, }
  else
    gitsigns.nav_hunk "next"
  end
end, { desc = "Go to the next git hunk", })
h.keys.map({ "n", }, "(", function()
  if vim.wo.diff then
    vim.cmd.normal { "[c", bang = true, }
  else
    gitsigns.nav_hunk "prev"
  end
end, { desc = "Go to the prev git hunk", })

h.keys.map({ "n", }, "<leader>hr", function()
  gitsigns.reset_hunk()
  vim.cmd "w"
end, { desc = "Reset the Hunk", })

h.keys.map({ "v", }, "<leader>hr", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v", }
  vim.cmd "w"
end, { desc = "Reset the Hunk", })

h.keys.map({ "n", }, "<leader>hb", function()
  gitsigns.reset_buffer()
  vim.cmd "w"
end, { desc = "Reset the bUffer", })

h.keys.map({ "n", }, "<leader>hp", gitsigns.preview_hunk, { desc = "Preview the current hunk", })
h.keys.map({ "n", }, "<leader>hl", gitsigns.toggle_current_line_blame,
  { desc = "Toggle git blame for the current line", })
h.keys.map({ "n", }, "<leader>hf", gitsigns.blame, { desc = "Toggle git blame for the current file", })
h.keys.map({ "n", }, "<leader>hd", h.keys.user_cmd_cb "Gdiffsplit", { desc = "Open the Diff for the current file", })
h.keys.map({ "n", }, "<leader>hq", function()
  vim.cmd "wincmd h"
  vim.cmd "q"
end, { desc = "Close the diff for the current file", })

-- fugitive
h.keys.map({ "n", }, "<leader>gs", h.keys.user_cmd_cb "Gedit :",
  { desc = "Open the fugitive status in the current tab", })
h.keys.map({ "n", }, "<leader>gd", h.keys.user_cmd_cb "Git difftool -y",
  { desc = "Open the git diff in different tabs", })
h.keys.map({ "n", }, "<leader>gh", h.keys.user_cmd_cb "Git push origin HEAD", { desc = "Git pusH origin HEAD", })
vim.cmd [[nnoremap <leader>ge :Git checkout ]]    -- Git checkout (an Existing branch)
vim.cmd [[nnoremap <leader>gn :Git checkout -b ]] -- Git checkout -b (a New branch)
h.keys.map({ "n", }, "<leader>gq", function()
  h.keys.send_keys("n", "1gt")
  vim.cmd "tabonly"
end, { desc = "Close the git diff tabs", })

h.keys.map({ "n", }, "<leader>gl", function()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd "tabnew"
  vim.api.nvim_set_current_buf(current_buf)
  vim.cmd "Git log %"
  vim.cmd "wincmd o"
end, { desc = "Open the commits of the current buffer in a new tab", })
h.keys.map({ "n", }, "<leader>go", function()
    local current_buf = vim.api.nvim_get_current_buf()
    vim.cmd "Gclog -n 20 %"
    vim.cmd "cclose"
    vim.api.nvim_set_current_buf(current_buf)
    vim.cmd "vsplit"
    vim.cmd "cc"
  end,
  { desc = "open the cOmmits of the current buffer in the quickfix list", })

local function go_to_commit(qf_cmd)
  if h.screen.has_split() then
    vim.cmd "wincmd l"
    vim.cmd(qf_cmd)
  else
    vim.cmd "vsplit"
    vim.cmd "cc"
  end
end
h.keys.map({ "n", }, "W", function()
  go_to_commit "Cprev"
end)
h.keys.map({ "n", }, "Q", function()
  go_to_commit "Cnext"
end)

h.keys.map({ "n", }, "<leader>gp", function()
  vim.cmd "wincmd j"
  vim.cmd "wincmd l"
  h.keys.send_keys("n", "2G0w")
  local commit = vim.fn.expand "<cword>"
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd "tabnew"
  vim.api.nvim_set_current_buf(current_buf)
  vim.cmd("Gvdiffsplit " .. commit .. "^")
end, { desc = "create a new tab with a side-by-side sPlit", })
