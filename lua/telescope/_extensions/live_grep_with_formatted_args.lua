local pickers = require "telescope.pickers"
local sorters = require "telescope.sorters"
local telescope = require "telescope"
local conf = require "telescope.config".values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"

local tbl_clone = function(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end

--- @param o table
--- @return string
local function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. " [" .. k .. "] = " .. dump(v)
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local function split(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^%s]+)") do
    table.insert(t, str)
  end
  return t
end


local setup_opts = {
  auto_quoting = true,
}

-- TODO: types
local function insert_flags(str, include_table, negate_table)
  if str:sub(1, 1) == "!" then
    if #str == 1 then
      table.insert(negate_table, "")
    else
      table.insert(negate_table, str:sub(2))
    end
  else
    table.insert(include_table, str)
  end
end

-- TODO: types
local function construct_flag(dir_table, type_table, negate)
  local flag = ""
  if #dir_table > 0 then
    flag = flag .. "**/{" .. table.concat(dir_table, ",") .. "}/**"
  end

  if #type_table > 0 then
    if #dir_table > 0 then
      flag = flag .. "/"
    end
    flag = flag .. "*.{" .. table.concat(type_table, ",") .. "}"
  end

  if #flag > 0 then
    if negate then
      flag = "!" .. flag
    end
    return { "-g", flag, }
  end

  return {}
end

local live_grep_with_formatted_args = function()
  local vimgrep_arguments = conf.vimgrep_arguments
  local entry_maker = make_entry.gen_from_vimgrep(setup_opts)

  local cmd_generator = function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local split_prompt = split(prompt)

    local text = ""

    local parsing_type_flags = false
    local parsing_dir_flags = false

    local include_type_flags = {}
    local negate_type_flags = {}
    local include_dir_flags = {}
    local negate_dir_flags = {}

    local index = 1
    while index < (#split_prompt + 1) do
      if index == 1 then
        text = split_prompt[index]
        goto continue
      end

      if split_prompt[index] == "-t" then
        parsing_type_flags = true
        parsing_dir_flags = false
        goto continue
      end

      if split_prompt[index] == "-d" then
        parsing_dir_flags = true
        parsing_type_flags = false
        goto continue
      end

      if parsing_type_flags == true then
        insert_flags(split_prompt[index], include_type_flags, negate_type_flags)
        goto continue
      end

      if parsing_dir_flags == true then
        insert_flags(split_prompt[index], include_dir_flags, negate_dir_flags)
        goto continue
      end

      ::continue::
      index = index + 1
    end


    local include_flag = construct_flag(include_dir_flags, include_type_flags, false)
    local negate_flag = construct_flag(negate_dir_flags, negate_type_flags, true)


    local cmd = vim.iter { tbl_clone(vimgrep_arguments), include_flag, negate_flag, text, }:flatten():totable()
    print(dump(vim.iter { text, include_flag, negate_flag, }:flatten():totable()))

    return cmd
  end

  pickers
      .new(setup_opts, {
        prompt_title = "Live Grep (Formatted Args)",
        finder = finders.new_job(cmd_generator, entry_maker),
        previewer = conf.grep_previewer(setup_opts),
        sorter = sorters.highlighter_only(setup_opts),
      })
      :find()
end

return telescope.register_extension {
  setup = function(ext_config)
    for k, v in pairs(ext_config) do
      setup_opts[k] = v
    end
  end,
  exports = {
    live_grep_with_formatted_args = live_grep_with_formatted_args,
  },
}
