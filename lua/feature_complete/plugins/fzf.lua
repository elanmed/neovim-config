local h = require "helpers"
local grug = require "grug-far"
local mini_files = require "mini.files"

local guicursor = vim.opt.guicursor:get()
-- :h cursor-blinking
table.insert(guicursor, "a:blinkon0")
vim.opt.guicursor = guicursor

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
  "--style", "full",
  "--preview-window", "up:40%",
  "--bind", "ctrl-d:preview-page-down",
  "--bind", "ctrl-u:preview-page-up",
}

local multi_select_opts = {
  "--multi",
  "--bind", "ctrl-a:toggle-all",
  "--bind", "tab:select+up",
  "--bind", "shift-tab:down+deselect",
}

local single_select_opts = {
  "--bind", "tab:down",
  "--bind", "shift-tab:up",
}

local qf_preview_opts = {
  "--delimiter", "|",
  "--preview", "bat --style=numbers --color=always {1} --highlight-line {2}",
  "--preview-window", "+{2}/3",
}

local base_window_opts = {
  width = 1,
  relative = true,
  yoffset = 1,
  border = "none",
}
local without_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.5, })
local with_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 1, })

vim.keymap.set("n", "<leader>b", function()
  local get_bufs_lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_bufs.lua"
  )
  local source = table.concat({ "nvim", "--headless", "-l", get_bufs_lua_script, vim.v.servername, }, " ")
  local buf_opts_tbl = {
    "--ghost", "Buffers",
  }

  local spec = {
    source = source,
    options = extend(buf_opts_tbl, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = "edit",
  }
  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>zm", function()
  maybe_close_mini_files()

  local get_marks_lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_marks.lua"
  )
  local source = table.concat({ "nvim", "--headless", "-l", get_marks_lua_script, vim.v.servername, }, " ")

  local delete_mark_lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/delete_mark.lua"
  )
  local delete_mark_source = table.concat({ "nvim", "--headless", "-l", delete_mark_lua_script, vim.v.servername, }, " ")

  local marks_opts_tbl = {
    "--delimiter", "|",
    "--bind", ("ctrl-x:execute(%s {1})+reload(%s)"):format(delete_mark_source, source),
    "--ghost", "Marks",
  }

  local spec = {
    source = source,
    options = extend(marks_opts_tbl, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = function(entry)
      local filename = vim.split(entry, "|")[2]
      vim.cmd("e " .. filename)
    end,
  }
  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>z;", function()
  maybe_close_mini_files()

  local source = {}

  for i = 1, math.min(vim.fn.histnr "cmd", 15) do
    local item = vim.fn.histget("cmd", i * -1)
    if item == "" then goto continue end
    table.insert(source, item)

    ::continue::
  end

  local cmd_history_opts_tbl = {
    "--ghost", "Command history",
  }

  local spec = {
    source = source,
    options = extend(cmd_history_opts_tbl, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = function(selected)
      vim.api.nvim_feedkeys(":" .. selected, "n", false)
    end,
  }

  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>i", function()
  maybe_close_mini_files()

  local diff_opts_tbl = {
    "--preview", "git diff --color=always {} | tail -n +5",
  }

  local spec = {
    source = "git diff --name-only HEAD",
    options = extend(diff_opts_tbl, default_opts, single_select_opts),
    window = with_preview_window_opts,
    sink = "edit",
  }
  vim.fn["fzf#run"](spec)
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
  local header =
  "-e by *.[ext] | -f by file | -d by **/[dir]/** | -c by case sensitive | -nc by case insensitive | -w by whole word | -nw by partial word"

  local rg_with_globs_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/rg-with-globs.sh"
  )
  local rg_options = {
    "--query", default_query,
    "--disabled",
    "--ghost", "Rg",
    "--header", header,
    "--bind", ("start:reload:%s {q} || true"):format(rg_with_globs_script),
    "--bind", ("change:reload:%s {q} || true"):format(rg_with_globs_script),
  }

  local spec = {
    options = extend(rg_options, default_opts, multi_select_opts, qf_preview_opts),
    window = with_preview_window_opts,
    sinklist = sinklist,
  }

  vim.fn["fzf#run"](spec)
end

vim.keymap.set("n", "<leader>ze", function()
  maybe_close_mini_files()
  require "fzf-lua-frecency".frecency {
    hidden = true,
    cwd_only = true,
  }
end)

vim.keymap.set("n", "<leader>zi", function()
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

  local remove_frecency_file_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/remove_frecency_file.lua"
  )
  local remove_frecency_file_source = table.concat({
    "nvim",
    "--headless",
    "-l",
    remove_frecency_file_script,
    vim.fn.getcwd(),
  }, " ")

  local frecency_and_fd_opts = {
    "--ghost", "Frecency",
    "--delimiter", "|",
    "--bind", ("ctrl-x:execute(%s {2})+reload(%s)"):format(remove_frecency_file_source, source),
  }

  local spec = {
    source = source,
    options = extend(frecency_and_fd_opts, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = function(entry)
      local filename = vim.split(entry, "|")[2]
      vim.cmd("e " .. filename)
    end,
  }

  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>zy", function()
  maybe_close_mini_files()

  local get_smart_files_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_smart_files.lua"
  )
  local source = table.concat({
    "nvim",
    "--headless",
    "--noplugin",
    "-l",
    get_smart_files_script,
    vim.v.servername,
  }, " ")

  local smart_fzy_opts = {
    "--ghost", "Smart fzy",
    "--ansi",
    "--delimiter", "|",
    "--disabled",
    "--bind", ("start:reload:%s {q}"):format(source),
    "--bind", ("change:reload:%s {q}"):format(source),
  }

  local spec = {
    source = source,
    options = extend(smart_fzy_opts, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = function(entry)
      local filename = vim.split(entry, "|")[2]
      vim.cmd("e " .. filename)
    end,
  }

  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>zf", function()
  vim.cmd "cclose"

  local get_qf_list_lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_qf_list.lua"
  )
  local source = table.concat({
      "nvim",
      "--headless",
      "-l",
      get_qf_list_lua_script,
      vim.v.servername,
    },
    " ")

  local quickfix_list_opts = {
    "--ghost", "Qf list",
  }

  local spec = {
    source = source,
    options = extend(quickfix_list_opts, default_opts, multi_select_opts, qf_preview_opts),
    window = with_preview_window_opts,
    sinklist = sinklist,
  }

  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>zs", function()
  vim.cmd "cclose"
  local get_qf_stack_lua_script = vim.fs.joinpath(
    os.getenv "HOME",
    "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_qf_stack.lua"
  )
  local source = table.concat({
      "nvim",
      "--headless",
      "-l",
      get_qf_stack_lua_script,
      vim.v.servername,
    },
    " ")

  local quickfix_list_opts = {
    "--ghost", "Qf stack",
  }

  local spec = {
    source = source,
    options = extend(quickfix_list_opts, default_opts, single_select_opts),
    window = without_preview_window_opts,
    sink = function(entry)
      local qf_id = vim.split(entry, "|")[1]
      vim.cmd("chistory " .. qf_id)
      vim.cmd "copen"
    end,
  }

  vim.fn["fzf#run"](spec)
end)

