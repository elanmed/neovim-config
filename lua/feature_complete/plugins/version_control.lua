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
