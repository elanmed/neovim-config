assert(arg[1], "Missing arg1: `servername`")

local entire_file_time = os.clock()

local h = require "helpers"
local bench = function(name, start_time)
  local end_time = os.clock()
  local elapsed_ms = (end_time - start_time) * 1000
  h.dev.log { string.format("%s: %.3f", name, elapsed_ms), }
end

local servername = arg[1]
local query = arg[2] or ""
query = query:gsub("%s+", "") -- fzy doesn't ignore spaces

local ANSI_CYAN = "\27[33m"
local ANSI_RESET = "\27[0m"

local OPEN_BUF_BOOST = 10
local CHANGED_BUF_BOOST = 20
local CURR_BUF_BOOST = -1000

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

local cwd_rpc_time = os.clock()
--- @type string
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
bench("cwd rpc", cwd_rpc_time)


--- @class BufInfo
--- @field name string
--- @field loaded number
--- @field changed boolean

local open_buffers_rpc_time = os.clock()
--- @type BufInfo[]
local open_buffers = vim.rpcrequest(chan, "nvim_call_function", "getbufinfo", { { buflisted = h.vimscript_true, }, })
bench("open buffers rpc", open_buffers_rpc_time)

local curr_buf_rpc_time = os.clock()
--- current buff is the fzf terminal buffer, so the alternate file is the real "alternate" buf
--- @type string
local curr_buf = vim.rpcrequest(chan, "nvim_call_function", "expand", { "#:p", })
bench("curr buf rpc", curr_buf_rpc_time)

vim.fn.chanclose(chan)

local req_time = os.clock()
local mini_icons = require "mini.icons"
local fzy = require "fzy-lua-native"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local sorted_files_path = frecency_helpers.get_sorted_files_path()
local frecency_fs = require "fzf-lua-frecency.fs"
local frecency_algo = require "fzf-lua-frecency.algo"
bench("req_time", req_time)

local now = os.time()

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

local dated_files_path = frecency_helpers.get_dated_files_path()
local read_dated_files_time = os.clock()
local dated_files = frecency_fs.read(dated_files_path)
bench("read_dated_files_time", read_dated_files_time)

local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
local fd_time = os.clock()
local fd_handle = io.popen(fd_cmd)
if fd_handle then
  for fd_file in fd_handle:lines() do
    scored_files[fd_file] = 0
  end
  fd_handle:close()
end
bench("fd_time", fd_time)


local buf_loop_time = os.clock()
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
bench("buf_loop_time", buf_loop_time)

local frecency_loop_time = os.clock()
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
bench("frecency_loop_time", frecency_loop_time)

local weighted_loop_time = os.clock()
local weighted_files = {}
for abs_file, frecency_score in pairs(scored_files) do
  local rel_file = vim.fs.relpath(cwd, abs_file)
  local fzy_score = 0
  local fzy_pos = {}
  -- fzy gives a score of -inf to empty strings
  if query ~= "" and fzy.has_match(query, rel_file) then
    fzy_score = fzy.score(query, rel_file)
    fzy_pos = fzy.positions(query, rel_file)
  end

  local score = fzy_score * 3 + frecency_score
  table.insert(weighted_files, { file = abs_file, score = score, pos = fzy_pos, })
end
bench("weighted_loop_time", weighted_loop_time)

local sort_time = os.clock()
table.sort(weighted_files, function(a, b)
  return a.score > b.score
end)
bench("sort_time", sort_time)

local print_loop_time = os.clock()
for _, weighted_entry in pairs(weighted_files) do
  local formatted = format_filename {
    abs_file = weighted_entry.file,
    pos = weighted_entry.pos,
    score = weighted_entry.score,
  }
  h.print_with_flush(formatted)
end
bench("print_loop_time", print_loop_time)
bench("entire_file_time", entire_file_time)
