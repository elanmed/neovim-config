--- @class FzfOpts
--- @field source string
--- @field options? table
--- @field sink? fun(entry: string)
--- @field sinklist? fun(entry:string[])
--- @field height "full"|"half"

local tempname = vim.fn.tempname()

--- @param opts FzfOpts
local function fzf(opts)
  opts.options = opts.options or {}

  vim.fn.writefile({}, tempname)

  local editor_height = vim.o.lines - 1
  local border_height = 2

  local term_bufnr = vim.api.nvim_create_buf(false, false)
  local term_winnr = vim.api.nvim_open_win(term_bufnr, true, {
    relative = "editor",
    row = editor_height,
    col = 0,
    width = vim.o.columns,
    height = opts.height == "full"
        and editor_height - border_height
        or math.floor(editor_height / 2) - border_height,
    border = "rounded",
    title = "FZF term",
  })
  local cmd = ("%s | fzf %s > %s"):format(opts.source, table.concat(opts.options, " "), vim.fn.shellescape(tempname))
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      vim.api.nvim_win_close(term_winnr, true)
      local temp_content = vim.fn.readfile(tempname)
      if #temp_content == 0 then return end

      if opts.sink then
        opts.sink(temp_content[1])
      elseif opts.sinklist then
        opts.sink(temp_content)
      end
    end,
  })
  vim.cmd "startinsert"
end

local h = require "helpers"
local grug = require "grug-far"
local mini_files = require "mini.files"

-- local guicursor = vim.opt.guicursor:get()
-- -- :h cursor-blinking
-- table.insert(guicursor, "a:blinkon0")
-- vim.opt.guicursor = guicursor

local function extend(...)
  local result = {}
  for _, list in ipairs { ..., } do
    vim.list_extend(result, list)
  end
  return result
end

local function maybe_close_mini_files()
  if vim.bo.filetype == "minifiles" then
    mini_files.close()
  end
end

local default_opts = {
  "--cycle",
  [[--preview-window='up:40%']],
  [[--bind='ctrl-d:preview-page-down']],
  [[--bind='ctrl-u:preview-page-up']],
}

local multi_select_opts = {
  "--multi",
  [[--bind='ctrl-a:toggle-all']],
  [[--bind='tab:select+up']],
  [[--bind='shift-tab:down+deselect']],
}

local single_select_opts = {
  [[--bind='tab:down']],
  [[--bind='shift-tab:up']],
}

local qf_preview_opts = {
  [[--delimiter='|']],
  [[--preview='bat --style=numbers --color=always {1} --highlight-line {2}']],
  [[--preview-window='+{2}/3']],
}

--- @param script_name "get_marks"|"delete_mark"|"get_cmd_history"|"remove_frecency_file"|"get_qf_list"|"get_qf_stack"
local function get_fzf_script(script_name)
  local lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    ("/.dotfiles/neovim/.config/nvim/fzf_scripts/%s.lua"):format(script_name)
  )
  return table.concat({ "nvim", "--headless", "-l", lua_script, vim.v.servername, }, " ")
end

vim.keymap.set("n", "<leader>zm", function()
  maybe_close_mini_files()

  local source = get_fzf_script "get_marks"
  local delete_mark_source = get_fzf_script "delete_mark"

  local marks_opts_tbl = {
    [[--delimiter='|']],
    [[--bind]], ([['ctrl-x:execute(%s {1})+reload(%s)']]):format(delete_mark_source, source),
    [[--ghost='Marks']],
  }

  fzf {
    height = "half",
    source = source,
    options = extend(marks_opts_tbl, default_opts, single_select_opts),
    sink = function(entry)
      print(entry)
      local filename = vim.split(entry, "|")[2]
      vim.cmd("e " .. filename)
    end,
  }
end)

vim.keymap.set("n", "<leader>z;", function()
  maybe_close_mini_files()

  local source = get_fzf_script "get_cmd_history"
  local cmd_history_opts_tbl = {
    [[--ghost='Command history']],
  }
  fzf {
    source = source,
    options = extend(cmd_history_opts_tbl, default_opts, single_select_opts),
    height = "half",
    sink = function(selected)
      vim.api.nvim_feedkeys(":" .. selected, "n", false)
    end,
  }
end)

vim.keymap.set("n", "<leader>i", function()
  maybe_close_mini_files()

  local diff_opts_tbl = {
    [[--preview='git diff --color=always {} | tail -n +5']],
  }

  fzf {
    source = "git diff --name-only HEAD",
    options = extend(diff_opts_tbl, default_opts, single_select_opts),
    height = "full",
    sink = function(entry) vim.cmd("edit " .. entry) end,
  }
end)

