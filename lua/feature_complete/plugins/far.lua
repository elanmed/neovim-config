local h = require "shared.helpers"
local grug = require "grug-far"

-- TODO: find a cleaner way to handle this
local GRUG_INSTANCE_NAME = ""

h.keys.map("n", "<leader>re", function()
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    grug.toggle_instance { instanceName = GRUG_INSTANCE_NAME, startInInsertMode = true, }
  else
    GRUG_INSTANCE_NAME = grug.open()
  end
  vim.cmd "vertical resize 135%"
  h.notify.info "Common flags: --case-sensitive (default), --ignore-case, --word-regexp"
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
  group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true, }),
  pattern = "grug-far",
  callback = function()
    -- TODO: why doesn't h.keys.map with buffer = true set the keymap?
    vim.api.nvim_buf_set_keymap(h.curr.buffer, "n", "<leader>o", "<leader>ro<leader>q", {})
    vim.api.nvim_buf_set_keymap(h.curr.buffer, "i", "<C-e>", "<Esc><leader>q", {})
  end,
})
