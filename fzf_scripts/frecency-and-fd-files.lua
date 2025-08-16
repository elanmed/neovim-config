local frecency_files_path = arg[1]
assert(frecency_files_path, "Missing arg1: `frecency_files_path`")

local cwd = arg[2]
assert(cwd, "Missing arg2: `cwd`")

local mini_icons = require "mini.icons"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local frecency_fs = require "fzf-lua-frecency.fs"
local frecency_algo = require "fzf-lua-frecency.algo"

local now = os.time()

--- @param abs_file string
local function format_filename(abs_file)
  local icon_ok, icon_res = pcall(mini_icons.get, "file", abs_file)
  local icon = icon_ok and icon_res or "?"
  local rel_file = vim.fs.relpath(cwd, abs_file)
  local dated_files_path = frecency_helpers.get_dated_files_path()
  local dated_files = frecency_fs.read(dated_files_path)
  local db_index = 1 -- TODO: remove
  if not dated_files[db_index] then
    dated_files[db_index] = {}
  end
  local date_at_score_one = dated_files[db_index][abs_file]

  local max_score = 99
  local max_score_len = #frecency_helpers.exact_decimals(max_score, 2)

  local score = nil
  if date_at_score_one then
    score = frecency_algo.compute_score { now = now, date_at_score_one = date_at_score_one, }
  end

  local formatted_score = frecency_helpers.pad_str(
    frecency_helpers.fit_decimals(score or 0, max_score_len),
    max_score_len
  )

  return ("%s %s |%s"):format(formatted_score, icon, rel_file)
end

local function print_with_flush(str)
  io.write(str)
  io.write "\n"
  io.flush()
end

local seen = {}

for frecency_file in io.lines(frecency_files_path) do
  if vim.fn.filereadable(frecency_file) == 0 then goto continue end
  if not vim.startswith(frecency_file, cwd) then goto continue end
  seen[frecency_file] = true

  local formatted = format_filename(frecency_file)
  print_with_flush(formatted)

  ::continue::
end

local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
local handle = io.popen(fd_cmd)
if handle then
  for fd_file in handle:lines() do
    if seen[fd_file] then goto continue end
    seen[fd_file] = true

    local formatted = format_filename(fd_file)
    print_with_flush(formatted)

    ::continue::
  end
  handle:close()
end
