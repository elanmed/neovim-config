local h = require "shared.helpers"
local grug = require "grug-far"
local snacks = require "snacks"

-- TODO: find a cleaner way to handle this
local GRUG_INSTANCE_NAME = ""

--- returns `true` to abort, `false` to kill instance
--- @param cb function
local function abort_or_cb(cb)
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    snacks.input.input(
      { prompt = "A grug instance is already running. Okay to kill? (y/N)", },
      function(user_input)
        if user_input == "y" then
          grug.kill_instance(GRUG_INSTANCE_NAME)
          cb()
        end
      end)
  else
    cb()
  end
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
  abort_or_cb(function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end

    local opts = vim.tbl_extend("error", shared_grug_opts, {
      prefills = {
        flags = "--ignore-case",
      },
    })
    GRUG_INSTANCE_NAME = grug.with_visual_selection(opts)
  end)
end, { desc = "Search the current selection with grug", })

h.keys.map({ "n", }, "<leader>lo", function()
    abort_or_cb(function()
      local opts = vim.tbl_extend("error", shared_grug_opts, {
        prefills = {
          search = vim.fn.expand "<cword>",
          flags = "--ignore-case",
        },
      })
      GRUG_INSTANCE_NAME = grug.open(opts)
    end)
  end,
  { desc = "Search the currently hovered word with grug", })

h.keys.map({ "n", }, "<leader>lg", function()
  abort_or_cb(function()
    GRUG_INSTANCE_NAME = grug.open {
      prefills = {
        flags = "--ignore-case",
      },
    }
  end)
end, { desc = "Search globally with grug", })

h.keys.map({ "n", }, "<leader>lc", function()
    abort_or_cb(function()
      GRUG_INSTANCE_NAME = grug.open()
    end)
  end,
  { desc = "Search globally (case-sensitive) with grug", })

h.keys.map({ "n", }, "<leader>lw", function()
    abort_or_cb(function()
      GRUG_INSTANCE_NAME = grug.open {
        prefilles = {
          flags = "--ignore-case --word-regexp",
        },
      }
    end)
  end,
  { desc = "Search globally (whole-word) with grug", })

h.keys.map({ "n", }, "<leader>lb", function()
    abort_or_cb(function()
      GRUG_INSTANCE_NAME = grug.open {
        prefills = {
          flags = "--word-regexp",
        },
      }
    end)
  end,
  { desc = "Search globally (case-sensitive and whole-word) with grug", })
