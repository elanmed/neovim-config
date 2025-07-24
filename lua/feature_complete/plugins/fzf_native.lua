local h = require "helpers"
local grug = require "grug-far"

local function extend(...)
  local result = {}
  for _, list in ipairs { ..., } do
    vim.list_extend(result, list)
  end
  return result
end

local function fzf_opts(...)
  return table.concat(extend(...), " ")
end

local default_opts_tbl = {
  "--cycle",
  "--style=full",
  "--preview-window=up:50%",
  "--bind=ctrl-d:preview-page-down",
  "--bind=ctrl-u:preview-page-up",
}

local preview_opts_tbl = {
  "--preview='~/.local/share/nvim/site/pack/paqs/start/fzf.vim/bin/preview.sh {}'",
}

local multi_opts_tbl = {
  "--multi",
  "--bind=ctrl-a:toggle-all",
  "--bind=tab:select+down",
  "--bind=shift-tab:up+deselect",
}

local single_opts_tbl = {
  "--bind=tab:down",
  "--bind=shift-tab:up",
}

local base_window_opts = {
  width = 1,
  relative = true,
  yoffset = 1,
  border = "none",
}
local without_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.5, })
local with_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.85, })

local function set_preview_window_opts(preview)
  vim.api.nvim_set_var("fzf_layout", { window = preview and with_preview_window_opts or without_preview_window_opts, })
end

vim.api.nvim_set_var("fzf_vim", {
  helptags_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  marks_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  buffers_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  files_options = fzf_opts(default_opts_tbl, multi_opts_tbl, { "--prompt='Files> '", }),
})

vim.keymap.set("n", "<leader>h", function()
  set_preview_window_opts(true)
  vim.cmd "Helptags"
end)
vim.keymap.set("n", "<leader>zm", function()
  set_preview_window_opts(false)
  vim.cmd "Marks"
end)
vim.keymap.set("n", "<leader>b", function()
  set_preview_window_opts(true)
  vim.cmd "Buffers"
end)
vim.keymap.set("n", "<leader>zf", function()
  set_preview_window_opts(true)
  vim.cmd "Files"
end)

vim.keymap.set("n", "<leader>z;", function()
  set_preview_window_opts(false)
  vim.fn["fzf#vim#command_history"] {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  }
  -- TODO: fzf_vim options entry
  -- vim.cmd "History:"
end)
vim.keymap.set("n", "<leader>zi", function()
  set_preview_window_opts(true)
  vim.fn["fzf#vim#gitfiles"]("?", {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  })
  -- TODO: fzf_vim options entry
  -- vim.cmd "GFiles?"
end)

-- https://junegunn.github.io/fzf/tips/ripgrep-integration/
local function live_grep_with_args(default_query)
  local script = os.getenv "HOME" .. "/.dotfiles/neovim/.config/nvim/rg-cmd.sh"

  default_query = default_query or ""
  local rg_options = {
    "--query", default_query,
    "--cycle",
    "--style=full",
    "--disabled",
    "--ansi",
    "--prompt", "Rg> ",
    "--header=-e by *.[ext] :: -f by file :: -d by **/[dir]/** :: -c by case sensitive :: -nc by case insensitive :: -w by whole word :: -nw by partial word",
    "--delimiter", ":",
    ("--bind=change:reload:%s {q} || true"):format(script),
    "--preview=bat --style=numbers --color=always --highlight-line {2} {1}",
  }

  local spec = {
    source = ":",
    options = extend(rg_options, default_opts_tbl, multi_opts_tbl),
    window = with_preview_window_opts,
  }

  vim.fn["fzf#run"](vim.fn["fzf#wrap"]("", spec))
end

vim.keymap.set("n", "<leader>a", function() live_grep_with_args "" end)
vim.keymap.set("v", "<leader>o",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    live_grep_with_args(visual_selection .. " -- ")
  end, { desc = "Grep the current word", })
vim.keymap.set("n", "<leader>o", function()
  live_grep_with_args(vim.fn.expand "<cword>" .. " -- ")
end, { desc = "Grep the current visual selection", })

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local start_idx = filepath:find "wf_modules"
  if not start_idx then
    h.notify.error "`wf_modules` not found in the filepath!"
    return nil
  end
  local stripped_start = filepath:sub(start_idx)
  local dot_idx = stripped_start:find "%." -- % escapes
  if dot_idx then
    stripped_start = stripped_start:sub(1, dot_idx - 1)
  end

  return stripped_start
end

vim.keymap.set("n", "<leader>lw",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    live_grep_with_args("~" .. stripped_filename .. "~ ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })
