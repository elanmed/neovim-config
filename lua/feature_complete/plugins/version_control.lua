-- local gitsigns = require "gitsigns"
-- gitsigns.setup {
--   current_line_blame_opts = {
--     virt_text_pos = "right_align",
--   },
--   preview_config = {
--     border = "rounded",
--   },
--   on_attach = function()
--     vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview the current hunk", })
--
--     -- https://github.com/lewis6991/gitsigns.nvim#-keymaps
--     vim.keymap.set("n", "]g", function()
--       if vim.wo.diff then
--         vim.cmd.normal { "]c", bang = true, }
--       else
--         gitsigns.nav_hunk "next"
--       end
--     end, { desc = "Go to the next git hunk", })
--
--     vim.keymap.set("n", "[g", function()
--       if vim.wo.diff then
--         vim.cmd.normal { "[c", bang = true, }
--       else
--         gitsigns.nav_hunk "prev"
--       end
--     end, { desc = "Go to the prev git hunk", })
--
--     vim.keymap.set("n", "<leader>gr", function()
--       gitsigns.reset_hunk()
--       vim.cmd "w"
--     end, { desc = "Reset the current hunk", })
--
--     vim.keymap.set("v", "<leader>gr", function()
--       gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v", }
--       vim.cmd "w"
--     end, { desc = "Reset the current hunk", })
--   end,
-- }

local mini_diff = require "mini.diff"
mini_diff.setup {
  mappings = {
    apply = "",
    reset = "gh",
    goto_first = "",
    goto_prev = "[g",
    goto_next = "]g",
    goto_last = "",
  },
}

vim.keymap.set("n", "<C-b>", mini_diff.toggle_overlay, { desc = "Toggle mini diff overlay", })
