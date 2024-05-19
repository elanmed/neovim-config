local h = require "shared.helpers"

local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local builtin = require "telescope.builtin"
local tree_api = require "nvim-tree.api"

local custom_actions = {}

custom_actions.fzf_multi_select = function(prompt_bufnr)
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
    actions.open_qflist()
  else
    actions.file_edit(prompt_bufnr)
    tree_api.tree.close()
  end
end

-- local function quickfix_shortcut_all(prompt_bufnr)
--   actions.send_to_qflist(prompt_bufnr)
--   vim.cmd('copen 25')
--   require('bqf.filter.fzf').run()
-- end
--
-- local function quickfix_shortcut_selected(prompt_bufnr)
--   custom_actions.fzf_multi_select(prompt_bufnr)
--   vim.cmd('copen 25')
--   require('bqf.filter.fzf').run()
-- end

local function send_to_qflist_and_open(prompt_bufnr)
  actions.send_to_qflist(prompt_bufnr)
  vim.cmd('copen 25')
end

telescope.setup({
  defaults = {
    layout_strategy = "vertical",
    layout_config   = {
      height = 0.95,
      width = 0.95,
      prompt_position = "bottom",
      preview_height = 0.4,
    },
    mappings        = {
      i = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        ["<c-f>"] = send_to_qflist_and_open,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_previous,
        ["<s-tab>"] = actions.move_selection_next + actions.toggle_selection,
        ["<esc>"] = actions.close,
        -- ["<c-d>"] = quickfix_shortcut_selected,
        -- ["<c-f>"] = quickfix_shortcut_all,
      }
    }
  },
})

telescope.load_extension("fzf")
telescope.load_extension("neoclip")
-- telescope.load_extension("rg_with_args")

local shared_grep_string_options = { only_sort_text = true }

local function grep_string_with_search()
  local term = vim.fn.input("Grep for > ")
  if term == "" then return end

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = term })
  builtin.grep_string(grep_string_options)
end

local function grep_string_with_visual()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))
  local visual = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
  local selected_text = visual[1] or ""

  local grep_string_options = vim.tbl_extend("error", shared_grep_string_options, { search = selected_text })
  builtin.grep_string(grep_string_options)
end

local function get_stripped_filename()
  local filepath = vim.fn.expand('%:p')

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

  vim.fn.setreg('+', stripped_filename)
end

h.nmap("<C-p>", builtin.find_files)
-- resUme
h.nmap("<leader>zu", builtin.resume)
-- fInd
h.nmap("<leader>zi", builtin.current_buffer_fuzzy_find)
-- gLobal
h.nmap("<leader>zl", grep_string_with_search)

-- Over
h.nmap("<leader>zo", function() builtin.grep_string(shared_grep_string_options) end)
h.vmap("<leader>zo", grep_string_with_visual)

h.nmap("<leader>if", yank_stripped_filename)
h.nmap("<leader>zf", grep_stripped_filename)
