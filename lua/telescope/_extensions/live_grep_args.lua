local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump(v)
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local function shift_until_delim(str, delim)
  local i = str["pos"]

  while i <= str["len"] do
    local current = string.sub(str["chars"], i, i)

    if current == delim then
      local result = string.sub(str["chars"], str["pos"], i - 1)
      str["pos"] = i + 1
      return result
    elseif current == "\\" then
      i = i + 1
    end

    i = i + 1

    if i > str["len"] then
      -- end reached without delimiter; return the rest of the string
      local result = string.sub(str["chars"], str["pos"], str["len"])
      str["pos"] = str["len"] + 1
      return result
    end
  end
end

--- If str begins with char, it shifts off the char of the beginning of str
local function shift_char(str, char)
  if str["pos"] > str["len"] then
    return false
  end

  local current = string.sub(str["chars"], str["pos"], str["pos"])

  if current == char then
    str["pos"] = str["pos"] + 1
    return true
  end

  return false
end

local function skip_spaces(str)
  local i = str["pos"]
  local skipped = false

  while i <= str["len"] do
    local current = string.sub(str["chars"], i, i)

    if current == " " then
      skipped = true
    else
      str["pos"] = i
      return skipped
    end

    i = i + 1
  end

  return skipped
end

--- Shifts any char off the begining of str
local function shift_any(str)
  if str["pos"] > str["len"] then
    return nil
  end

  local result = string.sub(str["chars"], str["pos"], str["pos"])
  str["pos"] = str["pos"] + 1
  return result
end

local non_autoquote_chars = {
  ["'"] = true,
  ["\""] = true,
  ["-"] = true,
}

--- Parses prompt shell like and returns a table containing the arguments
--- If autoquote is true (default) and promt does not start with ', " or - then { prompt } will be returned.
local parse = function(prompt, autoquote)
  if string.len(prompt) == 0 then return {} end

  autoquote = autoquote or autoquote == nil
  local first_char = string.sub(prompt, 1, 1)
  if autoquote and non_autoquote_chars[first_char] == nil then return { prompt } end

  local str = {
    chars = prompt,
    pos = 1,
    len = string.len(prompt)
  }

  local parts = {}
  local current_arg = nil

  while str["pos"] <= str["len"] do
    local safeguard = str["pos"]

    local delim
    local frag

    if skip_spaces(str) then
      if current_arg ~= nil then
        table.insert(parts, current_arg)
        current_arg = nil
      end
    else
      if shift_char(str, "\"") then
        delim = "\""
      end

      if shift_char(str, "'") then
        delim = "'"
      end

      if delim then
        frag = shift_until_delim(str, delim)
        if frag then
          frag = frag
              :gsub("\\\"", "\"")
              :gsub("\\'", "'")
        end
      else
        frag = shift_any(str)
      end

      if current_arg == nil then
        current_arg = frag
      else
        current_arg = current_arg .. frag
      end
    end

    if safeguard == str["pos"] then
      -- this should not happen
      goto afterloop
    end
  end

  if current_arg ~= nil then
    table.insert(parts, current_arg)
  end

  ::afterloop::

  return parts
end

local telescope = require("telescope")
local pickers = require "telescope.pickers"
local sorters = require('telescope.sorters')
local themes = require("telescope.themes")
local conf = require('telescope.config').values
local make_entry = require('telescope.make_entry')
local finders = require "telescope.finders"

local tbl_clone = function(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end

local setup_opts = {
  auto_quoting = true,
  mappings = {},
}

local live_grep_args = function(opts)
  opts = opts or {}

  opts.vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)

  local cmd_generator = function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local args = tbl_clone(opts.vimgrep_arguments)
    local prompt_parts = parse(prompt, opts.auto_quoting)

    local cmd = vim.tbl_flatten { args, prompt_parts, opts.search_dirs }

    print(dump(prompt_parts))
    return cmd
  end

  pickers.new(opts, {
    prompt_title = "Live Grep (Args)",
    finder = finders.new_job(cmd_generator, opts.entry_maker),
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
  }):find()
end


return telescope.register_extension {
  exports = {
    live_grep_args = live_grep_args,
  },
}
