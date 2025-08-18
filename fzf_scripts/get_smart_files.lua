assert(arg[1], "Missing arg1: `servername`")

local servername = arg[1]
local query = arg[2] or ""
query = query:gsub("%s+", "") -- fzy doesn't ignore spaces

local ANSI_CYAN = "\27[33m"
local ANSI_RESET = "\27[0m"

local OPEN_BUF_BOOST = 10
local CHANGED_BUF_BOOST = 20
local CURR_BUF_BOOST = -1000

local h = require "helpers"
local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

--- @type string
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})

--- @class BufInfo
--- @field name string
--- @field loaded number
--- @field changed boolean

--- @type BufInfo[]
local open_buffers = vim.rpcrequest(chan, "nvim_call_function", "getbufinfo", { { buflisted = h.vimscript_true, }, })

--- current buff is the fzf terminal buffer, so the alternate file is the real "alternate" buf
--- @type string
local curr_buf = vim.rpcrequest(chan, "nvim_call_function", "expand", { "#:p", })

vim.fn.chanclose(chan)

local mini_icons = require "mini.icons"
local fzy = require "fzy-lua-native"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local sorted_files_path = frecency_helpers.get_sorted_files_path()
local frecency_fs = require "fzf-lua-frecency.fs"
local frecency_algo = require "fzf-lua-frecency.algo"

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
local dated_files = frecency_fs.read(dated_files_path)

local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
local handle = io.popen(fd_cmd)
if handle then
  for fd_file in handle:lines() do
    scored_files[fd_file] = 0
  end
  handle:close()
end


for _, buf in ipairs(open_buffers) do
  if buf.loaded == h.vimscript_false then goto continue end
  if not vim.startswith(buf.name, cwd) then goto continue end
  if not buf.name then goto continue end
  if buf.name == "" then goto continue end

  if buf.name == curr_buf then
    scored_files[curr_buf] = CURR_BUF_BOOST
  elseif buf.changed == h.vimscript_true then
    scored_files[buf.name] = scored_files[buf.name] + CHANGED_BUF_BOOST
  else
    scored_files[buf.name] = OPEN_BUF_BOOST
  end

  ::continue::
end

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

table.sort(weighted_files, function(a, b)
  return a.score > b.score
end)

for _, weighted_entry in pairs(weighted_files) do
  local formatted = format_filename {
    abs_file = weighted_entry.file,
    pos = weighted_entry.pos,
    score = weighted_entry.score,
  }
  h.print_with_flush(formatted)
end
