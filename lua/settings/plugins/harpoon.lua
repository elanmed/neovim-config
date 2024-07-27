local h = require "shared.helpers"
local border_helpers = require "settings.plugins.tele"
local harpoon = require "harpoon"
harpoon:setup()

h.nmap("<leader>aa", function() harpoon:list():add() end, { desc = "Add a file to harpoon" })
h.nmap("<leader>an", function() harpoon:list():next() end, { desc = "Go to the next harpoon item" })
h.nmap("<leader>ap", function() harpoon:list():prev() end, { desc = "Go to the previous harpoon item" })

-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2?tab=readme-ov-file#telescope
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers").new({}, {
    prompt_title  = "Harpoon",
    finder        = require("telescope.finders").new_table({
      results = file_paths,
    }),
    previewer     = conf.file_previewer({}),
    sorter        = conf.generic_sorter({}),
    layout_config = {
      width  = 120,
      height = 15,
    },
    border        = true,
    borderchars   = {
      prompt = border_helpers.no_border_borderchars,
      results = border_helpers.border_borderchars,
      preview = border_helpers.border_borderchars,
    },
  }):find()
end

h.nmap("<leader>at", function() toggle_telescope(harpoon:list()) end, { desc = "Toggle the harpoon menu" })
