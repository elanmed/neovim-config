local h = require "helpers"
local grug = require "grug-far"

local default_instance = "default_instance"

vim.keymap.set("n", "<leader>r", function()
  if grug.has_instance(default_instance) then
    grug.get_instance(default_instance):open { startInInsertMode = false, }
  else
    grug.open { startInInsertMode = false, instanceName = default_instance, }
  end
  vim.cmd "wincmd ="
  h.notify.doing "Common flags: --case-sensitive (default), --ignore-case, --word-regexp"
end, { desc = "Open the grug-far ui", })

grug.setup {
  keymaps = {
    qflist = { n = "<leader>f", },
    close = { n = "<leader>q", },
    refresh = { n = "<leader>e", },
    engine = { n = "<leader>g", },
  },
}
