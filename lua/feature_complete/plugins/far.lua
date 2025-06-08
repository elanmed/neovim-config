local h = require "shared.helpers"
local grug = require "grug-far"

local default_instance = "default_instance"

vim.keymap.set("n", "<leader>re", function()
  if grug.has_instance(default_instance) then
    grug.get_instance(default_instance):open { startInInsertMode = false, }
  else
    grug.open { startInInsertMode = false, instanceName = default_instance, }
  end
  vim.cmd "vertical resize 135%"
  h.notify.doing "Common flags: --case-sensitive (default), --ignore-case, --word-regexp"
end, { desc = "Open the grug-far ui", })

grug.setup {
  keymaps = {
    replace = false,
    qflist = { n = "<leader>rq", },
    syncLocations = { n = "<leader>rs", },
    syncLine = { n = "<leader>rl", },
    close = { n = "<leader>q", },
    historyOpen = { n = "<leader>rh", },
    historyAdd = false,
    refresh = { n = "<leader>e", },
    openLocation = { n = "<leader>ro", },
    openNextLocation = { n = "<C-j>", },
    openPrevLocation = { n = "<C-k>", },
    gotoLocation = { n = "<enter>", },
    pickHistoryEntry = { n = "<enter>", },
    abort = false,
    help = { n = "g?", },
    toggleShowCommand = false,
    swapEngine = false,
    previewLocation = { n = "<leader>rp", },
    swapReplacementInterpreter = false,
  },
}
