assert(arg[1], "Missing arg1: `servername`")

local h = require "helpers"
local servername = arg[1]
local query = arg[2] or ""
query = query:gsub("%s+", "") -- fzy doesn't ignore spaces

local log = true

local ongoing = {}
--- @param type "start"|"end"
--- @param label string
local benchmark = function(type, label)
  if not log then return end

  if type == "start" then
    ongoing[label] = os.clock()
  else
    local end_time = os.clock()
    local start_time = ongoing[label]
    local elapsed_ms = (end_time - start_time) * 1000
    h.dev.log { string.format("%.3f : %s", elapsed_ms, label), }
  end
end

benchmark("start", "entire script")

local ANSI_CYAN = "\27[33m"
local ANSI_RESET = "\27[0m"

local OPEN_BUF_BOOST = 10
local CHANGED_BUF_BOOST = 20
local CURR_BUF_BOOST = -1000
local MAX_FUZZY_SCORE = 10100
local MAX_FRECENCY_SCORE = 100

local function scale_fuzzy_value_to_frecency(value)
  return (value) / (MAX_FUZZY_SCORE) * MAX_FRECENCY_SCORE
end

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

benchmark("start", "getcwd() rpc")
--- @type string
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
benchmark("end", "getcwd() rpc")

--- @class BufInfo
--- @field name string
--- @field loaded number
--- @field changed boolean

benchmark("start", "getbufinfo() rpc")
--- @type BufInfo[]
local open_buffers = vim.rpcrequest(chan, "nvim_call_function", "getbufinfo", { { buflisted = h.vimscript_true, }, })
benchmark("end", "getbufinfo() rpc")

benchmark("start", "curr_buff rpc")
--- current buff is the fzf terminal buffer, so the alternate file is the real "alternate" buf
--- @type string
local curr_buf = vim.rpcrequest(chan, "nvim_call_function", "expand", { "#:p", })
benchmark("end", "curr_buff rpc")

vim.fn.chanclose(chan)

local mini_icons = require "mini.icons"
local frecency_helpers = require "fzf-lua-frecency.helpers"

--- @class FormatFilenameOpts
--- @field abs_file string
--- @field score number
--- @field pos table

--- @param opts FormatFilenameOpts
local function format_filename(opts)
  local icon_ok, icon_res = pcall(mini_icons.get, "file", opts.abs_file)
  local icon = icon_ok and icon_res or "?"
  --- @type string
  local rel_file = vim.fs.relpath(cwd, opts.abs_file)

  local max_score = 99
  local max_score_len = #frecency_helpers.exact_decimals(max_score, 2)

  local formatted_score = frecency_helpers.pad_str(
    frecency_helpers.fit_decimals(opts.score or 0, max_score_len),
    max_score_len
  )

  local with_ansi = ""
  local str_ptr = 1
  local pos_ptr = 1
  while str_ptr < #rel_file + 1 do
    if str_ptr == opts.pos[pos_ptr] then
      with_ansi = with_ansi .. ANSI_CYAN .. rel_file:sub(str_ptr, str_ptr) .. ANSI_RESET
      pos_ptr = pos_ptr + 1
    else
      with_ansi = with_ansi .. rel_file:sub(str_ptr, str_ptr)
    end
    str_ptr = str_ptr + 1
  end

  return ("%s %s |%s"):format(formatted_score, icon, with_ansi)
end

local scored_files = {}


benchmark("start", "fd")
local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
local fd_handle = io.popen(fd_cmd)
if fd_handle then
  for fd_file in fd_handle:lines() do
    scored_files[fd_file] = 0
  end
  fd_handle:close()
end
benchmark("end", "fd")

benchmark("start", "open_buffers loop")
for _, buf in ipairs(open_buffers) do
  if not vim.startswith(buf.name, cwd) then goto continue end
  if buf.loaded == h.vimscript_false then goto continue end
  if buf.name == nil then goto continue end
  if buf.name == "" then goto continue end

  if buf.name == curr_buf then
    scored_files[curr_buf] = CURR_BUF_BOOST
  elseif buf.changed == h.vimscript_true then
    scored_files[buf.name] = CHANGED_BUF_BOOST
  else
    scored_files[buf.name] = OPEN_BUF_BOOST
  end

  ::continue::
end
benchmark("end", "open_buffers loop")

local now = os.time()
local frecency_algo = require "fzf-lua-frecency.algo"
local frecency_fs = require "fzf-lua-frecency.fs"

local sorted_files_path = frecency_helpers.get_sorted_files_path()
local dated_files_path = frecency_helpers.get_dated_files_path()
benchmark("start", "dated_files fs read")
local dated_files = frecency_fs.read(dated_files_path)
benchmark("end", "dated_files fs read")

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

  scored_files[frecency_file] = (scored_files[frecency_file] or 0) + score

  ::continue::
end
benchmark("end", "sorted_files_path fs read")

local mini_fuzzy = require "mini.fuzzy"
local weighted_files = {}
benchmark("start", "scored_files loop")
for abs_file, score in pairs(scored_files) do
  local rel_file = vim.fs.relpath(cwd, abs_file)

  local scaled_fuzzy_score = 0
  local fuzzy_pos = {}
  local fuzzy_res = mini_fuzzy.match(query, rel_file)
  if fuzzy_res.score ~= -1 then
    local fuzzy_score = fuzzy_res.score
    fuzzy_pos = fuzzy_res.positions
    local inverted_fuzzy_score = MAX_FUZZY_SCORE - fuzzy_score
    scaled_fuzzy_score = scale_fuzzy_value_to_frecency(inverted_fuzzy_score)
  end

  local weighted_score = 0.7 * scaled_fuzzy_score + 0.3 * score
  table.insert(weighted_files, { file = abs_file, score = weighted_score, pos = fuzzy_pos, })
end
benchmark("end", "scored_files loop")

benchmark("start", "weighted_files sort")
table.sort(weighted_files, function(a, b)
  return a.score > b.score
end)
benchmark("end", "weighted_files sort")

benchmark("start", "weighted_files loop and print")
for _, weighted_entry in pairs(weighted_files) do
  local formatted = format_filename {
    abs_file = weighted_entry.file,
    pos = weighted_entry.pos,
    score = weighted_entry.score,
  }
  h.print_with_flush(formatted)
end
benchmark("end", "weighted_files loop and print")

benchmark("end", "entire script")
h.dev.log { "=====================", }