vim.keymap.set("n", "<leader>a", function()
  maybe_close_mini_files()
  rg_with_globs ""
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

    rg_with_globs(stripped_filename .. " -- ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })

-- ==========================================================================
-- Smart fuzzy finder
-- ==========================================================================

local tick = 0

local mini_icons = require "mini.icons"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local frecency_algo = require "fzf-lua-frecency.algo"
local frecency_fs = require "fzf-lua-frecency.fs"
local mini_fuzzy = require "mini.fuzzy"
local ns_id = vim.api.nvim_create_namespace "SmartHighlight"

local LOG = true
local ongoing_benchmarks = {}
--- @param type "start"|"end"
--- @param label string
local benchmark = function(type, label)
  if not LOG then return end

  if type == "start" then
    ongoing_benchmarks[label] = os.clock()
  else
    local end_time = os.clock()
    local start_time = ongoing_benchmarks[label]
    local elapsed_ms = (end_time - start_time) * 1000
    h.dev.log { string.format("%.3f : %s", elapsed_ms, label), }
  end
end

local fd_files = {}
local frecency_files = {}

local function populate_caches()
  benchmark("start", "fd")
  local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
  local fd_handle = io.popen(fd_cmd)
  if fd_handle then
    for file in fd_handle:lines() do
      table.insert(fd_files, file)
    end
    fd_handle:close()
  end
  benchmark("end", "fd")

  local cwd = vim.uv.cwd()
  local now = os.time()
  local sorted_files_path = frecency_helpers.get_sorted_files_path()
  local dated_files_path = frecency_helpers.get_dated_files_path()
  local dated_files = frecency_fs.read(dated_files_path)

  benchmark("start", "sorted_files_path fs read")
  for frecency_file in io.lines(sorted_files_path) do
    if vim.fn.filereadable(frecency_file) == 0 then goto continue end
    if not vim.startswith(frecency_file, cwd) then goto continue end

    local db_index = 1
    if not dated_files[db_index] then
      dated_files[db_index] = {}
    end
    local date_at_score_one = dated_files[db_index][frecency_file]
    local score = frecency_algo.compute_score { now = now, date_at_score_one = date_at_score_one, }

    frecency_files[frecency_file] = score

    ::continue::
  end
  benchmark("end", "sorted_files_path fs read")
end
populate_caches()

--- @class GetSmartFilesOpts
--- @field query string
--- @field results_buf number
--- @field curr_bufname string
--- @field alt_bufname string

--- @param opts GetSmartFilesOpts
--- @param callback function
local function get_smart_files(opts, callback)
  benchmark("start", "entire script")
  local curr_tick = tick
  local query = opts.query:gsub("%s+", "") -- mini fuzzy doesn't ignore spaces

  local OPEN_BUF_BOOST = 10
  local CHANGED_BUF_BOOST = 20
  local ALT_BUF_BOOST = 30
  local CURR_BUF_BOOST = -1000
  local MAX_FUZZY_SCORE = 10100
  local MAX_FRECENCY_SCORE = 99
  local BATCH_SIZE = 25

  local cwd = vim.fn.getcwd()

  --- @param abs_file string
  --- @param score number
  --- @param highlight_idxs table
  --- @param highlight_row number
  local function format_filename(abs_file, score, highlight_idxs, highlight_row)
    local icon_ok, icon_res = pcall(mini_icons.get, "file", abs_file)
    local icon = icon_ok and icon_res or "?"
    local rel_file = vim.fs.relpath(cwd, abs_file)
    local max_score_len = #frecency_helpers.exact_decimals(MAX_FRECENCY_SCORE, 2)

    local formatted_score = frecency_helpers.pad_str(
      frecency_helpers.fit_decimals(score or 0, max_score_len),
      max_score_len
    )

    local formatted = ("%s %s |%s"):format(formatted_score, icon, rel_file)
    local offset = #formatted_score + 1 + #icon + 1 + 1

    vim.schedule(function()
      for _, highlight_idx in ipairs(highlight_idxs) do
        local row_0_indexed = highlight_row - 1
        local highlight_col_0_indexed = highlight_idx + offset - 1

        vim.hl.range(
          opts.results_buf,
          ns_id,
          "SmartHighlightPos",
          { row_0_indexed, highlight_col_0_indexed, },
          { row_0_indexed, highlight_col_0_indexed + 1, }
        )
      end
    end)

    return formatted
  end

  benchmark("start", "open_buffers loop")
  local open_buffers = {}
  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_loaded(bufnr) then goto continue end
    if not vim.api.nvim_get_option_value("buflisted", { buf = bufnr, }) then goto continue end
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    if buf_name == nil then goto continue end
    if buf_name == "" then goto continue end
    if not vim.startswith(buf_name, cwd) then goto continue end

    open_buffers[buf_name] = 0

    ::continue::
  end
  benchmark("end", "open_buffers loop")

  local function scale_fuzzy_value_to_frecency(value)
    return (value) / (MAX_FUZZY_SCORE) * MAX_FRECENCY_SCORE
  end

  benchmark("start", "batching")
  local weighted_files = {}
  local current_index = 1


  local function process_batch()
    if tick ~= curr_tick then
      return
    end

    local end_index = math.min(current_index + BATCH_SIZE - 1, #fd_files)
    for i = current_index, end_index do
      local file = fd_files[i]
      local score = 0

      if open_buffers[file] ~= nil then
        local bufnr = vim.fn.bufnr(file)
        local changed = vim.api.nvim_get_option_value("modified", { buf = bufnr, })

        if file == opts.curr_bufname then
          score = CURR_BUF_BOOST
        elseif file == opts.alt_bufname then
          score = ALT_BUF_BOOST
        elseif changed == h.vimscript_true then
          score = CHANGED_BUF_BOOST
        else
          score = OPEN_BUF_BOOST
        end
      end

      if frecency_files[file] ~= nil then
        score = score + frecency_files[file]
      end

      local highlight_idxs = {}
      local rel_file = vim.fs.relpath(cwd, file)

      if query ~= "" then
        local fuzzy_res = mini_fuzzy.match(query, rel_file)
        highlight_idxs = fuzzy_res.positions or {}
        local fuzzy_score = fuzzy_res.score
        if fuzzy_score ~= -1 then
          local inverted_fuzzy_score = MAX_FUZZY_SCORE - fuzzy_score
          local scaled_fuzzy_score = scale_fuzzy_value_to_frecency(inverted_fuzzy_score)

          score = 0.7 * scaled_fuzzy_score + 0.3 * score
        end
      end

      table.insert(weighted_files, { file = rel_file, score = score, highlight_idxs = highlight_idxs, })
    end

    current_index = end_index + 1
    if current_index <= #fd_files then
      vim.schedule(process_batch)
    else
      benchmark("end", "batching")

      benchmark("start", "weighted_files sort")
      table.sort(weighted_files, function(a, b)
        return a.score < b.score -- reverse order
      end)
      benchmark("end", "weighted_files sort")

      benchmark("start", "weighted_files format loop")
      local formatted_files = {}
      for idx, weighted_entry in pairs(weighted_files) do
        local formatted = format_filename(weighted_entry.file, weighted_entry.score, weighted_entry.highlight_idxs, idx)
        table.insert(formatted_files, formatted)
      end
      benchmark("end", "weighted_files format loop")

      benchmark("end", "entire script")

      callback(formatted_files)
    end
  end
  process_batch()
end

vim.keymap.set("n", "<leader>f", function()
  maybe_close_mini_files()
  local curr_bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local alt_bufname = vim.api.nvim_buf_get_name(vim.fn.bufnr "#")

  vim.cmd "vnew"
  local results_buf = vim.api.nvim_get_current_buf()
  local results_win = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(results_buf, "Results")

  vim.cmd "new"
  vim.cmd "resize 1"
  vim.cmd "startinsert"
  local input_buf = vim.api.nvim_get_current_buf()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(input_buf, "Input")

  vim.schedule(
    function()
      get_smart_files({
        query = "",
        results_buf = results_buf,
        curr_bufname = curr_bufname,
        alt_bufname = alt_bufname,
      }, function(results)
        vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, results)
        vim.api.nvim_win_call(results_win, function()
          h.keys.send_keys("n", "G")
        end)
      end)
    end
  )

  local function close_picker()
    local force = true
    vim.api.nvim_buf_delete(input_buf, { force = force, })
    vim.api.nvim_buf_delete(results_buf, { force = force, })
  end

  vim.keymap.set("i", "<C-n>", function()
    vim.api.nvim_win_call(results_win, function()
      h.keys.send_keys("n", "j")
    end)
  end, { buffer = input_buf, })

  vim.keymap.set("i", "<C-p>", function()
    vim.api.nvim_win_call(results_win, function()
      h.keys.send_keys("n", "k")
    end)
  end, { buffer = input_buf, })

  vim.keymap.set("i", "<cr>", function()
    vim.api.nvim_win_call(results_win, function()
      local entry = vim.api.nvim_get_current_line()
      local file = vim.split(entry, "|")[2]
      close_picker()
      vim.cmd("edit " .. file)
      vim.cmd "stopinsert"
    end)
  end, { buffer = input_buf, })

  for _, keymap in pairs { "q", "<leader>q", "<esc>", "<C-c>", } do
    vim.keymap.set("n", keymap, close_picker, { buffer = results_buf, nowait = true, })
    vim.keymap.set("n", keymap, close_picker, { buffer = input_buf, nowait = true, })
  end

  vim.keymap.set("i", "<C-c>", function()
    close_picker()
    vim.cmd "stopinsert"
  end, { buffer = input_buf, nowait = true, })

  local debounce_timer

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", }, {
    buffer = input_buf,
    callback = function()
      tick = tick + 1
      local curr_tick = tick

      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
      end

      debounce_timer = vim.fn.timer_start(150, function()
        vim.schedule(function()
          if curr_tick ~= tick then return end

          local query = vim.api.nvim_get_current_line()
          get_smart_files({
            query = query,
            results_buf = results_buf,
            curr_bufname = curr_bufname,
            alt_bufname = alt_bufname,
          }, function(results)
            vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, results)
            vim.api.nvim_win_call(results_win, function()
              h.keys.send_keys("n", "G")
            end)
          end)
        end)
      end)
    end,
  })
end)
