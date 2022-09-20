package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end

-- TODO: is a pcall necessary here?
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local custom_actions = {}

local preview_opts = {
  preview_width = 0.3
}

function custom_actions.fzf_multi_select(prompt_bufnr)
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
    mappings = {
      n = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        ["<C-c>"] = actions.close
      },
      i = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        -- TODO: why isn't this working?
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
      }
    }
  },
  pickers = {
    live_grep = {
      theme = "ivy",
      layout_config = preview_opts
    },
    grep_string = {
      theme = "ivy",
      layout_config = preview_opts
    },
    resume = {
      theme = "ivy",
      layout_config = preview_opts
    },
    find_files = {
      theme = "ivy",
      previewer = false
    }
  },
  extensions = {
    frecency = {
      default_workspace = 'CWD',
      theme = "ivy"
    },
    neoclip = {
      theme = "ivy"
    }
  }
})
telescope.load_extension('fzf')
telescope.load_extension("frecency") -- loads results based on frequency
telescope.load_extension('neoclip')

-- TODO: figure out ivy theme in setup
-- h.nmap('<C-p>', [[<cmd>lua require('telescope').extensions.frecency.frecency(require('telescope.themes').get_ivy({}))<cr>]]) -- find files
h.nmap('<C-p>', [[<cmd>lua require('telescope.builtin').find_files()<cr>]]) -- find files
h.nmap("<leader>zf", [[<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<cr>]]) -- enter before grep
h.nmap("<leader>zu", [[<cmd>lua require('telescope.builtin').resume()<cr>]])

h.nmap("<leader>zo", [[<cmd>lua require('telescope.builtin').grep_string()<cr>]]) -- grep over current word
-- TODO: convert over to lua functions
h.vmap("<leader>zo", [["zy<cmd>exec 'Telescope grep_string search=' . escape(@z, ' ')<cr>]]) -- grep over selection
