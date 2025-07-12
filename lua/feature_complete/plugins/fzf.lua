local h = require "helpers"
local grug = require "grug-far"
local fzf_lua = require "fzf-lua"
local Job = require "plenary.job"

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
}

local with_preview_opts = {
  winopts = {
    height = 1,
    preview = {
      layout = "vertical",
      vertical = "up:35%",
    },
  },
}
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

local function fre_and_all_files(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()

  local contents = function(fzf_cb)
    local seen = {}

    --- @param on_exit function
    local function run_fre(on_exit)
      Job:new {
        command = "fre",
        args = { "--sorted", },
        on_stdout = function(err, abs_file)
          if err then return vim.notify(err, vim.log.levels.ERROR) end
          -- `fre` can have files from any directory
          if not vim.startswith(abs_file, cwd) then return end
          -- `fre` can have duplicates, need to check `seen`
          if seen[abs_file] then return end
          seen[abs_file] = true

          local rel_file = vim.fs.relpath(cwd, abs_file)
          local entry = fzf_lua.make_entry.file(rel_file, opts)
          fzf_cb(entry)
        end,
        on_exit = on_exit,
      }:start()
    end

    local function run_fd()
      local ignore_dirs = { "node_modules", ".git", "dist", "nvm", }
      local fd_args = { "--hidden", "--absolute-path", "--type", "f", "--base-directory", cwd, }
      for _, ignore_dir in ipairs(ignore_dirs) do
        table.insert(fd_args, "--exclude")
        table.insert(fd_args, ignore_dir)
      end

      Job:new {
        command = "fd",
        args = fd_args,
        on_stdout = function(err, abs_file)
          if err then return vim.notify(err, vim.log.levels.ERROR) end
          -- `fd` only searches in the cwd, no need to filter out
          -- `fd` has no duplicates, no need to add to `seen`
          if seen[abs_file] then return end

          local rel_file = vim.fs.relpath(cwd, abs_file)
          local entry = fzf_lua.make_entry.file(rel_file, opts)
          fzf_cb(entry)
        end,
        on_exit = function()
          fzf_cb(nil)
        end,
      }:start()
    end

    run_fre(run_fd)
  end

  local wrapped_enter = function(action)
    return function(selected, action_opts)
      for _, sel in ipairs(selected) do
        local file = fzf_lua.path.entry_to_file(sel, action_opts, action_opts._uri)
        vim.system { "fre", "--add", file.path, }
      end

      return action(selected, action_opts)
    end
  end

  local actions = vim.tbl_extend("force", fzf_lua.defaults.actions.files, {
    enter = wrapped_enter(fzf_lua.defaults.actions.files.enter),
  })
  local default_opts = { actions = actions, }
  local fzf_exec_opts = vim.tbl_extend("force", default_opts, opts)
  fzf_lua.fzf_exec(contents, fzf_exec_opts)
end

vim.keymap.set("n", "<leader>lr", fzf_lua.resume, { desc = "Resume fzf-lua search", })
vim.keymap.set("n", "<leader>h", with_preview_cb(fzf_lua.helptags), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>m", with_preview_cb(fzf_lua.marks), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<c-p>", function()
  local opts = vim.tbl_extend("error", without_preview_opts,
    { file_icons = true, color_icons = true, })
  fre_and_all_files(opts)
end, { desc = "Search files with fzf", })
vim.keymap.set("n", "<leader>l;", without_preview_cb(fzf_lua.command_history),
  { desc = "Search command history with fzf", })
vim.keymap.set("n", "<leader>i", function()
    local opts = vim.tbl_extend("error", without_preview_opts, {
      actions = { ["right"] = false, ["left"] = false, ["ctrl-x"] = false, },
    })
    fzf_lua.git_status(opts)
  end,
  { desc = "Search git status with fzf", })
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
