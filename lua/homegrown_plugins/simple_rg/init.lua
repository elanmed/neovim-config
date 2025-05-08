local M = {}

--- @param input_str string
--- @return table
local function split(input_str)
  local tbl = {}
  for str in input_str:gmatch "([^%s]+)" do
    table.insert(tbl, str)
  end
  return tbl
end

--- @param tbl table
--- @return table
local function flatten(tbl)
  return vim.iter(tbl):flatten():totable()
end

--- @param opts { str: string, include_tbl: table, negate_tbl: table }
local function record_custom_flag(opts)
  local str, include_tbl, negate_tbl = opts.str, opts.include_tbl, opts.negate_tbl
  if str:sub(1, 1) == "!" then
    if #str > 1 then
      table.insert(negate_tbl, str:sub(2))
    end
  else
    table.insert(include_tbl, str)
  end
end

--- @param opts { dir_tbl: table, file_tbl: table, negate: boolean }
local function construct_rg_flag(opts)
  local dir_tbl, file_tbl, negate = opts.dir_tbl, opts.file_tbl, opts.negate
  local flag = ""
  if #dir_tbl > 0 then
    flag = flag .. "'**/{" .. table.concat(dir_tbl, ",") .. "}/**"
    if #file_tbl == 0 then
      flag = flag .. "'"
    end
  end

  if #file_tbl > 0 then
    if #dir_tbl == 0 then
      flag = flag .. "'"
    end
    flag = flag .. "/{" .. table.concat(file_tbl, ",") .. "}'"
  end

  if #flag > 0 then
    if negate then
      flag = "!" .. flag
    end

    return "-g " .. flag
  end

  return ""
end

--- @param prompt string
local function parse_search(prompt)
  local search = ""
  local search_index = 1
  while search_index < (#prompt + 1) do
    if search_index == 1 then
      goto continue
    end

    if prompt:sub(search_index, search_index) == "~" then
      break
    end

    search = search .. prompt:sub(search_index, search_index)

    ::continue::
    search_index = search_index + 1
  end

  return { search = "'" .. search .. "'", search_index = search_index, }
end

M.construct_simple_rg = function(prompt)
  if not prompt or prompt == "" then
    return nil
  end

  local parsing_file_flags = false
  local parsing_dir_flags = false

  local include_file_flags = {}
  local negate_file_flags = {}
  local include_dir_flags = {}
  local negate_dir_flags = {}
  local case_sensitive_flag = { "--ignore-case", }
  local whole_word_flag = { nil, }

  local parsed_search = parse_search(prompt)
  local search, search_index = parsed_search.search, parsed_search.search_index

  local flags_prompt = prompt:sub(search_index + 1)
  local split_flags_prompt = split(flags_prompt)

  local flags_index = 1
  while flags_index < (#split_flags_prompt + 1) do
    local flag_token = split_flags_prompt[flags_index]

    local is_last_char_space = flags_prompt:sub(#flags_prompt, #flags_prompt) == " "
    if flags_index == #split_flags_prompt and not is_last_char_space then
      -- avoid updating the rg command
      return nil
    end

    if flag_token == "-c" then
      case_sensitive_flag = { "--case-sensitive", }
      goto continue
    end

    if flag_token == "-nc" then
      case_sensitive_flag = { "--ignore-case", }
      goto continue
    end

    if flag_token == "-w" then
      whole_word_flag = { "--word-regexp", }
      goto continue
    end

    if flag_token == "-nw" then
      whole_word_flag = { nil, }
      goto continue
    end

    if flag_token == "-f" then
      parsing_file_flags = true
      parsing_dir_flags = false
      goto continue
    end

    if flag_token == "-d" then
      parsing_dir_flags = true
      parsing_file_flags = false
      goto continue
    end

    if parsing_file_flags == true then
      record_custom_flag { str = flag_token, include_tbl = include_file_flags, negate_tbl = negate_file_flags, }
      goto continue
    end

    if parsing_dir_flags == true then
      record_custom_flag { str = flag_token, include_tbl = include_dir_flags, negate_tbl = negate_dir_flags, }
      goto continue
    end

    ::continue::
    flags_index = flags_index + 1
  end


  local include_flag = construct_rg_flag { negate = false, dir_tbl = include_dir_flags, file_tbl = include_file_flags, }
  local negate_flag = construct_rg_flag { negate = true, dir_tbl = negate_dir_flags, file_tbl = negate_file_flags, }

  local cmd = flatten {
    "rg",
    "--line-number", "--column", "--no-heading", -- formatting for fzf-lua
    "--hidden",
    "--color=always",
    case_sensitive_flag, whole_word_flag, search, include_flag, negate_flag,
  }

  return table.concat(cmd, " ")
end

return M
