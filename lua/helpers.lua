local tbl = {}
local str = {}
local _os = {}
local dev = {}
local utils = {}
local diff = {}

--- @class UnpackedHunk
--- @field start_old_1i number
--- @field start_old_0i number
--- @field count_old number
--- @field end_old_1i_excl number
--- @field end_old_1i_incl number
--- @field end_old_0i_excl number
--- @field end_old_0i_incl number
--- @field start_new_1i number
--- @field start_new_0i number
--- @field count_new number
--- @field end_new_1i_excl number
--- @field end_new_1i_incl number
--- @field end_new_0i_excl number
--- @field end_new_0i_incl number
--- @field is_deletion boolean
--- @field is_insertion boolean

--- @alias DiffHunk { [1]: integer, [2]: integer, [3]: integer, [4]: integer }
--- @param hunk DiffHunk
--- @return UnpackedHunk
diff.unpack_hunk = function(hunk)
  local start_old_1i, count_old, start_new_1i, count_new = unpack(hunk)

  local start_old_0i = start_old_1i - 1
  local end_old_1i_excl = start_old_1i + count_old
  local end_old_1i_incl = end_old_1i_excl - 1
  local end_old_0i_excl = end_old_1i_excl - 1
  local end_old_0i_incl = end_old_1i_incl - 1

  local start_new_0i = start_new_1i - 1
  local end_new_1i_excl = start_new_1i + count_new
  local end_new_1i_incl = end_new_1i_excl - 1
  local end_new_0i_excl = end_new_1i_excl - 1
  local end_new_0i_incl = end_new_1i_incl - 1

  local is_deletion = count_new == 0
  local is_insertion = count_old == 0

  return {
    start_old_1i = start_old_1i,
    start_old_0i = start_old_0i,
    count_old = count_old,
    end_old_1i_excl = end_old_1i_excl,
    end_old_1i_incl = end_old_1i_incl,
    end_old_0i_excl = end_old_0i_excl,
    end_old_0i_incl = end_old_0i_incl,

    start_new_1i = start_new_1i,
    start_new_0i = start_new_0i,
    count_new = count_new,
    end_new_1i_excl = end_new_1i_excl,
    end_new_1i_incl = end_new_1i_incl,
    end_new_0i_excl = end_new_0i_excl,
    end_new_0i_incl = end_new_0i_incl,

    is_deletion = is_deletion,
    is_insertion = is_insertion,
  }
end

local vimscript_true = 1
local vimscript_false = 0

--- @param predicate fun(curr_item, idx: number): any
--- @param list table
tbl.map = function(predicate, list)
  local mapped_list = {}
  for index, val in pairs(list) do
    -- vim.tbl_map doesn't pass the index
    table.insert(mapped_list, predicate(val, index))
  end
  return mapped_list
end

--- @param ... any[]
tbl.extend = function(...)
  local result = {}
  for _, list in ipairs { ..., } do
    vim.list_extend(result, list)
  end
  return result
end

--- @param input table
tbl.reverse = function(input)
  local reversed = {}
  for index = #input, 1, -1 do
    table.insert(reversed, input[index])
  end
  return reversed
end

_os.is_linux = function()
  return vim.fn.has "macunix" == vimscript_false
end

--- @param content any
dev.log = function(content)
  local file = io.open("log.txt", "a")
  if not file then
    vim.notify("Error opening file!", vim.log.levels.ERROR)
    return
  end
  file:write(vim.inspect(content) .. "\n")
  file:close()
end

--- @param dir string i.e. "/feature_complete/plugins/"
utils.require_dir = function(dir)
  local base_lua_path = vim.fs.joinpath(vim.fn.stdpath "config", "lua")
  local glob_path = vim.fs.joinpath(base_lua_path, dir, "*.lua")
  local paths_str = vim.fn.glob(glob_path)
  local paths_tbl = vim.split(paths_str, "\n")
  for _, path in pairs(paths_tbl) do
    local relfilename = vim.fs.relpath(base_lua_path, path):gsub(".lua", "")
    require(relfilename)
  end
end

--- @generic T
--- @param val T | nil
--- @param fallback T
--- @return T
utils.if_nil = function(val, fallback)
  if val == nil then
    return fallback
  end
  return val
end

--- @param try string
--- @param catch string
utils.try_catch = function(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

utils.rotate_registers = function()
  for i = 9, 1, -1 do
    vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
  end
end

--- @param val string
utils.set_and_rotate = function(val)
  vim.fn.setreg("", val)
  vim.fn.setreg("+", val)
  vim.notify("Setting the unnamed and + registers to: `" .. val .. "`", vim.log.levels.INFO)
  utils.rotate_registers()
end

--- @class PadOpts
--- @field min_len number
--- @field side 'left' | 'right'
--- @param val string | number
--- @param opts PadOpts
str.pad = function(val, opts)
  if #tostring(val) >= opts.min_len then
    return tostring(val)
  end

  local num_spaces = opts.min_len - #tostring(val)
  if opts.side == "left" then
    return string.rep(" ", num_spaces) .. tostring(val)
  end
  return tostring(val) .. string.rep(" ", num_spaces)
end

local function safe_resume(...)
  local ok, err = coroutine.resume(...)
  if not ok then error(err) end
end

--- @param fn fun(...):nil
local async = function(fn)
  return function(...)
    safe_resume(coroutine.create(fn), ...)
  end
end

--- @alias Resolve fun():nil
--- @alias Promise fun(resolve: Resolve):nil

--- @param promise Promise
local await = function(promise)
  local thread = coroutine.running()
  assert(thread ~= nil, "`await` can only be called in a coroutine")
  local scheduled_promise = vim.schedule_wrap(promise)
  local resolve = function(...) safe_resume(thread, ...) end
  scheduled_promise(resolve)
  return coroutine.yield()
end

return {
  tbl = tbl,
  os = _os,
  dev = dev,
  vimscript_true = vimscript_true,
  vimscript_false = vimscript_false,
  fd_cmd = "fd --absolute-path --hidden --type f --exclude .git --exclude node_modules --exclude dist",
  utils = utils,
  str = str,
  async = async,
  await = await,
  diff = diff,
}
