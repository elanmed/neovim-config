local h = require "shared.helpers"

-- buffers
h.nmap("L", h.user_cmd_cb("bnext"))
h.nmap("H", h.user_cmd_cb("bprev"))
h.nmap("<leader>tw", h.user_cmd_cb("bdelete"))
h.nmap("<leader>ta", function()
  vim.cmd("bufdo")
  vim.cmd("bdelete")
end)

-- netrw
h.nmap("<leader>re", h.user_cmd_cb("Lexplore")) -- toggle netrw
h.nmap("<leader>rw", h.user_cmd_cb("Lexplore")) -- toggle netrw
