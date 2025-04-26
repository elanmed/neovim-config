local h = require "shared.helpers"
local grug = require "grug-far"
local fzf_lua = require "fzf-lua"

local ignore_dirs = { "node_modules", ".git", "dist", }
local fd_cmd = "fd --type f"
for _, ignore_dir in pairs(ignore_dirs) do
  fd_cmd = fd_cmd .. " --exclude " .. ignore_dir
end

fzf_lua.setup {
  winopts = {
    preview = { default = "bat_native", },
  },
  files = {
    hidden = false,
    git_icons = false,
    file_icons = false,
    cmd = fd_cmd,
  },
  fzf_opts = {
    ["--layout"] = "reverse-list",
  },
  keymap = {
    builtin = { false, },
    fzf = {
      false,
      ["ctrl-a"] = "toggle-all",
      ["tab"] = "select+down",
      ["shift-tab"] = "up+deselect",
    },
  },
  actions = {
    files = {
      ["enter"] = fzf_lua.actions.file_edit_or_qf,
    },
  },
  marks = {
    marks = "%a",
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

vim.keymap.set("n", "<leader>lr", fzf_lua.resume, { desc = "Resume fzf-lua search", })
vim.keymap.set("n", "<leader>lh", with_preview_cb(fzf_lua.helptags), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>lm", with_preview_cb(fzf_lua.marks), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>l;", without_preview_cb(fzf_lua.command_history),
  { desc = "Search search history with fzf", })
vim.keymap.set("n", "<leader>lu", with_preview_cb(fzf_lua.buffers),
  { desc = "Search currently open buffers with fzf", })
vim.keymap.set("n", "<leader>lf", with_preview_cb(fzf_lua.grep_curbuf),
  { desc = "Search in the current buffer with fzf", })
vim.keymap.set("n", "<leader>lg",
  function()
    local opts = vim.tbl_deep_extend("error", { search = "", }, with_preview_opts)
    fzf_lua.grep(opts)
  end,
  { desc = "Live grep the entire project", })

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

-- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#example-1-live-ripgrep
--- @param initial_query string
local function live_grep_with_args(initial_query)
  local opts = vim.tbl_deep_extend("error", {}, with_preview_opts)
  opts.git_icons = false
  opts.file_icons = false
  opts.actions = fzf_lua.defaults.actions.files
  opts.previewer = "bat_native"
  opts.fn_transform = function(x)
    return fzf_lua.make_entry.file(x, opts)
  end
  opts.query = initial_query
  opts.fzf_opts = { ["--multi"] = true, }

  -- found in the live_grep implementation, necessary to preview the correct section w/bats
  -- fzf-lua/lua/fzf-lua/providers/grep.lua
  opts = fzf_lua.core.set_fzf_field_index(opts)

  return fzf_lua.fzf_live(function(prompt)
    local cmd = cmd_generator(prompt or "")
    if cmd then h.notify.doing(cmd) end
    return cmd
  end, opts)
end

vim.keymap.set("n", "<leader>la", function() live_grep_with_args "~" end)
vim.keymap.set("v", "<leader>lo",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    live_grep_with_args("~" .. visual_selection .. "~ ")
  end, { desc = "Grep the current word", })
vim.keymap.set({ "n", }, "<leader>lo",
  function()
    live_grep_with_args("~" .. vim.fn.expand "<cword>" .. "~ ")
  end, { desc = "Grep the current visual selection", })

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local stripped_start = filepath:match "wf_modules.*$"
  if not stripped_start then
    h.notify.warn "`wf_modules` not found in the filepath!"
    return nil
  end

  local stripped_filename = stripped_start:match "(.-)%..-$"
  return stripped_filename
end

vim.keymap.set("n", "<leader>le",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    live_grep_with_args("~" .. stripped_filename .. "~ ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>ye",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })
