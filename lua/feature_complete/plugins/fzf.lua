local h = require "helpers"
local grug = require "grug-far"
local fzf_lua = require "fzf-lua"

local ignore_dirs = { "node_modules", ".git", "dist", }
local fd_cmd = "fd --type f"
for _, ignore_dir in pairs(ignore_dirs) do
  fd_cmd = fd_cmd .. " --exclude " .. ignore_dir
end

fzf_lua.setup {
  winopts = {
    preview = {
      default = "bat_native",
      border = "rounded",
    },
    border = "none",
    width = 1,
  },
  files = {
    git_icons = false,
    file_icons = false,
    cmd = fd_cmd,
  },
  fzf_opts = {
    ["--layout"] = "reverse-list",
    ["--cycle"] = true,
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
  actions = {
    files = {
      ["enter"] = fzf_lua.actions.file_edit_or_qf,
    },
  },
  marks = {
    marks = "%a",
  },
  fzf_colors = true,
}

local with_preview_opts = { winopts = { height = 1, preview = {
  layout = "vertical",
  vertical = "up:35%",
}, }, }
--- @param cb function
local function with_preview_cb(cb)
  return function() cb(with_preview_opts) end
end

local without_preview_opts = { winopts = { height = 0.5, row = 1, preview = { hidden = true, }, }, }
--- @param cb function
local function without_preview_cb(cb)
  return function()
    cb(without_preview_opts)
  end
end

local function git_status(arg_opts)
  local git_status_opts = {
    fn_transform = function(x)
      return require "fzf-lua".make_entry.file(x, { file_icons = true, color_icons = true, })
    end,
  }
  local opts = vim.tbl_extend("error", git_status_opts, arg_opts)

  -- https://github.com/ibhagwan/fzf-lua/blob/1e5933eef1a25d790b5f800b43d6eb841478247a/lua/fzf-lua/defaults.lua#L348-L349
  fzf_lua.fzf_exec("git -c color.status=false --no-optional-locks status --porcelain=v1", opts)
end

vim.keymap.set("n", "<leader>lr", fzf_lua.resume, { desc = "Resume fzf-lua search", })
vim.keymap.set("n", "<leader>h", with_preview_cb(fzf_lua.helptags), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>m", with_preview_cb(fzf_lua.marks), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<c-p>", function()
  local opts = vim.tbl_extend("error", without_preview_opts, { file_icons = true, })
  fzf_lua.files(opts)
end, { desc = "Search files with fzf", })
vim.keymap.set("n", "<leader>l;", without_preview_cb(fzf_lua.command_history),
  { desc = "Search search history with fzf", })
vim.keymap.set("n", "<leader>i", without_preview_cb(git_status),
  { desc = "Search git hunks with fzf", })
vim.keymap.set("n", "<leader>b", without_preview_cb(fzf_lua.buffers),
  { desc = "Search currently open buffers with fzf", })
vim.keymap.set("n", "<leader>lt", without_preview_cb(fzf_lua.tabs),
  { desc = "Search currently open tabs with fzf", })
vim.keymap.set("n", "<leader>lq", with_preview_cb(fzf_lua.quickfix),
  { desc = "Search the current qf list with fzf", })
vim.keymap.set("n", "<leader>lf", with_preview_cb(fzf_lua.quickfix_stack),
  { desc = "Search the qf lists with fzf", })

--- @param initial_query string
local function live_grep_with_args(initial_query)
  local opts = vim.tbl_deep_extend(
    "error",
    { previewer = "bat_native", query = initial_query, },
    with_preview_opts
  )

  require "rg-glob-builder".fzf_lua_adapter {
    fzf_lua_opts = opts,
    rg_glob_builder_opts = {
      nil_unless_trailing_space = true,
    },
  }
end

vim.keymap.set("n", "<leader>a", function() live_grep_with_args "~" end)
vim.keymap.set("v", "<leader>o",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    live_grep_with_args("~" .. visual_selection .. "~ ")
  end, { desc = "Grep the current word", })
vim.keymap.set("n", "<leader>o",
  function()
    live_grep_with_args("~" .. vim.fn.expand "<cword>" .. "~ ")
  end, { desc = "Grep the current visual selection", })

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local start_idx = filepath:find "wf_modules"
  if not start_idx then
    h.notify.warn "`wf_modules` not found in the filepath!"
    return nil
  end
  local stripped_start = filepath:sub(start_idx)
  local dot_idx = stripped_start:find "%." -- % escapes
  if dot_idx then
    stripped_start = stripped_start:sub(1, dot_idx - 1)
  end

  return stripped_start
end

vim.keymap.set("n", "<leader>le",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    live_grep_with_args("~" .. stripped_filename .. "~ ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>ye",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })
