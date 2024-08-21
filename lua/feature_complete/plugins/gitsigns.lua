local h = require "shared.helpers"

local gitsigns = require "gitsigns"
gitsigns.setup({
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
})

h.nmap("<leader>gs", h.user_cmd_cb("tab Git"), { desc = "Git status" })
h.nmap("<leader>gd", h.user_cmd_cb("Git difftool -y"), { desc = "Open the git diff in different tabs" })
h.nmap("<leader>gh", h.user_cmd_cb("Git push origin HEAD"), { desc = "Git pusH origin HEAD" })
h.nmap("<leader>gl", h.user_cmd_cb("Git pull origin master"), { desc = "Git puLl origin master" })
h.nmap("<leader>ga", h.user_cmd_cb("Git add -A"), { desc = "Git Add -A" })
vim.cmd([[nnoremap <leader>ge :Git checkout ]])    -- Git checkout (an Existing branch)
vim.cmd([[nnoremap <leader>gn :Git checkout -b ]]) -- Git checkout -b (a New branch)

h.nmap("<leader>gq", function()
  h.send_keys("1gt");
  vim.cmd("tabonly")
end, { desc = "Close the git diff tabs" })
h.nmap(")", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    gitsigns.nav_hunk("next")
  end
end, { desc = "Go to the next git hunk" })

h.nmap("(", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    gitsigns.nav_hunk("prev")
  end
end, { desc = "Go to the prev git hunk" })

h.nmap("<leader>hr", function()
  gitsigns.reset_hunk()
  vim.cmd("w")
end, { desc = "Reset the Hunk" })
h.vmap("<leader>hr", function()
  gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line('v') })
  vim.cmd("w")
end, { desc = "Reset the Hunk" })
h.nmap("<leader>hb", function()
  gitsigns.reset_buffer()
  vim.cmd("w")
end, { desc = "Reset the bUffer" })
h.nmap("<leader>hp", gitsigns.preview_hunk, { desc = "Preview the current hunk" })
h.nmap("<leader>hl", gitsigns.toggle_current_line_blame, { desc = "Toggle git blame for the current line" })
h.nmap("<leader>hd", gitsigns.diffthis, { desc = "Diff the current file" })
