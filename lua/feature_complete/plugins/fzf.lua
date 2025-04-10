local h = require "shared.helpers"
local grug = require "grug-far"

-- https://github.com/ibhagwan/fzf-lua/wiki#how-do-i-get-maximum-performance-out-of-fzf-lua
local fzf_lua = require "fzf-lua"
fzf_lua.setup {
  winopts = {
    preview = { default = "bat_native", },
  },
  files = {
    hidden = false,
    git_icons = false,
    file_icons = false,
  },
  fzf_opts = {
    ["--layout"] = "reverse-list",
  },
}

local with_preview_opts = {
  winopts = {
    width   = 1,
    height  = 1,
    preview = {
      layout   = "vertical",
      vertical = "up:35%",
    },
  },
}

local function with_preview_cb(cb)
  return function() cb(with_preview_opts) end
end

local function without_preview_cb(cb)
  local without_preview_opts = {
    previewer = false,
    winopts = {
      width  = 1,
      height = 0.5,
      row    = 1,
    },
  }
  return function() cb(without_preview_opts) end
end


h.keys.map("n", "<C-p>", with_preview_cb(fzf_lua.files), { desc = "Find files with telescope", })
h.keys.map("n", "<leader>lr", fzf_lua.resume, { desc = "Resume fzf-lua search", })
h.keys.map("n", "<leader>lh", with_preview_cb(fzf_lua.helptags), { desc = "Search help tags with telescope", })
h.keys.map("n", "<leader>l;", without_preview_cb(fzf_lua.command_history),
  { desc = "Search search history with telescope", })
h.keys.map("n", "<leader>lu", with_preview_cb(fzf_lua.buffers),
  { desc = "Search currently open buffers with telescope", })
h.keys.map("n", "<leader>lf", with_preview_cb(fzf_lua.grep_curbuf),
  { desc = "Search in the current buffer with telescope", })
h.keys.map("n", "<leader>lg",
  function()
    fzf_lua.grep(vim.tbl_extend("force", with_preview_opts, { search = "", }))
  end,
  { desc = "Live grep the entire project", })

--- @param input_str string
--- @return table
local function split(input_str)
  local tbl = {}
  for str in string.gmatch(input_str, "([^%s]+)") do
    table.insert(tbl, str)
  end
  return tbl
end

--- @param opts { str: string, include_tbl: table, negate_tbl: table }
local function insert_flags(opts)
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
local function construct_flag(opts)
  local dir_tbl, file_tbl, negate = opts.dir_tbl, opts.file_tbl, opts.negate
  local flag = ""
  if #dir_tbl > 0 then
    flag = flag .. "'**/{" .. table.concat(dir_tbl, ",") .. "}/**"
    if #file_tbl == 0 then
      flag = flag .. "'"
    end
  end

  if #file_tbl > 0 then
    if #dir_tbl > 0 then
      flag = flag .. "/"
    else
      flag = flag .. "'"
    end
    flag = flag .. "*{" .. table.concat(file_tbl, ",") .. "}'"
  end

  if #flag > 0 then
    if negate then
      flag = "!" .. flag
    end
    return { "-g", flag, }
  end

  return {}
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

local cmd_generator = function(prompt)
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
      insert_flags { str = flag_token, include_tbl = include_file_flags, negate_tbl = negate_file_flags, }
      goto continue
    end

    if parsing_dir_flags == true then
      insert_flags { str = flag_token, include_tbl = include_dir_flags, negate_tbl = negate_dir_flags, }
      goto continue
    end

    ::continue::
    flags_index = flags_index + 1
  end


  local include_flag = construct_flag { negate = false, dir_tbl = include_dir_flags, file_tbl = include_file_flags, }
  local negate_flag = construct_flag { negate = true, dir_tbl = negate_dir_flags, file_tbl = negate_file_flags, }

  local function flatten(tbl)
    return vim.iter(tbl):flatten():totable()
  end

  local cmd = flatten { "rg", "--column", "--color=always", case_sensitive_flag, whole_word_flag, search, include_flag, negate_flag, }

  return table.concat(cmd, " ")
end

local function live_grep_with_args(opts)
  -- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#example-1-live-ripgrep
  opts = vim.tbl_extend("force", opts or {}, with_preview_opts)
  opts.git_icons = false
  opts.file_icons = false
  opts.actions = fzf_lua.defaults.actions.files
  opts.previewer = "bat_native"
  opts.search = "~"
  opts.fn_transform = function(x)
    return fzf_lua.make_entry.file(x, opts)
  end


  return fzf_lua.fzf_live(function(prompt)
    local cmd = cmd_generator(prompt or "")
    if cmd then h.notify.info(cmd) end
    return cmd
  end, opts)
end

h.keys.map("n", "<leader>la", function() live_grep_with_args { query = "~", } end)

h.keys.map("v", "<leader>lo",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    live_grep_with_args { query = "~" .. visual_selection .. "~ ", }
  end, { desc = "Grep the current word", })

h.keys.map({ "n", }, "<leader>lo",
  function() live_grep_with_args { query = "~" .. vim.fn.expand "<cword>" .. "~ ", } end,
  { desc = "Grep the current visual selection", })
