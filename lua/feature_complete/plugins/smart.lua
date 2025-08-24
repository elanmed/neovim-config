local function maybe_close_mini_files()
  if vim.bo.filetype == "minifiles" then
    require "mini.files".close()
  end
end

local tick = 0
local vimscript_false = 0
local vimscript_true = 0

local mini_icons = require "mini.icons"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local frecency_algo = require "fzf-lua-frecency.algo"
local frecency_fs = require "fzf-lua-frecency.fs"
local fzy = require "fzy-lua-native"
local ns_id = vim.api.nvim_create_namespace "SmartHighlight"

--- @type string
local cwd = vim.uv.cwd()

local LOG = true
local ICONS_ENABLED = true
local HL_ENABLED = true
local BATCH_SIZE = 500

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
local formatted_score_last_idx = #frecency_helpers.pad_str(
  frecency_helpers.fit_decimals(MAX_FRECENCY_SCORE, max_score_len),
  max_score_len
)
local icon_char_idx = formatted_score_last_idx + 2

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

--- @param file string
local function get_extension(file)
  local dot_pos = file:find "%.[^.]+$"

  if dot_pos then
    return file:sub(dot_pos + 1)
  end
  return nil
end

--- @param content string
local function log(content)
  local file = io.open("log.txt", "a")
  if not file then return end
  file:write(content)
  file:write "\n"
  file:close()
end

local LOG_LEN = 50

--- @param type "start"|"middle"|"end"
local function benchmark_line(type)
  if not LOG then return end

  if type == "start" then
    log("┌" .. ("─"):rep(LOG_LEN - 2) .. "┐")
  elseif type == "middle" then
    log("├" .. ("─"):rep(LOG_LEN - 2) .. "┤")
  else
    log("└" .. ("─"):rep(LOG_LEN - 2) .. "┘")
  end
end


