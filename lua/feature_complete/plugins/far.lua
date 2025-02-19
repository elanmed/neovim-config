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
    close = { n = "<leader>q", i = "<C-e>", },
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

-- TODO: add this in a PR
-- local flash_highlight = function(bufnr, lnum)
--   local ns = vim.api.nvim_buf_add_highlight(bufnr, 0, "Visual", lnum - 1, 0, -1)
--   local remove_highlight = function()
--     pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)
--   end
--   vim.defer_fn(remove_highlight, 300)
-- end

local files_filter_row = 4
local shared_grug_opts = {
  startInInsertMode = false,
  startCursorRow = files_filter_row,
}

h.keys.map({ "v", }, "<leader>lo", function()
  local require_visual_mode_active = true
  local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
  if visual_selection == "" then return end

  local opts = vim.tbl_extend("error", shared_grug_opts, {
    prefills = {
      flags = "--ignore-case",
    },
  })
  GRUG_INSTANCE_NAME = grug.with_visual_selection(opts)
end, { desc = "Search the current selection with grug", })

h.keys.map({ "n", }, "<leader>lo", function()
    local opts = vim.tbl_extend("error", shared_grug_opts, {
      prefills = {
        search = vim.fn.expand "<cword>",
        flags = "--ignore-case",
      },
    })
    GRUG_INSTANCE_NAME = grug.open(opts)
  end,
  { desc = "Search the currently hovered word with grug", })

h.keys.map({ "n", }, "<leader>lg", function()
  GRUG_INSTANCE_NAME = grug.open {
    prefills = {
      flags = "--ignore-case",
    },
  }
end, { desc = "Search globally with grug", })

h.keys.map({ "n", }, "<leader>lc", function()
    local search = vim.fn.input "Grep for (case-sensitive): "
    if search == "" then return end

    local opts = vim.tbl_extend("error", shared_grug_opts, {
      prefills = {
        search = search,
      },
    })
    GRUG_INSTANCE_NAME = grug.open(opts)
  end,
  { desc = "Search globally (case-sensitive) with grug", })

h.keys.map({ "n", }, "<leader>lw", function()
    local search = vim.fn.input "Grep for (whole-word): "
    if search == "" then return end

    local opts = vim.tbl_extend("error", shared_grug_opts, {
      prefills = {
        search = search,
        flags = "--ignore-case --word-regexp",
      },
    })
    GRUG_INSTANCE_NAME = grug.open(opts)
  end,
  { desc = "Search globally (whole-word) with grug", })

h.keys.map({ "n", }, "<leader>lb", function()
    local search = vim.fn.input "Grep for (case-sensitive and whole-word): "
    if search == "" then return end

    local opts = vim.tbl_extend("error", shared_grug_opts, {
      prefills = {
        search = search,
        flags = "--word-regexp",
      },
    })
    GRUG_INSTANCE_NAME = grug.open(opts)
  end,
  { desc = "Search globally (case-sensitive and whole-word) with grug", })
