local h = require "shared.helpers"

h.nmap("zn", h.user_cmd_cb("AerialNext"), { desc = "Go to the next aerial symbol" })
h.nmap("zp", h.user_cmd_cb("AerialPrev"), { desc = "Go to the prev aerial symbol" })

return {
  "stevearc/aerial.nvim",
  commit = "92f93f4",
  opts = {
    lazy_load = false, -- let lazy handle the lazy loading
    show_guides = true,
    -- use automatic resizing
    layout = {
      resize_to_content = true,
      max_width = 0.4,
      width = nil,
      min_width = nil,
    },
    keymaps = {
      ["<C-g>"] = "actions.close",
    }
  },
  keys = {
    { "<C-g>", h.user_cmd_cb("AerialToggle left"), desc = "Toggle aerial  window" }
  },
  config = function()
    vim.api.nvim_set_hl(0, "AerialLine", { link = "Visual" })
  end

}
