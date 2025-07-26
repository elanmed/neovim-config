local h = require "helpers"
local grug = require "grug-far"

local guicursor = vim.opt.guicursor:get()
-- :h cursor-blinking
table.insert(guicursor, "a:blinkon0")
vim.opt.guicursor = guicursor

local prev_rg_query_file = vim.fs.joinpath(
  os.getenv "HOME",
  ".dotfiles/neovim/.config/nvim/fzf_scripts/prev-rg-query.txt"
)
local remove_frecency_file_script = vim.fs.joinpath(
  os.getenv "HOME",
  "/.dotfiles/neovim/.config/nvim/fzf_scripts/remove-frecency-file.sh"
)
local rg_with_globs_script = vim.fs.joinpath(
  os.getenv "HOME",
  "/.dotfiles/neovim/.config/nvim/fzf_scripts/rg-with-globs.sh"
)
local frecency_and_fd_files_script = vim.fs.joinpath(
  os.getenv "HOME",
  "/.dotfiles/neovim/.config/nvim/fzf_scripts/frecency-and-fd-files.sh"
)

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
  "--style", "full",
  "--preview-window", "up:40%",
  "--bind", "ctrl-d:preview-page-down",
  "--bind", "ctrl-u:preview-page-up",
}

local multi_opts_tbl = {
  "--multi",
  "--bind", "ctrl-a:toggle-all",
  "--bind", "tab:select+down",
  "--bind", "shift-tab:up+deselect",
}

local single_opts_tbl = {
  "--bind", "tab:down",
  "--bind", "shift-tab:up",
}

local base_window_opts = {
  width = 1,
  relative = true,
  yoffset = 1,
  border = "none",
}
local without_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.5, })
local with_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 1, })

local function set_preview_window_opts(preview)
  vim.api.nvim_set_var("fzf_layout", { window = preview and with_preview_window_opts or without_preview_window_opts, })
end

vim.api.nvim_set_var("fzf_vim", {
  helptags_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  marks_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  buffers_options = fzf_opts(default_opts_tbl, single_opts_tbl),
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

vim.keymap.set("n", "<leader>z;", function()
  set_preview_window_opts(false)
  vim.fn["fzf#vim#command_history"] {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  }
  -- TODO: fzf_vim options entry
  -- vim.cmd "History:"
end)
vim.keymap.set("n", "<leader>i", function()
  set_preview_window_opts(true)
  vim.fn["fzf#vim#gitfiles"]("?", {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  })
  -- TODO: fzf_vim options entry
  -- vim.cmd "GFiles?"
end)

-- https://junegunn.github.io/fzf/tips/ripgrep-integration/
local function rg_with_globs(default_query)
  default_query = default_query or ""
  local header =
  "-e by *.[ext] :: -f by file :: -d by **/[dir]/** :: -c by case sensitive :: -nc by case insensitive :: -w by whole word :: -nw by partial word"

  local rg_options = {
    "--query", default_query,
    "--cycle",
    "--style", "full",
    "--disabled",
    "--ansi",
    "--prompt", "Rg> ",
    "--header", header,
    "--delimiter", "|",
    "--preview", "bat --style=numbers --color=always {1} --highlight-line {2}",
    "--preview-window", "+{2}+3/3",
    "--bind", ("start:reload:%s {q} || '|'"):format(rg_with_globs_script),
    "--bind", ("change:reload:%s {q} || '|'"):format(rg_with_globs_script),
  }

  local spec = {
    options = extend(rg_options, default_opts_tbl, multi_opts_tbl),
    window = with_preview_window_opts,
    sinklist = function(list)
      if #list == 1 then
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
        local split_entry = vim.split(entry, "|")
        local filename = split_entry[1]
        local row = split_entry[2]
        local col = split_entry[3]
        local text = split_entry[4]
        return { filename = filename, lnum = row, col = col, text = text, }
      end, list)
      vim.fn.setqflist(qf_list)
      vim.cmd "copen"
    end,
  }

  vim.fn["fzf#run"](vim.fn["fzf#wrap"]("", spec))
end

vim.keymap.set("n", "<leader>f", function()
  local sorted_files_path = require "fzf-lua-frecency.helpers".get_sorted_files_path()
  local source = table.concat({ frecency_and_fd_files_script, vim.fn.getcwd(), sorted_files_path, }, " ")

  local frecency_and_fd_opts = {
    "--prompt", "Frecency> ",
    "--delimiter", "|",
    "--preview", "bat --style=numbers --color=always {2}",
    "--bind", ("ctrl-x:execute(%s %s {2})+reload(%s)"):format(remove_frecency_file_script, vim.fn.getcwd(), source),
  }

  local spec = {
    source = source,
    options = extend(frecency_and_fd_opts, default_opts_tbl, single_opts_tbl),
    window = with_preview_window_opts,
    sink = function(entry)
      local filename = vim.split(entry, "|")[2]
      local abs_file = vim.fs.joinpath(vim.fn.getcwd(), filename)
      vim.schedule(function()
        require "fzf-lua-frecency.algo".update_file_score(abs_file, {
          update_type = "increase",
        })
      end)
      vim.cmd("e " .. filename)
    end,
  }

  vim.fn["fzf#run"](vim.fn["fzf#wrap"]("", spec))
end)

vim.keymap.set("n", "<leader>a", function() rg_with_globs "" end)
vim.keymap.set("n", "<leader>zr", function()
  local file = io.open(prev_rg_query_file, "r")
  if not file then return end
  local prev_rg_query = file:read "*a"
  prev_rg_query = prev_rg_query:gsub("\n$", "")
  file:close()
  rg_with_globs(prev_rg_query)
end)
vim.keymap.set("v", "<leader>o",
  function()
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

vim.keymap.set("n", "<leader>zw",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    rg_with_globs("~" .. stripped_filename .. "~ ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })
