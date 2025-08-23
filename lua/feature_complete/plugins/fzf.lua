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

-- vim.keymap.set("n", "<leader>zy", function()
--   maybe_close_mini_files()
--
--   local get_smart_files_script = vim.fs.joinpath(
--     os.getenv "HOME",
--     "/.dotfiles/neovim/.config/nvim/fzf_scripts/get_smart_files.lua"
--   )
--   local source = table.concat({
--     "nvim",
--     "--headless",
--     "--noplugin",
--     "-l",
--     get_smart_files_script,
--     vim.v.servername,
--   }, " ")
--
--   local smart_fzy_opts = {
--     "--ghost", "Smart fzy",
--     "--ansi",
--     "--delimiter", "|",
--     "--disabled",
--     "--bind", ("start:reload:%s {q}"):format(source),
--     "--bind", ("change:reload:%s {q}"):format(source),
--   }
--
--   local spec = {
--     source = source,
--     options = extend(smart_fzy_opts, default_opts, single_select_opts),
--     window = without_preview_window_opts,
--     sink = function(entry)
--       local filename = vim.split(entry, "|")[2]
--       vim.cmd("e " .. filename)
--     end,
--   }
--
--   vim.fn["fzf#run"](spec)
-- end)

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
local fzy = require "fzy-lua-native"
local ns_id = vim.api.nvim_create_namespace "SmartHighlight"

local LOG = true
local ICONS_ENABLED = true
local HL_ENABLED = true

--- @param file string
local function get_extension(file)
  local dot_pos = file:find "%.[^.]+$"

  if dot_pos then
    return file:sub(dot_pos + 1)
  end
  return nil
end

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

--- @type string[]
local fd_files = {}

--- @type string[]
local frecency_files = {}

-- {[file_name] = 0}
local frecency_file_to_score = {}

-- {[icon_name] = {icon_char = "", icon_hl = ""}}
local icon_cache = {}

local db_index = 1
--- @type string
local cwd = vim.uv.cwd()

local function populate_fd_cache()
  benchmark("start", "fd")
  local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
  local fd_handle = io.popen(fd_cmd)
  if fd_handle then
    for abs_file in fd_handle:lines() do
      table.insert(fd_files, abs_file)
    end
    fd_handle:close()
  end
  benchmark("end", "fd")
end

local function populate_frecency_files_cwd_cache()
  local sorted_files_path = frecency_helpers.get_sorted_files_path()

  benchmark("start", "sorted_files_path fs read")
  for abs_file in io.lines(sorted_files_path) do
    if not vim.startswith(abs_file, cwd) then goto continue end
    if vim.fn.filereadable(abs_file) == h.vimscript_false then goto continue end

    table.insert(frecency_files, abs_file)

    ::continue::
  end
  benchmark("end", "sorted_files_path fs read")
end

local function populate_frecency_scores_cache()
  benchmark("start", "dated_files fs read")
  local dated_files_path = frecency_helpers.get_dated_files_path()
  local dated_files = frecency_fs.read(dated_files_path)
  if not dated_files[db_index] then
    dated_files[db_index] = {}
  end
  benchmark("end", "dated_files fs read")

  local now = os.time()
  benchmark("start", "calculate frecency_file_to_score")
  for _, abs_file in ipairs(frecency_files) do
    local date_at_score_one = dated_files[db_index][abs_file]
    local score = frecency_algo.compute_score { now = now, date_at_score_one = date_at_score_one, }
    frecency_file_to_score[abs_file] = score
  end
  benchmark("end", "calculate frecency_file_to_score")
end

--- @class GetSmartFilesOpts
--- @field query string
--- @field results_buf number
--- @field curr_bufname string
--- @field alt_bufname string
--- @field curr_tick number

