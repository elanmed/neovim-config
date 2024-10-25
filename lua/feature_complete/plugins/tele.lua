local h = require "shared.helpers"

local telescope = require "telescope"
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"
local action_state = require "telescope.actions.state"

local custom_actions = {}

custom_actions.send_all_and_open = function(prompt_bufnr)
  actions.send_to_qflist(prompt_bufnr)
  vim.cmd("copen 25")
end

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
    vim.cmd("copen 25")
    actions.open_qflist()
  else
    actions.select_default(prompt_bufnr)
  end
end

local border_borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
local no_border_borderchars = { " " }

-- custom_actions.send_all_and_open_with_fzf = function(prompt_bufnr)
--   custom_actions.send_all_and_open(prompt_bufnr)
--   require("bqf.filter.fzf").run()
-- end

-- custom_actions.send_selected_and_open_with_fzf = function(prompt_bufnr)
--   custom_actions.send_selected_and_open(prompt_bufnr)
--   require("bqf.filter.fzf").run()
-- end

telescope.load_extension "fzf"
telescope.load_extension "neoclip"
telescope.load_extension "coc"
-- telescope.load_extension "frecency"
-- telescope.load_extension("rg_with_args")

local shared_grep_string_options = { only_sort_text = true }

local function grep_string_with_search(opts)
  opts = opts or {}

  local base_input_text = "Grep for"
  local additional_args = {}
  local word_match
  local input_text

  if opts.case_sensitive and opts.whole_word then
    input_text = base_input_text .. " (case sensitive + whole word): "
    additional_args = { "-s" }
    word_match = "-w"
  elseif opts.case_sensitive then
    input_text = base_input_text .. " (case sensitive): "
    additional_args = { "-s" }
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
    { search = term, word_match = word_match, additional_args = additional_args })
  builtin.grep_string(grep_string_options)
end

local function grep_string_with_visual()
  local _, ls, cs = unpack(vim.fn.getpos("v"))
  local _, le, ce = unpack(vim.fn.getpos("."))
  local visual = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
  local selected_text = visual[1] or ""

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = selected_text })
  builtin.grep_string(grep_string_options)
end

local function get_stripped_filename()
  local filepath = vim.fn.expand("%:p")

  local stripped_start = filepath:match("wf_modules.*$")
  if not stripped_start then
    print("`wf_modules` not found in the filepath!")
    return nil
  end

  return stripped_start:match("(.-)%..-$")
end

local function grep_stripped_filename()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = stripped_filename })
  builtin.grep_string(grep_string_options)
end

local function yank_stripped_filename()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  vim.fn.setreg("+", stripped_filename)
end

-- h.nmap("<C-p>", h.user_cmd_cb("Telescope frecency workspace=CWD"), { desc = "Find files with telescope" })
h.nmap("<C-p>", builtin.find_files, { desc = "Find files with telescope" })
h.nmap("<leader>lr", builtin.resume, { desc = "Resume telescope search" })
h.nmap("<leader>lt", builtin.buffers, { desc = "Search currently open buffers with telescope" })
h.nmap("<leader>li", builtin.search_history, { desc = "Search search history with telescope" })
h.nmap("<leader>lh", builtin.help_tags, { desc = "Search help tags with telescope" })
h.nmap("<leader>l;", builtin.command_history, { desc = "Search command history with telescope" })
h.nmap("<leader>lf", builtin.current_buffer_fuzzy_find, { desc = "Search in the current file with telescope" })
h.nmap("<leader>ld", h.user_cmd_cb("Telescope coc diagnostics"), { desc = "Open diagnostics with telescope" })
h.nmap("<leader>lg", grep_string_with_search, { desc = "Search globally with telescope" })
h.nmap("<leader>lc", function() grep_string_with_search({ case_sensitive = true }) end,
  { desc = "Search globally (case-sensitive) with telescope" })
h.nmap("<leader>lw", function() grep_string_with_search({ whole_word = true }) end,
  { desc = "Search globally (whole-word) with telescope" })
h.nmap("<leader>lb", function() grep_string_with_search({ whole_word = true, case_sensitive = true }) end,
  { desc = "Search globally (case-sensitive and whole-word) with telescope" })
h.nmap("<leader>lo", function() builtin.grep_string(shared_grep_string_options) end,
  { desc = "Search the currently hovered word with telescope" })
h.vmap("<leader>lo", grep_string_with_visual, { desc = "Search the current selection with telescope" })
h.nmap("<leader>le", grep_stripped_filename,
  { desc = "Search a file name starting with `wf_modules` with telescope" })
h.nmap("<leader>ke", yank_stripped_filename, { desc = "C(K)opy a file name starting with `wf_modules`" })
h.nmap("<leader>lp", function()
    builtin.planets({
      layout_strategy = "horizontal",
      border = true,
      borderchars = {
        prompt = no_border_borderchars,
        results = border_borderchars,
        preview = border_borderchars,
      },
    })
  end,
  { desc = "Search the planets with telescope" })

vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "PmenuBorder" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopeFindPre",
  callback = function()
    h.set.showtabline = 0
    h.set.laststatus = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function()
    vim.api.nvim_create_autocmd("BufLeave", {
      callback = function()
        h.set.laststatus = 2
        h.set.showtabline = 2
      end,
    })
  end,
})

telescope.setup({
  pickers = {
    find_files = {
      preview_title = "",
    },
    buffers = {
      preview_title = "",
    },
    search_history = {
      preview_title = "",
    },
    help_tags = {
      preview_title = "",
    },
    command_history = {
      preview_title = "",
    },
    current_buffer_fuzzy_find = {
      preview_title = "",
    },
    grep_string = {
      preview_title = "",
    },
  },
  defaults = {
    results_title    = "",
    layout_strategy  = "vertical",
    sorting_strategy = "ascending",
    border           = true,
    borderchars      = {
      prompt = no_border_borderchars,
      results = no_border_borderchars,
      preview = border_borderchars,
    },
    layout_config    = {
      vertical = {
        width = { padding = 0 },
        height = { padding = 0 },
        prompt_position = "bottom",
        preview_height = 0.35,
      },
    },
    mappings         = {
      i = {
        ["<cr>"] = custom_actions.send_selected_and_open,
        ["<c-a>"] = actions.toggle_all,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.move_selection_previous + actions.toggle_selection,
        ["<c-t>"] = actions.toggle_selection,
        ["<esc>"] = actions.close,
      }
    }
  },
  extensions = {
    coc = {
      timeout = 3000, -- timeout for coc commands
    }
  },
})

require("neoclip").setup({
  history = 25,
  keys = {
    telescope = {
      i = {
        paste = "<f1>", -- unbind <C-p>, but this doesn't accept nil or ""
      },
    },
  },
})

h.nmap("<leader>ye", telescope.extensions.neoclip.default, { desc = "Open neoclip" })
h.nmap("<leader>yp", [[""p]], { desc = "Paste the last item selected from neoclip" })
