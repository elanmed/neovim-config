local h = require "shared.helpers"

local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

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
  end
end

telescope.setup({
  defaults = {
    layout_strategy = "vertical",
    layout_config   = {
      height = 0.95,
      width = 0.925,
      prompt_position = "bottom",
      preview_height = 0.4,
    },
    mappings        = {
      i = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
        ["<c-f>"] = actions.send_to_qflist,
        ["<esc>"] = actions.close
      }
    }
  },
})

telescope.load_extension("fzf")
telescope.load_extension("neoclip")
telescope.load_extension("rg_with_args")

h.nmap("<C-p>", [[<cmd>lua require("telescope.builtin").find_files()<cr>]])
h.nmap("<leader>zu", [[<cmd>lua require("telescope.builtin").resume()<cr>]])
h.nmap("<leader>zf", [[<cmd>lua require("telescope").extensions.rg_with_args.rg_with_args()<CR>]])
h.nmap("<leader>zl", [[<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<cr>]])
