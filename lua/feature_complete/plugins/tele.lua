local h = require "shared.helpers"

local telescope = require "telescope"
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local grug = require "grug-far"

local custom_actions = {}

custom_actions.send_selected_and_open = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = h.tbl.size(picker:get_multi_selection())

  if num_selections > 1 then
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd "copen 15"
  else
    actions.select_default(prompt_bufnr)
  end
end

local border_borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└", }
local no_border_borderchars = { " ", }

-- custom_actions.send_selected_and_open_with_fzf = function(prompt_bufnr)
--   custom_actions.send_selected_and_open(prompt_bufnr)
--   require "bqf.filter.fzf".run()
--   h.keys.send_keys("n", "i")
-- end

telescope.load_extension "fzf"
telescope.load_extension "frecency"
telescope.load_extension "rails"

local shared_grep_string_options = { only_sort_text = true, }

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local stripped_start = filepath:match "wf_modules.*$"
  if not stripped_start then
    print "`wf_modules` not found in the filepath!"
    return nil
  end

  return stripped_start:match "(.-)%..-$"
end

local function grep_stripped_filename()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = stripped_filename, })
  builtin.grep_string(grep_string_options)
end

local function yank_stripped_filename()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  vim.fn.setreg("+", stripped_filename)
end

local ivy_layout_config = {
  height = 0.4,
  preview_width = 0,
}

-- h.keys.map({ "n", }, "<C-p>", h.keys.user_cmd_cb "Telescope frecency workspace=CWD", { desc = "Find files with telescope", })
h.keys.map({ "n", }, "<C-p>", function()
  telescope.extensions.frecency.frecency(
    themes.get_ivy {
      hidden = true,
      layout_config = ivy_layout_config,
      workspace = "CWD",
    }
  )
end, { desc = "Find files with telescope", })
h.keys.map({ "n", }, "<leader>li", function()
  builtin.search_history(themes.get_ivy {
    layout_config = ivy_layout_config,
  })
end, { desc = "Search search history with telescope", })
h.keys.map({ "n", }, "<leader>l;", function()
  builtin.command_history(themes.get_ivy {
    layout_config = ivy_layout_config,
  })
end, { desc = "Search command history with telescope", })
h.keys.map({ "n", }, "<leader>lr", builtin.resume, { desc = "Resume telescope search", })
h.keys.map({ "n", }, "<leader>lt", builtin.buffers, { desc = "Search currently open buffers with telescope", })
h.keys.map({ "n", }, "<leader>lh", builtin.help_tags, { desc = "Search help tags with telescope", })
h.keys.map({ "n", }, "<leader>lf", builtin.current_buffer_fuzzy_find,
  { desc = "Search in the current file with telescope", })
vim.cmd [[
nnoremap <leader>la :Telescope rails<space>
]]
h.keys.map({ "n", }, "<leader>le", grep_stripped_filename,
  { desc = "Search a file name starting with `wf_modules` with telescope", })
h.keys.map({ "n", }, "<leader>ke", yank_stripped_filename, { desc = "C(K)opy a file name starting with `wf_modules`", })
h.keys.map({ "n", }, "<leader>lp", function()
    builtin.planets {
      layout_strategy = "horizontal",
      border = true,
      borderchars = {
        prompt = no_border_borderchars,
        results = border_borderchars,
        preview = border_borderchars,
      },
    }
  end,
  { desc = "Search the planets with telescope", })

telescope.setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git", },
    results_title        = "",
    layout_strategy      = "vertical",
    sorting_strategy     = "ascending",
    border               = true,
    borderchars          = {
      prompt = no_border_borderchars,
      results = no_border_borderchars,
      preview = border_borderchars,
    },
    layout_config        = {
      vertical = {
        width = { padding = 0, },
        height = { padding = 0, },
        prompt_position = "bottom",
        preview_height = 0.35,
      },
    },
    mappings             = {
      i = {
        ["<cr>"] = custom_actions.send_selected_and_open,
        -- ["<C-f>"] = custom_actions.send_selected_and_open_with_fzf,
        -- ["<C-a>"] = actions.toggle_all,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.move_selection_previous + actions.toggle_selection,
        ["<C-t>"] = actions.toggle_selection,
        ["<esc>"] = actions.close,
      },
    },
  },
  extensions = {
    frecency = {
      db_safe_mode = false,
    },
  },
}
