local h = require "shared.helpers"
local grug = require "grug-far"

GRUG_INSTANCE_NAME = ""

h.keys.map({ "n", }, "<leader>re", function()
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    grug.kill_instance(GRUG_INSTANCE_NAME)
  else
    GRUG_INSTANCE_NAME = grug.open()
  end
  vim.cmd "vertical resize 135%"
end, { desc = "Open the grug-far ui", })

grug.setup {
  keymaps = {
    replace = false,
    qflist = { n = "<leader>rq", },
    syncLocations = { n = "<leader>rs", },
    syncLine = { n = "<leader>rl", },
    close = { n = "<leader>q", },
    historyOpen = { n = "<leader>rh", },
    historyAdd = { n = "<leader>rd", },
    refresh = { n = "<leader>rr", },
    openLocation = { n = "<leader>ro", },
    openNextLocation = { n = "<C-j>", },
    openPrevLocation = { n = "<C-k>", },
    gotoLocation = { n = "<enter>", },
    pickHistoryEntry = { n = "<enter>", },
    abort = { n = "<leader>ra", },
    help = { n = "g?", },
    toggleShowCommand = { n = "<leader>rm", },
    swapEngine = false,
    previewLocation = { n = "<leader>rp", },
    swapReplacementInterpreter = false,
  },
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "grug-far",
  callback = function()
    h.keys.map({ "n", }, "<leader>o", "<leader>ro<leader>q", {
      buffer = true,
    })
  end,
})