--- @param content string
local function benchmark_start(content)
  if not LOG then return end

  benchmark_line "start"
  log("│" .. content .. (" "):rep(LOG_LEN - #content - 2) .. "│")
  benchmark_line "middle"
end

local ongoing_benchmarks = {}
--- @param type "start"|"end"
--- @param label string
local function benchmark(type, label)
  if not LOG then return end

  if type == "start" then
    ongoing_benchmarks[label] = os.clock()
  else
    local end_time = os.clock()
    local start_time = ongoing_benchmarks[label]
    local elapsed_ms = (end_time - start_time) * 1000
    local content = ("%.3f : %s"):format(elapsed_ms, label)
    log("│" .. content .. (" "):rep(LOG_LEN - #content - 2) .. "│")
  end
end

--- @type string[]
local fd_files = {}

--- @type string[]
local frecency_files = {}

--- @type table<string, number>
local frecency_file_to_score = {}

--- @type table<string, {icon_char: string, icon_hl: string|nil}>
local icon_cache = {}

--- @type table<string, number>
local open_buffer_to_score = {}

local function populate_fd_cache()
  benchmark("start", "fd")
  local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
  local fd_handle = io.popen(fd_cmd)
  if not fd_handle then
    error "[smart.lua] fd failed!"
    return
  end

  for abs_file in fd_handle:lines() do
    table.insert(fd_files, abs_file)
  end
  fd_handle:close()
  benchmark("end", "fd")
end

local function populate_frecency_files_cwd_cache()
  local sorted_files_path = frecency_helpers.get_sorted_files_path()

  benchmark("start", "sorted_files_path fs read")
  if not vim.fn.filereadable(sorted_files_path) then
    error "[smart.lua] sorted_files_path isn't readable!"
    return
  end

  for abs_file in io.lines(sorted_files_path) do
    if not vim.startswith(abs_file, cwd) then goto continue end
    if vim.fn.filereadable(abs_file) == vimscript_false then goto continue end

    table.insert(frecency_files, abs_file)

    ::continue::
  end
  benchmark("end", "sorted_files_path fs read")
end

local function populate_frecency_scores_cache()
  benchmark("start", "dated_files fs read")
  local dated_files_path = frecency_helpers.get_dated_files_path()
  local dated_files = frecency_fs.read(dated_files_path)
  local db_index = 1 -- backwards compat reasons
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

local function populate_open_buffers_cache()
  benchmark("start", "open_buffer_to_score loop")
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
  local query = opts.query:gsub("%s+", "") -- fzy doesn't ignore spaces
  benchmark_start(("query: '%s'"):format(query))
  benchmark("start", "entire script")

  --- @class AnnotatedFile
  --- @field file string
  --- @field score number
  --- @field hl_idxs table
  --- @field icon_char string
  --- @field icon_hl string

  --- @type AnnotatedFile[]
  local weighted_files = {}

  local process_files = coroutine.create(function()
    -- TODO: change type, only need file and score
    --- @type AnnotatedFile[]
    local fuzzy_files = {}
    benchmark("start", "calculate fuzzy_files")
    for idx, abs_file in ipairs(fd_files) do
      if query == "" then
        table.insert(fuzzy_files, {
          file = abs_file,
          score = 0,
          hl_idxs = {},
          icon_char = "",
          icon_hl = nil,
        })
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
      local buf_score = 0

      local abs_file = fuzzy_entry.file

      if open_buffer_to_score[abs_file] ~= nil then
        local bufnr = vim.fn.bufnr(abs_file)
        local changed = vim.api.nvim_get_option_value("modified", { buf = bufnr, })

        if abs_file == opts.curr_bufname then
          buf_score = CURR_BUF_BOOST
        elseif abs_file == opts.alt_bufname then
          buf_score = ALT_BUF_BOOST
        elseif changed == vimscript_true then
          buf_score = CHANGED_BUF_BOOST
        else
          buf_score = OPEN_BUF_BOOST
        end
      end

      local frecency_and_buf_score = buf_score
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
          local _, icon_char_res, icon_hl_res = pcall(mini_icons.get, "file", rel_file)
          icon_char = (icon_char_res or "?") .. " "
          icon_hl = icon_hl_res or nil
          if ext then
            icon_cache[ext] = { icon_char = icon_char_res or "?", icon_hl = icon_hl, }
          end
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

    if not HL_ENABLED then
      benchmark("end", "entire script")
      benchmark_line "end"
      return
    end

    benchmark("start", "highlight loop")
    for idx, formatted_file in ipairs(formatted_files) do
      local row_0_indexed = idx - 1

      if weighted_files[idx].icon_hl then
        local icon_hl_col_1_indexed = icon_char_idx
        local icon_hl_col_0_indexed = icon_hl_col_1_indexed - 1

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
    benchmark_line "end"
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

benchmark_start "Populate file-level caches"
populate_fd_cache()
populate_frecency_files_cwd_cache()
benchmark_line "end"

vim.keymap.set("n", "<leader>f", function()
  maybe_close_mini_files()
  local _, curr_bufname = pcall(vim.api.nvim_buf_get_name, 0)
  local _, alt_bufname = pcall(vim.api.nvim_buf_get_name, vim.fn.bufnr "#")

  vim.cmd "new"
  local results_buf = vim.api.nvim_get_current_buf()
  local results_win = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(results_buf, "Results")

  vim.cmd "new"
  vim.cmd "resize 1"
  local input_buf = vim.api.nvim_get_current_buf()
  local input_win = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(input_buf, "Input")

  vim.cmd "startinsert"

  vim.schedule(
    function()
      benchmark_start "Populate function-level caches"
      populate_frecency_scores_cache()
      populate_open_buffers_cache()
      benchmark_line "end"

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
    vim.cmd "normal! j"
    vim.api.nvim_set_current_win(input_win)
  end, { buffer = input_buf, })

  vim.keymap.set("n", "<C-j>", function() vim.cmd "wincmd j" end, { buffer = input_buf, })
  vim.keymap.set("n", "<C-j>", function() vim.cmd "wincmd j" end, { buffer = results_buf, })
  vim.keymap.set("n", "<C-k>", function() vim.cmd "wincmd k" end, { buffer = results_buf, })
  vim.keymap.set("n", "<C-k>", function() vim.cmd "wincmd k" end, { buffer = input_buf, })

  vim.keymap.set({ "i", "n", }, "<C-p>", function()
    vim.api.nvim_set_current_win(results_win)
    vim.cmd "normal! k"
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
