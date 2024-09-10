local h = require "shared.helpers"

h.nmap("<C-f>", h.user_cmd_cb("Oil"), { desc = "Toggle oil" })
h.nmap("<leader>ne", h.user_cmd_cb("NERDTreeFind"), { desc = "Open NERDTree" })

vim.api.nvim_set_var('NERDTreeWinSize', 100)
return {
  {
    "kyazdani42/nvim-web-devicons",
    commit = "3722e3d"
  },
  {
    "preservim/nerdtree",
    commit = "9b465ac"
  },
  {
    "stevearc/oil.nvim",
    commit = "30e0438",
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true
      },
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<cr>"] = "actions.select",
        ["<C-f>"] = "actions.close",
        ["-"] = "actions.parent",
        ["g."] = "actions.toggle_hidden",
      },
    },
  }
}
