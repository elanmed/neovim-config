local h = require "shared.helpers"

h.let.netrw_banner = 0 -- removes banner at the top

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "netrw",
  callback = function()
    h.nmap("-", "-^") -- go up a directory
  end
})

h.nmap("L", h.user_cmd_cb("bnext"), { desc = "Next buffer" })
h.nmap("H", h.user_cmd_cb("bprev"), { desc = "Previous buffer" })
h.nmap("<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd("Rex")
  else
    vim.cmd("Explore %:p:h")
  end
end, { desc = "Toggle netrw, focusing the current file" })
