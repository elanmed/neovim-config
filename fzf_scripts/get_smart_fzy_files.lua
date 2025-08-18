assert(arg[1], "Missing arg1: `servername`")
assert(arg[2], "Missing arg2: `query`")

local servername = arg[1]
local query = arg[2]
query = query:gsub("%s+", "") -- fzy doesn't ignore spaces

local CYAN = "\27[36m"
local RESET = "\27[0m"

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type string
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
vim.fn.chanclose(chan)

local mini_icons = require "mini.icons"
local fzy = require "fzy-lua-native"
local h = require "helpers"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local sorted_files_path = frecency_helpers.get_sorted_files_path()
local frecency_fs = require "fzf-lua-frecency.fs"
local frecency_algo = require "fzf-lua-frecency.algo"

local now = os.time()
--- @param abs_file string
--- @param score number
--- @param pos table
local function format_filename(abs_file, score, pos)
  local icon_ok, icon_res = pcall(mini_icons.get, "file", abs_file)
  local icon = icon_ok and icon_res or "?"
  --- @type string
  local rel_file = vim.fs.relpath(cwd, abs_file)

  local max_score = 99
  local max_score_len = #frecency_helpers.exact_decimals(max_score, 2)

  local formatted_score = frecency_helpers.pad_str(
    frecency_helpers.fit_decimals(score or 0, max_score_len),
    max_score_len
  )

  local with_ansi = ""
  local str_ptr = 1
  local pos_ptr = 1
  while str_ptr < #rel_file + 1 do
    if str_ptr == pos[pos_ptr] then
      with_ansi = with_ansi .. CYAN .. rel_file:sub(str_ptr, str_ptr) .. RESET
      pos_ptr = pos_ptr + 1
    else
      with_ansi = with_ansi .. rel_file:sub(str_ptr, str_ptr)
    end
    str_ptr = str_ptr + 1
  end

  return ("%s %s |%s"):format(formatted_score, icon, with_ansi)
end

local frecency_scored_files = {}

local seen = {}
local dated_files_path = frecency_helpers.get_dated_files_path()
local dated_files = frecency_fs.read(dated_files_path)

for frecency_file in io.lines(sorted_files_path) do
  if vim.fn.filereadable(frecency_file) == 0 then goto continue end
  if not vim.startswith(frecency_file, cwd) then goto continue end
  seen[frecency_file] = true

  local db_index = 1 -- TODO: remove
  if not dated_files[db_index] then
    dated_files[db_index] = {}
  end
  local date_at_score_one = dated_files[db_index][frecency_file]
  local score = frecency_algo.compute_score { now = now, date_at_score_one = date_at_score_one, }
  frecency_scored_files[frecency_file] = score

  ::continue::
end

local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
local handle = io.popen(fd_cmd)
if handle then
  for fd_file in handle:lines() do
    if seen[fd_file] then goto continue end
    seen[fd_file] = true

    frecency_scored_files[fd_file] = 0

    ::continue::
  end
  handle:close()
end

local weighted_files = {}
for abs_file, frecency_score in pairs(frecency_scored_files) do
  local rel_file = vim.fs.relpath(cwd, abs_file)
  local fzy_score = 0
  local fzy_pos = {}
  -- fzy gives a score of -inf to empty strings
  if query ~= "" and fzy.has_match(query, rel_file) then
    fzy_score = fzy.score(query, rel_file)
    fzy_pos = fzy.positions(query, rel_file)
    h.dev.log { query = query, fzy = fzy.score(query, rel_file), file = rel_file, pos = fzy_pos, }
  end

  local score = fzy_score * 1.5 + frecency_score
  table.insert(weighted_files, { file = abs_file, score = score, pos = fzy_pos, })
end

table.sort(weighted_files, function(a, b)
  return a.score > b.score
end)

for _, weighted_entry in pairs(weighted_files) do
  local formatted = format_filename(weighted_entry.file, weighted_entry.score, weighted_entry.pos)
  h.print_with_flush(formatted)
end
