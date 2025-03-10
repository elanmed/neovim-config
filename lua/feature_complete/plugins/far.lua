local h = require "shared.helpers"
local grug = require "grug-far"

local GRUG_INSTANCE_NAME = ""

--- returns `true` to abort, `false` to kill instance
--- @return boolean
local function maybe_abort()
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    local user_input = vim.fn.input "A grug instance is already running. Okay to kill? (y/N) "
    if user_input ~= "y" then
      return true
    end
    grug.kill_instance(GRUG_INSTANCE_NAME)
  end
  return false
end

h.keys.map({ "n", }, "<leader>re", function()
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    grug.toggle_instance { instanceName = GRUG_INSTANCE_NAME, startInInsertMode = true, }
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
  group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true, }),
  pattern = "grug-far",
  callback = function()
    -- TODO: why doesn't h.keys.map with buffer = true set the keymap?
    vim.api.nvim_buf_set_keymap(h.curr.buffer, "n", "<leader>o", "<leader>ro<leader>q", {})
    vim.api.nvim_buf_set_keymap(h.curr.buffer, "i", "<C-e>", "<Esc><leader>q", {})
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
  if maybe_abort() then return end

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
    if maybe_abort() then return end

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
  if maybe_abort() then return end

  GRUG_INSTANCE_NAME = grug.open {
    prefills = {
      flags = "--ignore-case",
    },
  }
end, { desc = "Search globally with grug", })

h.keys.map({ "n", }, "<leader>lc", function()
    if maybe_abort() then return end

    GRUG_INSTANCE_NAME = grug.open()
  end,
  { desc = "Search globally (case-sensitive) with grug", })

h.keys.map({ "n", }, "<leader>lw", function()
    maybe_abort()
    GRUG_INSTANCE_NAME = grug.open {
      prefilles = {
        flags = "--ignore-case --word-regexp",
      },
    }
  end,
  { desc = "Search globally (whole-word) with grug", })

h.keys.map({ "n", }, "<leader>lb", function()
    if maybe_abort() then return end

    GRUG_INSTANCE_NAME = grug.open {
      prefills = {
        flags = "--word-regexp",
      },
    }
  end,
  { desc = "Search globally (case-sensitive and whole-word) with grug", })