local function sinklist(list)
  if vim.tbl_count(list) == 1 then
    local split_entry = vim.split(list[1], "|")
    local filename = split_entry[1]
    local row_one_index = tonumber(split_entry[2])
    local col_one_index = tonumber(split_entry[3])
    local col_zero_index = col_one_index - 1
    vim.cmd("e " .. filename)
    vim.api.nvim_win_set_cursor(0, { row_one_index, col_zero_index, })
    return
  end

  local qf_list = vim.tbl_map(function(entry)
    local filename, row, col, text = unpack(vim.split(entry, "|"))
    return { filename = filename, lnum = row, col = col, text = text, }
  end, list)
  vim.fn.setqflist(qf_list)
  vim.cmd "copen"
end

-- https://junegunn.github.io/fzf/tips/ripgrep-integration/
local function rg_with_globs(default_query)
  default_query = default_query or ""
  default_query = [[']] .. default_query .. [[']]

  local header =
  [['-e by *.[ext] | -f by file | -d by **/[dir]/** | -c by case sensitive | -nc by case insensitive | -w by whole word | -nw by partial word']]

  local rg_with_globs_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/rg-with-globs.sh"
  )
  local rg_options = {
    "--query", default_query,
    "--disabled",
    [[--ghost='Rg']],
    "--header", header,
    "--bind", ("'change:reload:%s {q} || true'"):format(rg_with_globs_script),
  }

  fzf {
    source = rg_with_globs_script,
    options = extend(rg_options, default_opts, multi_select_opts, qf_preview_opts),
    height = "full",
    sinklist = sinklist,
  }
end

vim.keymap.set("n", "<leader>a", function()
  maybe_close_mini_files()
  rg_with_globs ""
end)

vim.keymap.set("n", "<leader>zl", function()
  maybe_close_mini_files()
  require "fzf-lua-frecency".frecency {
    hidden = true,
    cwd_only = true,
  }
end)

vim.keymap.set("n", "<leader>zy", function()
  maybe_close_mini_files()

  local get_frecency_and_fd_files_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_frecency_and_fd_files.lua"
  )
  local sorted_files_path = require "fzf-lua-frecency.helpers".get_sorted_files_path()
  local source = table.concat({
    "nvim",
    "--headless",
    "-l",
    get_frecency_and_fd_files_script,
    sorted_files_path,
    vim.fn.getcwd(),
  }, " ")

  local remove_frecency_file_source = get_fzf_script "remove_frecency_file"
  local frecency_and_fd_opts = {
    [[--ghost='Frecency']],
    [[--delimiter='|']],
    "--bind", ([['ctrl-x:execute(%s {2})+reload(%s)']]):format(remove_frecency_file_source, source),
  }

  fzf {
    source = source,
    options = extend(frecency_and_fd_opts, default_opts, single_select_opts),
    height = "half",
    sink = function(entry)
      local filename = vim.split(entry, "|")[2]
      vim.cmd("e " .. filename)
    end,
  }
end)

vim.keymap.set("n", "<leader>zf", function()
  vim.cmd "cclose"
  local source = get_fzf_script "get_qf_list"
  local quickfix_list_opts = { [[--ghost='Qf list']], }
  fzf {
    source = source,
    options = extend(quickfix_list_opts, default_opts, multi_select_opts, qf_preview_opts),
    height = "full",
    sinklist = sinklist,
  }
end)

vim.keymap.set("n", "<leader>zs", function()
  vim.cmd "cclose"
  local source = get_fzf_script "get_qf_stack"
  local quickfix_list_opts = { [[--ghost='Qf stack']], }
  fzf {
    source = source,
    options = extend(quickfix_list_opts, default_opts, single_select_opts),
    height = "half",
    sink = function(entry)
      local qf_id = vim.split(entry, "|")[1]
      vim.cmd("chistory " .. qf_id)
      vim.cmd "copen"
    end,
  }
end)

vim.keymap.set("n", "<leader>zr", function()
  maybe_close_mini_files()

  local prev_rg_query_file = vim.fs.joinpath(
    os.getenv "HOME",
    ".dotfiles/neovim/.config/nvim/fzf_scripts/prev-rg-query.txt"
  )
  --- @type table
  local prev_rg_query = vim.fn.readfile(prev_rg_query_file)
  rg_with_globs(prev_rg_query[1])
end)

vim.keymap.set("v", "<leader>o", function()
  local require_visual_mode_active = true
  local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
  if visual_selection == "" then return end
  rg_with_globs(visual_selection .. " -- ")
end, { desc = "Grep the current word", })

vim.keymap.set("n", "<leader>o", function()
  rg_with_globs(vim.fn.expand "<cword>" .. " -- ")
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

vim.keymap.set("n", "<leader>zw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  rg_with_globs(stripped_filename .. " -- ")
end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  vim.fn.setreg("+", stripped_filename)
end, { desc = "Yank a file name starting with `wf_modules`", })