--- @param opts GetSmartFilesOpts
--- @param callback function
local function get_smart_files(opts, callback)
  benchmark("start", "entire script")
  local query = opts.query:gsub("%s+", "") -- fzy doesn't ignore spaces

  local OPEN_BUF_BOOST = 10
  local CHANGED_BUF_BOOST = 20
  local ALT_BUF_BOOST = 30
  local CURR_BUF_BOOST = -1000

  -- [-math.huge, math.huge]
  -- just below math.huge is aprox the length of the string
  -- just above -math.huge is aprox 0
  local MAX_FZY_SCORE = 20
  local MAX_FRECENCY_SCORE = 99

  local max_score_len = #frecency_helpers.exact_decimals(MAX_FRECENCY_SCORE, 2)
  local icon_char_offset = #frecency_helpers.pad_str(
    frecency_helpers.fit_decimals(MAX_FRECENCY_SCORE, max_score_len),
    max_score_len
  )

  local BATCH_SIZE = 500
  --- @param abs_file string
  local function get_rel_file(abs_file)
    return abs_file:sub(#cwd + 2)
  end

  --- @param rel_file string
  --- @param score number
  --- @param icon string
  local function format_filename(rel_file, score, icon)
    local formatted_score = frecency_helpers.pad_str(
      frecency_helpers.fit_decimals(score or 0, max_score_len),
      max_score_len
    )

    local formatted = ("%s %s|%s"):format(formatted_score, icon, rel_file)

    return formatted
  end

  --- @param fzy_score number
  local function scale_fzy_to_frecency(fzy_score)
    if fzy_score == math.huge then return MAX_FRECENCY_SCORE end
    if fzy_score == -math.huge then return 0 end
    return (fzy_score) / (MAX_FZY_SCORE) * MAX_FRECENCY_SCORE
  end

  benchmark("start", "open_buffer_to_score loop")
  local open_buffer_to_score = {}
  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_loaded(bufnr) then goto continue end
    if not vim.api.nvim_get_option_value("buflisted", { buf = bufnr, }) then goto continue end
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    if buf_name == nil then goto continue end
    if buf_name == "" then goto continue end
    if not vim.startswith(buf_name, cwd) then goto continue end

    open_buffer_to_score[buf_name] = 0

    ::continue::
  end
  benchmark("end", "open_buffer_to_score loop")

  --- @class AnnotatedFile
  --- @field file string
  --- @field score number
  --- @field hl_idxs table
  --- @field icon_char string
  --- @field icon_hl string

  --- @type AnnotatedFile[]
  local weighted_files = {}

  local process_files = coroutine.create(function()
    --- @type AnnotatedFile[]
    local fuzzy_files = {}
    benchmark("start", "calculate fuzzy_files")
    for idx, abs_file in ipairs(fd_files) do
      if query == "" then
        table.insert(fuzzy_files, { file = abs_file, score = 0, hl_idxs = {}, })
      else
        local rel_file = get_rel_file(abs_file)
        if fzy.has_match(query, rel_file) then
          local fzy_score = fzy.score(query, rel_file)
          local scaled_fzy_score = scale_fzy_to_frecency(fzy_score)
          local hl_idxs = {}
          if HL_ENABLED then
            hl_idxs = fzy.positions(query, rel_file)
          end

          table.insert(fuzzy_files,
            {
              file = abs_file,
              score = scaled_fzy_score,
              hl_idxs = hl_idxs,
              icon_char = "",
              icon_hl = nil,
            })
        end
      end

      if idx % BATCH_SIZE == 0 then
        coroutine.yield()
      end
    end
    benchmark("end", "calculate fuzzy_files")

    benchmark("start", "calculate weighted_files")
    for idx, fuzzy_entry in ipairs(fuzzy_files) do
      local frecency_and_buf_score = 0

      local abs_file = fuzzy_entry.file

      if open_buffer_to_score[abs_file] ~= nil then
        local bufnr = vim.fn.bufnr(abs_file)
        local changed = vim.api.nvim_get_option_value("modified", { buf = bufnr, })

        if abs_file == opts.curr_bufname then
          frecency_and_buf_score = CURR_BUF_BOOST
        elseif abs_file == opts.alt_bufname then
          frecency_and_buf_score = ALT_BUF_BOOST
        elseif changed == h.vimscript_true then
          frecency_and_buf_score = CHANGED_BUF_BOOST
        else
          frecency_and_buf_score = OPEN_BUF_BOOST
        end
      end

      if frecency_file_to_score[abs_file] ~= nil then
        frecency_and_buf_score = frecency_and_buf_score + frecency_file_to_score[abs_file]
      end

      local weighted_score = 0.7 * fuzzy_entry.score + 0.3 * frecency_and_buf_score

      local rel_file = get_rel_file(abs_file)
      local icon_char = ""
      local icon_hl = nil

      local ext = get_extension(rel_file)
      if ICONS_ENABLED then
        if icon_cache[ext] then
          icon_char = icon_cache[ext].icon_char .. " "
          icon_hl = icon_cache[ext].icon_hl
        else
          local ok, icon_char_res, icon_hl_res = pcall(mini_icons.get, "file", rel_file)
          icon_char = (icon_char_res or "?") .. " "
          if ok then
            icon_hl = icon_hl_res
          end
          if ext then icon_cache[ext] = { icon_char = icon_char_res or "?", icon_hl = icon_hl, } end
        end
      end

      table.insert(
        weighted_files,
        {
          file = rel_file,
          score = weighted_score,
          hl_idxs = fuzzy_entry.hl_idxs,
          icon_hl = icon_hl,
          icon_char = icon_char,
        }
      )

      if idx % BATCH_SIZE == 0 then
        coroutine.yield()
      end
    end
    benchmark("end", "calculate weighted_files")

    benchmark("start", "sort weighted_files")
    table.sort(weighted_files, function(a, b)
      return a.score > b.score
    end)
    benchmark("end", "sort weighted_files")

    benchmark("start", "format weighted_files")
    --- @type string[]
    local formatted_files = {}
    for idx, weighted_entry in ipairs(weighted_files) do
      if idx > 200 then break end

      local formatted = format_filename(weighted_entry.file, weighted_entry.score, weighted_entry.icon_char)
      table.insert(formatted_files, formatted)
      if idx % BATCH_SIZE == 0 then
        coroutine.yield()
      end
    end
    benchmark("end", "format weighted_files")

    benchmark("start", "callback")
    callback(formatted_files)
    benchmark("end", "callback")

    if not HL_ENABLED then return end

    benchmark("start", "highlight loop")
    for idx, formatted_file in ipairs(formatted_files) do
      local row_0_indexed = idx - 1

      if weighted_files[idx].icon_hl then
        local space_offset = 1
        local icon_hl_col_0_indexed = icon_char_offset + space_offset

        vim.hl.range(
          opts.results_buf,
          ns_id,
          weighted_files[idx].icon_hl,
          { row_0_indexed, icon_hl_col_0_indexed, },
          { row_0_indexed, icon_hl_col_0_indexed + 1, }
        )
      end

      local file_offset = string.find(formatted_file, "|")
      for _, hl_idx in ipairs(weighted_files[idx].hl_idxs) do
        local file_char_hl_col_0_indexed = hl_idx + file_offset - 1

        vim.hl.range(
          opts.results_buf,
          ns_id,
          "SmartFilesFuzzyHighlightIdx",
          { row_0_indexed, file_char_hl_col_0_indexed, },
          { row_0_indexed, file_char_hl_col_0_indexed + 1, }
        )
      end

      if idx % BATCH_SIZE == 0 then
        coroutine.yield()
      end
    end
    benchmark("end", "highlight loop")
    benchmark("end", "entire script")
  end)

  local function continue_processing()
    if tick ~= opts.curr_tick then return end
    coroutine.resume(process_files)

    if coroutine.status(process_files) == "suspended" then
      vim.schedule(continue_processing)
    end
  end

  continue_processing()
end

populate_fd_cache()
populate_frecency_files_cwd_cache()

vim.keymap.set("n", "<leader>f", function()
  maybe_close_mini_files()
  local _, curr_bufname = pcall(vim.api.nvim_buf_get_name, 0)
  local _, alt_bufname = pcall(vim.api.nvim_buf_get_name, vim.fn.bufnr "#")

  vim.cmd "vnew"
  local input_buf = vim.api.nvim_get_current_buf()
  local input_win = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(input_buf, "Input")

  vim.cmd "new"
  vim.cmd "resize"
  local results_buf = vim.api.nvim_get_current_buf()
  local results_win = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(results_buf, "Results")

  vim.cmd "wincmd p"
  vim.cmd "startinsert"

  vim.schedule(
    function()
      populate_frecency_scores_cache()
      get_smart_files({
        query = "",
        results_buf = results_buf,
        curr_bufname = curr_bufname or "",
        alt_bufname = alt_bufname or "",
        curr_tick = tick,
      }, function(results)
        vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, results)
      end)
    end
  )

  local function close_picker()
    local force = true
    vim.api.nvim_buf_delete(input_buf, { force = force, })
    vim.api.nvim_buf_delete(results_buf, { force = force, })
  end

  vim.keymap.set({ "i", "n", }, "<C-n>", function()
    vim.api.nvim_set_current_win(results_win)
    h.keys.send_keys("n", "j")
    vim.api.nvim_set_current_win(input_win)
  end, { buffer = input_buf, })

  vim.keymap.set("n", "<C-j>", h.keys.vim_cmd_cb "wincmd j", { buffer = input_buf, })
  vim.keymap.set("n", "<C-j>", h.keys.vim_cmd_cb "wincmd j", { buffer = results_buf, })
  vim.keymap.set("n", "<C-k>", h.keys.vim_cmd_cb "wincmd k", { buffer = results_buf, })
  vim.keymap.set("n", "<C-k>", h.keys.vim_cmd_cb "wincmd k", { buffer = input_buf, })

  vim.keymap.set({ "i", "n", }, "<C-p>", function()
    vim.api.nvim_set_current_win(results_win)
    h.keys.send_keys("n", "k")
    vim.api.nvim_set_current_win(input_win)
  end, { buffer = input_buf, })

  vim.keymap.set({ "i", "n", }, "<cr>", function()
    vim.api.nvim_set_current_win(results_win)
    local entry = vim.api.nvim_get_current_line()
    local file = vim.split(entry, "|")[2]
    close_picker()
    vim.cmd("edit " .. file)
    vim.cmd "stopinsert"

    vim.schedule(function()
      local abs_file = vim.fs.joinpath(cwd, file)
      frecency_algo.update_file_score(abs_file, { update_type = "increase", })
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

  vim.api.nvim_set_option_value("winhighlight", "CursorLine:SmartFilesResultsCursor", { win = results_win, })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", }, {
    buffer = input_buf,
    callback = function()
      tick = tick + 1
      vim.schedule(function()
        local query = vim.api.nvim_get_current_line()
        get_smart_files({
          query = query,
          results_buf = results_buf,
          curr_bufname = curr_bufname or "",
          alt_bufname = alt_bufname or "",
          curr_tick = tick,
        }, function(results)
          vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, results)
        end)
      end)
    end,
  })
end)
