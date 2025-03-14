local pickers = require "telescope.pickers"
local sorters = require "telescope.sorters"
local telescope = require "telescope"
local conf = require "telescope.config".values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local action_state = require "telescope.actions.state"

-- TODO:
-- wait until space to process
-- accept case arguments

--- @param input table
--- @return string
local function dump(input)
  if type(input) == "table" then
    local str = "{ "
    for key, value in pairs(input) do
      if type(key) ~= "number" then key = '"' .. key .. '"' end
      str = str .. "[" .. key .. "] = " .. dump(value)
    end
    return str .. "} "
  else
    return tostring(input)
  end
end

--- @param input_str string
--- @return table
local function split(input_str)
  local tbl = {}
  for str in string.gmatch(input_str, "([^%s]+)") do
    table.insert(tbl, str)
  end
  return tbl
end

local function quote_prompt(prompt_bufnr)
  local function quote(value)
    local quoted = value:gsub('"', "\\" .. '"')
    return '"' .. quoted .. '"'
  end

  local picker = action_state.get_current_picker(prompt_bufnr)
  local trimmed_prompt = vim.trim(picker:_get_prompt())
  local quoted_prompt = quote(trimmed_prompt) .. " "
  picker:set_prompt(quoted_prompt)
end

--- @param opts { str: string, include_tbl: table, negate_tbl: table }
local function insert_flags(opts)
  local str, include_tbl, negate_tbl = opts.str, opts.include_tbl, opts.negate_tbl
  if str:sub(1, 1) == "!" then
    if #str == 1 then
      table.insert(negate_tbl, "")
    else
      table.insert(negate_tbl, str:sub(2))
    end
  else
    table.insert(include_tbl, str)
  end
end

--- @param opts { dir_tbl: table, type_tbl: table, negate: boolean }
local function construct_flag(opts)
  local dir_tbl, type_tbl, negate = opts.dir_tbl, opts.type_tbl, opts.negate
  local flag = ""
  if #dir_tbl > 0 then
    flag = flag .. "**/{" .. table.concat(dir_tbl, ",") .. "}/**"
  end

  if #type_tbl > 0 then
    if #dir_tbl > 0 then
      flag = flag .. "/"
    end
    flag = flag .. "*.{" .. table.concat(type_tbl, ",") .. "}"
  end

  if #flag > 0 then
    if negate then
      flag = "!" .. flag
    end
    return { "-g", flag, }
  end

  return {}
end

local setup_opts = {
  auto_quoting = true,
}

local live_grep_with_formatted_args = function()
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
        insert_flags { str = split_prompt[index], include_tbl = include_type_flags, negate_tbl = negate_type_flags, }
        goto continue
      end

      if parsing_dir_flags == true then
        insert_flags { str = split_prompt[index], include_tbl = include_dir_flags, negate_tbl = negate_dir_flags, }
        goto continue
      end

      ::continue::
      index = index + 1
    end


    local include_flag = construct_flag { negate = false, dir_tbl = include_dir_flags, type_tbl = include_type_flags, }
    local negate_flag = construct_flag { negate = true, dir_tbl = negate_dir_flags, type_tbl = negate_type_flags, }


    local cmd = vim.iter { conf.vimgrep_arguments, include_flag, negate_flag, text, }:flatten():totable()
    local minified_cmd = vim.iter { "rg", text, include_flag, negate_flag, }:flatten():totable()
    vim.notify(table.concat(minified_cmd, " "), vim.log.levels.DEBUG)

    return cmd
  end

  pickers
      .new(setup_opts, {
        prompt_title = "Live Grep (Formatted Args)",
        finder = finders.new_job(cmd_generator, entry_maker),
        previewer = conf.grep_previewer(setup_opts),
        sorter = sorters.highlighter_only(setup_opts),
        attach_mappings = function(_, map)
          map("i", "<C-k>", quote_prompt)
          return true
        end,
      })
      :find()
end

-- live_grep_with_formatted_args()

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
