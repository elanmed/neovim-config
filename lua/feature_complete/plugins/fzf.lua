local fzf_lua = require "fzf-lua"
local fzf_lua_frecency = require "fzf-lua-frecency"

local guicursor = vim.opt.guicursor:get()
-- :h cursor-blinking
table.insert(guicursor, "a:blinkon0")
vim.opt.guicursor = guicursor

fzf_lua.setup {
  winopts = {
    preview = {
      default = "bat_native",
      border = "rounded",
    },
    border = "none",
    width = 1,
  },
  fzf_opts = {
    ["--layout"] = "reverse-list",
    ["--cycle"] = true,
    ["--multi"] = true,
  },
  keymap = {
    builtin = { false, },
    fzf = {
      false,
      ["ctrl-a"] = "toggle-all",
      ["tab"] = "select+down",
      ["shift-tab"] = "up+deselect",
    },
  },
  marks = {
    marks = "%a",
  },
  fzf_colors = true,
  sort_lastused = true,
}

local without_preview_opts = { winopts = { height = 0.5, row = 1, preview = { hidden = true, }, }, }

vim.keymap.set("n", "<leader>f", function()
  local ignore_dirs = { "node_modules", ".git", "dist", }
  local fd_cmd = { "fd", "--absolute-path", "--hidden", "--type", "f", }
  for _, ignore_dir in pairs(ignore_dirs) do
    table.insert(fd_cmd, "--exclude")
    table.insert(fd_cmd, ignore_dir)
  end

  local opts = vim.tbl_deep_extend(
    "error",
    without_preview_opts,
    {
      fzf_opts = {
        ["--no-sort"] = false,
      },
      fzf_lua_frecency = {
        display_score = true,
        fd_cmd = table.concat(fd_cmd, " "),
      },
    })
  fzf_lua_frecency.frecency(opts)
end, { desc = "Search files with fzf", })
