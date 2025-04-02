local h = require "shared.helpers"
local grug = require "grug-far"

local telescope = require "telescope"
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local custom_actions = {}

custom_actions.send_selected_and_open = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = h.tbl.size(picker:get_multi_selection())

  if num_selections > 1 then
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd "copen"
  else
    actions.select_default(prompt_bufnr)
  end
end

local border_borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└", }
local no_border_borderchars = { " ", }
local shared_grep_string_options = { only_sort_text = true, }

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local stripped_start = filepath:match "wf_modules.*$"
  if not stripped_start then
    h.notify.error "`wf_modules` not found in the filepath!"
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

h.keys.map("n", "<C-p>", function()
  telescope.extensions.frecency.frecency(
    themes.get_ivy {
      hidden = true,
      layout_config = ivy_layout_config,
      workspace = "CWD",
    }
  )
end, { desc = "Find files with telescope", })
h.keys.map("n", "<leader>li", function()
  builtin.search_history(themes.get_ivy {
    layout_config = ivy_layout_config,
  })
end, { desc = "Search search history with telescope", })
h.keys.map("n", "<leader>l;", function()
  builtin.command_history(themes.get_ivy {
    layout_config = ivy_layout_config,
  })
end, { desc = "Search command history with telescope", })
h.keys.map("n", "<leader>lr", builtin.resume, { desc = "Resume telescope search", })
h.keys.map("n", "<leader>lt", builtin.buffers, { desc = "Search currently open buffers with telescope", })
h.keys.map("n", "<leader>lh", builtin.help_tags, { desc = "Search help tags with telescope", })
h.keys.map("n", "<leader>lf", builtin.current_buffer_fuzzy_find,
  { desc = "Search in the current file with telescope", })
h.keys.map("n", "<leader>le", grep_stripped_filename,
  { desc = "Search a file name starting with `wf_modules` with telescope", })
h.keys.map("n", "<leader>ke", yank_stripped_filename, { desc = "C(K)opy a file name starting with `wf_modules`", })
h.keys.map("n", "<leader>lp", function()
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
h.keys.map("n", "<leader>lg", function()
  -- fuzzy live grep, slow on large code bases
  builtin.grep_string { only_sort_text = true, search = "", prompt_title = "Live grep fuzzy", }
end)
h.keys.map("n", "<leader>la", telescope.extensions.live_grep_with_custom_args.live_grep_with_custom_args)
h.keys.map("n", "<leader>lo",
  function()
    telescope.extensions.live_grep_with_custom_args.live_grep_with_custom_args { default_text = "~" .. vim.fn.expand "<cword>" .. "~ ", }
  end)
h.keys.map({ "v", }, "<leader>lo",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    telescope.extensions.live_grep_with_custom_args.live_grep_with_custom_args { default_text = "'" .. visual_selection .. "' ", }
  end)


telescope.setup {
  extensions = {
    frecency = {
      db_safe_mode = false, -- disable prompt
    },
  },
  defaults = {
    file_ignore_patterns = { "node_modules", ".git", "dist", },
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
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.move_selection_previous + actions.toggle_selection,
        ["<C-t>"] = actions.toggle_selection,
        ["<C-a>"] = actions.toggle_all,
        ["<C-e>"] = actions.close,
      },
    },
  },
}

telescope.load_extension "fzf"
telescope.load_extension "frecency"
telescope.load_extension "live_grep_with_custom_args"
