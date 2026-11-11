local tbl = {}
local str = {}
local _os = {}
local dev = {}
local utils = {}
local async = {}
local qf = {}
local fs = {}

local vimscript_true = 1
local vimscript_false = 0

--- @param predicate fun(curr_item, idx: number): any
--- @param list table
tbl.map = function(predicate, list)
  local mapped_list = {}
  for index, val in ipairs(list) do
    -- vim.tbl_map doesn't pass the index
    table.insert(mapped_list, predicate(val, index))
  end
  return mapped_list
end

--- @param ... any[]
tbl.extend = function(...)
  local result = {}
  for _, list in ipairs { ... } do
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

--- @param content any
dev.log = function(content)
  local file = io.open("log.txt", "a")
  if file == nil then
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
    local relfilename = vim.fs.relpath(base_lua_path, path)
    if relfilename == nil then
      goto continue
    end

    relfilename = relfilename:gsub("%.lua$", "")
    require(relfilename)
    ::continue::
  end
end

--- @param try string
--- @param catch string
utils.vim_cmd_try_catch = function(try, catch)
  local success = pcall(function()
    vim.cmd(try)
  end)
  if not success then
    pcall(function()
      vim.cmd(catch)
    end)
  end
end

--- @generic T : vim.fn.getqflist.ret
--- @param predicate fun(qf: T): boolean
--- @return T[]
qf.filter = function(predicate)
  local count = vim.fn.getqflist({ nr = "$" }).nr
  if count == 0 then
    return {}
  end

  local qf_lists = vim
    .iter(vim.fn.range(1, count))
    :map(
      --- @param qf_list_number_arg integer
      function(qf_list_number_arg)
        ---@diagnostic disable-next-line: missing-return-value
        return vim.fn.getqflist {
          nr = qf_list_number_arg,
          items = 0,
          context = 0,
          idx = 0,
          title = 0,
        }
      end
    )
    :filter(predicate)
    :totable()

  return qf_lists
end

--- @param qf_lists vim.fn.getqflist.ret[]
qf.replace = function(qf_lists)
  vim.fn.setqflist({}, "f")

  for _, list in ipairs(qf_lists) do
    vim.fn.setqflist({}, " ", {
      nr = "$",
      items = list.items,
      title = list.title,
      context = list.context,
      idx = list.idx,
    })
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

--- @class IsBigFileOpts
--- @field bname string
--- @field line_count number
--- @param opts IsBigFileOpts
utils.is_big_file = function(opts)
  local one_pt_five_mb = 1.5 * 1024 * 1024
  return vim.fn.getfsize(opts.bname) > one_pt_five_mb or opts.line_count > 20000
end

--- @type fun(cmd: string[], opts: vim.SystemOpts?): vim.SystemCompleted
local system_async = vim.async.wrap(3, vim.system)

--- @type fun(cmd: string[], opts: vim.SystemOpts?): vim.async.Task<string?, string?>
async.system = function(cmd, opts)
  --- @return string?, string?
  return vim.async.run(function()
    local out = system_async(cmd, opts)
    if out.code ~= 0 then
      local err = vim.trim(out.stderr)
      if err == "" then
        err = "unknown error"
      end
      --- @diagnostic disable-next-line: redundant-return-value
      return string.format("%s failed. Error: %s", table.concat(cmd, " "), err), nil
    end

    --- @diagnostic disable-next-line: redundant-return-value
    return nil, out.stdout
  end)
end

--- @type fun(opts: vim.ui.input.Opts?): string?
async.ui_input = vim.async.wrap(2, vim.ui.input)

--- @param callback fun(...: any): any
--- @return fun(...: any): nil
async.cb = function(callback)
  return function(...)
    local arguments = { ... }
    vim.async
      .run(function()
        return callback(unpack(arguments))
      end)
      :raise_on_error()
  end
end

async.ensure_main_loop = function()
  vim.async.sleep(0)
end

--- @param filepath string
--- @return vim.async.Task<string?, { lines: string[], str: string }?>
fs.readfile = function(filepath)
  --- @return string?, { lines: string[], str: string }?
  return vim.async.run(function()
    --- @diagnostic disable: redundant-return-value
    local open_err, fd = vim.async.await(function(callback)
      vim.uv.fs_open(filepath, 0, 0, callback)
    end)
    if open_err then
      return open_err, nil
    end

    local stat_err, stat = vim.async.await(2, vim.uv.fs_fstat, fd)
    if stat_err ~= nil then
      vim.async.await(2, vim.uv.fs_close, fd)
      return stat_err, nil
    end

    local content = ""
    local read_err = nil
    if stat.size > 0 then
      read_err, content = vim.async.await(4, vim.uv.fs_read, fd, stat.size, 0)
    end
    local close_err = vim.async.await(2, vim.uv.fs_close, fd)
    if read_err then
      return read_err, nil
    end
    if close_err then
      return close_err, nil
    end

    local lines = (function()
      if content == "" then
        return {}
      end
      return vim.split(content, "\n", { plain = true })
    end)()

    -- vim.split on a string that ends in a newline produces a trailing "" item
    if lines[#lines] == "" then
      table.remove(lines)
    end

    local str = (function()
      if #lines == 0 then
        return ""
      end
      return table.concat(lines, "\n") .. "\n"
    end)()

    return nil, { lines = lines, str = str }
    --- @diagnostic enable: redundant-return-value
  end)
end

--- @class PadOpts
--- @field min_len number
--- @field side 'left' | 'right'
--- @param val string | number
--- @param opts PadOpts
str.pad = function(val, opts)
  if vim.fn.strchars(tostring(val)) >= opts.min_len then
    return tostring(val)
  end

  local num_spaces = opts.min_len - vim.fn.strchars(tostring(val))
  if opts.side == "left" then
    return string.rep(" ", num_spaces) .. tostring(val)
  end
  return tostring(val) .. string.rep(" ", num_spaces)
end

--- @class TruncateOpts
--- @field max_len number
--- @field side 'left' | 'right'
--- @param val string
--- @param opts TruncateOpts
str.truncate = function(val, opts)
  local ellipsis = "…"
  local char_count = vim.fn.strchars(val)
  if char_count <= opts.max_len then
    return val
  end
  if opts.max_len <= 0 then
    return ""
  end

  local content_len = opts.max_len - vim.fn.strchars(ellipsis)
  if opts.side == "right" then
    return vim.fn.strcharpart(val, 0, content_len) .. ellipsis
  end

  local start_index = char_count - content_len
  return ellipsis .. vim.fn.strcharpart(val, start_index, content_len)
end

return {
  tbl = tbl,
  os = _os,
  dev = dev,
  vimscript_true = vimscript_true,
  vimscript_false = vimscript_false,
  fd_cmd = {
    "fd",
    "--absolute-path",
    "--hidden",
    "--type",
    "f",
    "--exclude",
    ".git",
    "--exclude",
    "node_modules",
    "--exclude",
    "dist",
  },
  utils = utils,
  qf = qf,
  fs = fs,
  str = str,
  async = async,
}
