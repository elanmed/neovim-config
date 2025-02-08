local h = require "shared.helpers"

local telescope = require "telescope"
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"
local action_state = require "telescope.actions.state"

local custom_actions = {}

custom_actions.send_selected_and_open = function(prompt_bufnr)
  local function get_table_size(t)
    local count = 0
    for _ in pairs(t) do
      count = count + 1
    end
    return count
  end

  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = get_table_size(picker:get_multi_selection())

  if num_selections > 1 then
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd "copen 15"
  else
    actions.select_default(prompt_bufnr)
  end
end

local border_borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└", }
local no_border_borderchars = { " ", }

custom_actions.send_selected_and_open_with_fzf = function(prompt_bufnr)
  custom_actions.send_selected_and_open(prompt_bufnr)
  require "bqf.filter.fzf".run()
  h.keys.send_keys("n", "i")
end

-- telescope.load_extension "fzf"
-- telescope.load_extension "coc"
-- telescope.load_extension "frecency"

local shared_grep_string_options = { only_sort_text = true, }

local function grep_string_with_search(opts)
  opts = opts or {}

  local base_input_text = "Grep for"
  local additional_args = { "--hidden", }
  local word_match
  local input_text

  if opts.case_sensitive and opts.whole_word then
    input_text = base_input_text .. " (case sensitive + whole word): "
    table.insert(additional_args, "-s")
    word_match = "-w"
  elseif opts.case_sensitive then
    input_text = base_input_text .. " (case sensitive): "
    table.insert(additional_args, "-s")
  elseif opts.whole_word then
    input_text = base_input_text .. " (whole word): "
    word_match = "-w"
  else
    input_text = base_input_text .. ": "
    word_match = nil
  end

  local term = vim.fn.input(input_text)
  if term == "" then return end

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options,
    { search = term, word_match = word_match, additional_args = additional_args, })
  builtin.grep_string(grep_string_options)
end

local function grep_string_with_visual()
  local _, line_start, col_start = table.unpack(vim.fn.getpos "v")
  local _, line_end, col_end = table.unpack(vim.fn.getpos ".")
  local visual = vim.api.nvim_buf_get_text(0, line_start - 1, col_start - 1, line_end - 1, col_end, {})
  local selected_text = visual[1] or ""

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = selected_text, })
  builtin.grep_string(grep_string_options)
end

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

-- h.keys.map({ "n", }, "<C-p>", h.keys.user_cmd_cb "Telescope frecency workspace=CWD", { desc = "Find files with telescope", })
h.keys.map({ "n", }, "<C-p>", function()
  builtin.find_files {
    hidden = true,
    border = true,
    borderchars = {
      prompt = no_border_borderchars,
      results = border_borderchars,
      preview = border_borderchars,
    },
    layout_config = {
      anchor = "N",
      -- anchor_padding = 0,
      vertical = {
        height = 0.7,
        width = 0.7,
        prompt_position = "top",
        preview_height = 0,
      },
    },
  }
end, { desc = "Find files with telescope", })
h.keys.map({ "n", }, "<leader>lr", builtin.resume, { desc = "Resume telescope search", })
h.keys.map({ "n", }, "<leader>lt", builtin.buffers, { desc = "Search currently open buffers with telescope", })
h.keys.map({ "n", }, "<leader>li", builtin.search_history, { desc = "Search search history with telescope", })
h.keys.map({ "n", }, "<leader>lh", builtin.help_tags, { desc = "Search help tags with telescope", })
h.keys.map({ "n", }, "<leader>l;", builtin.command_history, { desc = "Search command history with telescope", })
h.keys.map({ "n", }, "<leader>lf", builtin.current_buffer_fuzzy_find,
  { desc = "Search in the current file with telescope", })
h.keys.map({ "n", }, "<leader>lg", grep_string_with_search, { desc = "Search globally with telescope", })
h.keys.map({ "n", }, "<leader>lc", function() grep_string_with_search { case_sensitive = true, } end,
  { desc = "Search globally (case-sensitive) with telescope", })
h.keys.map({ "n", }, "<leader>lw", function() grep_string_with_search { whole_word = true, } end,
  { desc = "Search globally (whole-word) with telescope", })
h.keys.map({ "n", }, "<leader>lb", function() grep_string_with_search { whole_word = true, case_sensitive = true, } end,
  { desc = "Search globally (case-sensitive and whole-word) with telescope", })
h.keys.map({ "n", }, "<leader>lo", function() builtin.grep_string(shared_grep_string_options) end,
  { desc = "Search the currently hovered word with telescope", })
h.keys.map({ "v", }, "<leader>lo", grep_string_with_visual, { desc = "Search the current selection with telescope", })
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

-- vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal", })

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
        ["<C-f>"] = custom_actions.send_selected_and_open_with_fzf,
        ["<C-a>"] = actions.toggle_all,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.move_selection_previous + actions.toggle_selection,
        ["<C-t>"] = actions.toggle_selection,
        ["<esc>"] = actions.close,
      },
    },
  },
  -- extensions = {
  --   coc = {
  --     timeout = 3000, -- timeout for coc commands
  --   },
  -- },
}
