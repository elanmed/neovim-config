local h = require "helpers"
local prev_state = {
  bare_cmd = nil,
  height = nil,
  sink = nil,
  sinklist = nil,
}

local prev_query_file = vim.fs.joinpath(vim.fn.stdpath "config", "fzf_scripts", "prev_query")
vim.fn.writefile({ "", }, prev_query_file)

--- @class FzfResumeOpts
--- @field is_replay? boolean

--- @class FzfNewOpts
--- @field source string|table|nil
--- @field options? table
--- @field sink? fun(entry: string)
--- @field sinklist? fun(entry:string[])
--- @field height "full"|"half"

--- @param opts FzfNewOpts | FzfResumeOpts
local fzf = function(opts)
  local editor_height = vim.o.lines - 1
  local border_height = 2

  local sink_temp = vim.fn.tempname()
  vim.fn.writefile({}, sink_temp)

  local height = (function()
    if opts.is_replay then
      return prev_state.height
    else
      prev_state.height = opts.height
      return opts.height
    end
  end)()

  local sink = (function()
    if opts.is_replay then
      return prev_state.sink
    end
    prev_state.sink = opts.sink
    return opts.sink
  end)()

  local sinklist = (function()
    if opts.is_replay then
      return prev_state.sinklist
    end
    prev_state.sinklist = opts.sinklist
    return opts.sinklist
  end)()

  local term_bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[term_bufnr].bufhidden = "delete"
  local term_winnr = vim.api.nvim_open_win(term_bufnr, true, {
    relative = "editor",
    row = editor_height,
    col = 0,
    width = vim.o.columns,
    height = height == "full"
        and editor_height - border_height
        or math.floor(editor_height * 0.5 - border_height),
    border = "single",
    title = "FZF term",
  })

  local bare_cmd = (function()
    if opts.is_replay then
      return prev_state.bare_cmd
    else
      local source = (function()
        if type(opts.source) == "string" then
          return opts.source
        elseif type(opts.source) == "table" then
          return ([[echo %s]]):format(vim.fn.shellescape(table.concat(opts.source, "\n")))
        elseif opts.source == nil then
          return nil
        end
      end)()

      local new_bare_cmd = ("fzf %s"):format(table.concat(opts.options or {}, " "))
      if opts.source then
        new_bare_cmd = source .. " | " .. new_bare_cmd
      end

      prev_state.bare_cmd = new_bare_cmd
      return new_bare_cmd
    end
  end)()

  if opts.is_replay then
    local prev_query = vim.fn.readfile(prev_query_file)[1]
    bare_cmd = table.concat({ bare_cmd, ("--query %s"):format(prev_query), }, " ")
  end

  local cmd_with_record_prev_query = table.concat({
    bare_cmd,
    ([['--bind=result:execute-silent(echo {q} > %s)']]):format(prev_query_file),
  }, " ")

  local cmd_with_sink = cmd_with_record_prev_query .. " > " .. sink_temp
  vim.fn.setreg("+", cmd_with_sink)

  vim.fn.jobstart(cmd_with_sink, {
    term = true,
    on_exit = function()
      vim.api.nvim_win_close(term_winnr, true)

      local sink_content = vim.fn.readfile(sink_temp)
      if #sink_content > 0 then
        if sink then
          sink(sink_content[1])
        elseif sinklist then
          sinklist(sink_content)
        end
      end

      vim.fn.delete(sink_temp)
    end,
  })
  vim.cmd.startinsert()
end

-- :h cursor-blinking
vim.opt.guicursor:append "a:blinkon0"

local default_opts = {
  "--cycle",
  [[--preview-window='up:40%']],
  [[--bind='ctrl-d:preview-page-down']],
  [[--bind='ctrl-u:preview-page-up']],
  [[--preview-border='sharp']],
  [[--header-border='sharp']],
}

local multi_select_opts = {
  "--multi",
  [[--bind='ctrl-a:toggle-all']],
  [[--bind='tab:select+up']],
  [[--bind='shift-tab:down+deselect']],
}

local qf_preview_opts = {
  [[--delimiter='|']],
  [[--preview='bat --style=numbers --color=always {1} --highlight-line {2}']],
  [[--preview-window='+{2}/3']],
}

--- @param script_name "get_marks"|"delete_mark"|"ex_cmd"|"get_qf_list"|"get_qf_stack"|"get_buffers"|"get_lines"|"delete_buffer"|'get_registers'
local function get_fzf_script(script_name)
  local lua_script = vim.fs.joinpath(
    vim.fn.stdpath "config",
    "fzf_scripts",
    ("%s.lua"):format(script_name)
  )

  return table.concat(
    { "nvim", "-i", "NONE", "--clean", "-u", "NONE", "--headless", "-l", lua_script, vim.v.servername, },
    " ")
end

--- @class QfSinklistOpts
--- @field get_filename fun(entry:string):string
--- @field get_qf_entry fun(entry:string):{ filename:string, lnum:number, col:number, text:string, }
--- @field get_cursor_pos? fun(entry:string):[integer, integer]
--- @param opts QfSinklistOpts
local build_sinklist = function(opts)
  return function(entries)
    if #entries == 1 then
      vim.cmd.edit(opts.get_filename(entries[1]))
      if opts.get_cursor_pos then
        vim.api.nvim_win_set_cursor(0, opts.get_cursor_pos(entries[1]))
      end
      return
    end

    local qf_list = vim.tbl_map(function(entry)
      return opts.get_qf_entry(entry)
    end, entries)

    vim.fn.setqflist(qf_list)
    vim.cmd.copen()
  end
end


vim.keymap.set("n", "<leader>l", function()
  local source = get_fzf_script "get_marks"
  local delete_mark_source = get_fzf_script "delete_mark"

  local marks_opts_tbl = {
    [[--delimiter='|']],
    ([[--bind='ctrl-x:execute(%s {1})+reload(%s)']]):format(delete_mark_source, source),
    [[--ghost=Marks]],
  }

  fzf {
    height = "half",
    source = source,
    options = h.tbl.extend(marks_opts_tbl, default_opts, multi_select_opts),
    sinklist = build_sinklist {
      get_filename = function(entry) return vim.split(entry, "|")[3] end,
      get_qf_entry = function(entry)
        local _, lnum, filename = unpack(vim.split(entry, "|"))
        return { filename = filename, lnum = lnum, col = 0, text = filename, }
      end,
      get_cursor_pos = function(entry) return { tonumber(vim.split(entry, "|")[2]), 0, } end,
    },
  }
end, { desc = "fzf global marks", })

vim.keymap.set("n", "<leader>b", function()
  local source = get_fzf_script "get_buffers"
  local delete_buf_source = get_fzf_script "delete_buffer"
  local bufs_opts_tbl = {
    [[--delimiter='|']],
    [[--ghost=Buffers]],
    ([[--bind='ctrl-x:execute(%s {1})+reload(%s)']]):format(delete_buf_source, source),
  }

  fzf {
    height = "half",
    source = source,
    options = h.tbl.extend(bufs_opts_tbl, default_opts, multi_select_opts),
    sinklist = build_sinklist {
      get_filename = function(entry) return vim.split(entry, "|")[2] end,
      get_qf_entry = function(entry)
        local _, filename = unpack(vim.split(entry, "|"))
        return { filename = filename, lnum = 1, col = 0, text = filename, }
      end,
    },
  }
end, { desc = "fzf buffers", })

vim.keymap.set("n", "<leader>zu", function()
  local source = get_fzf_script "get_registers"
  local registers_opts_tbl = { [[--ghost=Registers]], }

  fzf {
    height = "half",
    source = source,
    options = h.tbl.extend(registers_opts_tbl, default_opts),
    sink = function(entry)
      local reg = vim.split(entry, "|")[1]
      h.utils.set_unnamed_and_plus(vim.fn.getreg(reg))
    end,
  }
end, { desc = "fzf register", })

vim.keymap.set("n", "<leader>z;", function()
  local ex_cmd_source = get_fzf_script "ex_cmd"

  local cmd_history_opts_tbl = {
    [[--ghost='Command history']],
    ([[--bind='ctrl-e:execute(%s {1} %s %s)+close']]):format(
      ex_cmd_source,
      vim.api.nvim_get_current_win(),
      vim.api.nvim_get_current_buf()
    ),
  }

  local source = {}
  local num_cmd_history = vim.fn.histnr "cmd"
  for i = 1, math.min(num_cmd_history, 15) do
    local item = vim.fn.histget("cmd", i * -1)
    if item == "" then goto continue end
    table.insert(source, item)

    ::continue::
  end

  fzf {
    source = source,
    options = h.tbl.extend(cmd_history_opts_tbl, default_opts),
    height = "half",
    sink = function(selected)
      vim.api.nvim_feedkeys(":" .. selected, "n", false)
    end,
  }
end, { desc = "fzf command history", })

vim.keymap.set("n", "<leader>i", function()
  local diff_opts_tbl = {
    [[--preview='if git diff --color=always HEAD {2} 2>/dev/null | grep -q .; then git diff --color=always HEAD {2} | tail -n +5; else bat --style=numbers --color=always {2}; fi']],
    [[--with-nth='{2}']],
    [[--accept-nth='{2}']],
    [[--bind='ctrl-x:execute-silent(git restore --staged --worktree {2}; git clean -f {2})+reload(git status --short --untracked-files)']],
  }

  fzf {
    source = "git status --short --untracked-files",
    options = h.tbl.extend(diff_opts_tbl, default_opts, multi_select_opts),
    height = "full",
    sinklist = build_sinklist {
      get_filename = function(entry) return entry end,
      get_qf_entry = function(entry) return { lnum = 1, col = 0, filename = entry, } end,
    },
  }
end, { desc = "fzf git diff", })

local function ripgrep_sinklist(list)
  if vim.tbl_count(list) == 1 then
    local split_entry = vim.split(list[1], "|")
    local filename = split_entry[1]
    local row_one_index = tonumber(split_entry[2])
    local col_one_index = tonumber(split_entry[3])
    local col_zero_index = col_one_index - 1
    vim.cmd.edit(filename)
    vim.api.nvim_win_set_cursor(0, { row_one_index, col_zero_index, })
    return
  end

  local qf_list = vim.tbl_map(function(entry)
    local filename, row, col, text = unpack(vim.split(entry, "|"))
    return { filename = filename, lnum = row, col = col, text = text, }
  end, list)
  vim.fn.setqflist(qf_list)
  vim.cmd.copen()
end

-- https://junegunn.github.io/fzf/tips/ripgrep-integration/
local function rg_with_globs(default_query)
  local base_header =
  [['-i --ignore-case | -s --case-sensitive | -S --smart-case | -w --word-regexp | -F --fixed-strings | -g --glob= | -t --type= | -. --hidden']]

  local rg_with_globs_script = vim.fs.joinpath(vim.fn.stdpath "config", "fzf_scripts", "rg-with-globs.sh")

  local rg_options = {
    "--disabled",
    "--ghost", "Rg",
    "--header", base_header,
    ([[--bind="change:reload(%s {q} || true)+transform-header(echo %s\\\n%s)"]]):format(
      rg_with_globs_script,
      base_header,
      "rg --hidden {q}"
    ),
    ([[--bind="start:reload(%s {q} || true)"]]):format(rg_with_globs_script),
  }
  if default_query then
    table.insert(rg_options, "-q")
    table.insert(rg_options, default_query)
  end

  fzf {
    source = nil,
    options = h.tbl.extend(rg_options, default_opts, multi_select_opts, qf_preview_opts),
    height = "full",
    sinklist = ripgrep_sinklist,
  }
end

vim.keymap.set("n", "<leader>a", function()
  rg_with_globs()
end, { desc = "fzf rg with globs", })

vim.keymap.set("n", "<leader>zf", function()
  vim.cmd.cclose()
  local source = get_fzf_script "get_qf_list"
  local quickfix_list_opts = { [[--ghost='Qf list']], }
  fzf {
    source = source,
    options = h.tbl.extend(quickfix_list_opts, default_opts, multi_select_opts, qf_preview_opts),
    height = "full",
    sinklist = ripgrep_sinklist,
  }
end, { desc = "fzf current quickfix list", })

vim.keymap.set("n", "<leader>zs", function()
  vim.cmd.cclose()
  local source = get_fzf_script "get_qf_stack"
  local quickfix_list_opts = { [[--ghost='Qf stack']], }
  fzf {
    source = source,
    options = h.tbl.extend(quickfix_list_opts, default_opts),
    height = "half",
    sink = function(entry)
      local qf_id = vim.split(entry, "|")[1]
      vim.cmd.chistory(qf_id)
      vim.cmd.copen()
    end,
  }
end, { desc = "fzf quickfix stack", })

vim.keymap.set("n", "<leader>/z", function()
  local slash_opts = {
    [[--ghost='/']],
    [[--delimiter='|']],
    [[--print-query]],
  }

  local curr_bufnr = vim.api.nvim_get_current_buf()
  local source = table.concat({
    get_fzf_script "get_lines",
    curr_bufnr,
  }, " ")

  fzf {
    source = source,
    height = "half",
    options = h.tbl.extend(slash_opts, default_opts),
    sinklist = function(entry)
      local query = entry[1]
      if not entry[2] then
        return
      end
      local line_nr, filename = unpack(vim.split(entry[2], "|"))
      if #query == 0 then
        vim.api.nvim_win_set_cursor(0, { tonumber(line_nr), 0, })
        return
      end
      local _, positions = unpack(vim.fn.matchfuzzypos({ filename, }, query))
      if #positions == 0 then
        vim.api.nvim_win_set_cursor(0, { tonumber(line_nr), 0, })
        return
      end

      vim.api.nvim_win_set_cursor(0, { tonumber(line_nr), positions[1][1], })
    end,
  }
end, { desc = "fzf lines in the buf", })

vim.keymap.set("n", "<leader>zr", function()
  if prev_state.bare_cmd == nil then
    return h.notify.error "No previous fzf terminal buffer"
  end
  fzf { is_replay = true, }
end, { desc = "fzf replay", })

vim.keymap.set("v", "<leader>o", function()
  local region = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".")
  if #region > 0 then
    rg_with_globs(region[1])
  end
end, { desc = "fzf rg with globs", })

vim.keymap.set("n", "<leader>o", function()
  rg_with_globs(vim.fn.expand "<cword>")
end, { desc = "fzf rg with globs", })

local function get_stripped_filename()
  local abs_path = vim.api.nvim_buf_get_name(0)

  local start_idx = abs_path:find "wf_modules"
  if not start_idx then
    h.notify.error "`wf_modules` not found in the filepath!"
    return nil
  end
  local stripped_start = abs_path:sub(start_idx)
  local dot_idx = stripped_start:find "%." -- % escapes
  if dot_idx then
    stripped_start = stripped_start:sub(1, dot_idx - 1)
  end

  return stripped_start
end

vim.keymap.set("n", "<leader>zw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  rg_with_globs(stripped_filename)
end, { desc = "fzf rg with globs starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  h.utils.set_and_rotate(stripped_filename)
end, { desc = "Yank a file name starting with `wf_modules`", })

--- @generic T
--- @param items T[]
--- @param opts vim.ui.select.Opts
--- @param on_choice fun(item: T?, idx: integer?)
local function fzf_ui_select(items, opts, on_choice)
  opts.prompt = h.utils.if_nil(opts.prompt, "")
  opts.format_item = h.utils.if_nil(opts.format_item, function(item) return item end)
  local select_opts = {
    [[--ghost='Select']],
    [[--delimiter='|']],
    [[--with-nth='2']],
    ([[--header='%s']]):format(opts.prompt),
  }
  local formatted_items = h.tbl.map(function(item, index)
    return ("%s|%s"):format(index, opts.format_item(item))
  end, items)

  fzf {
    source = formatted_items,
    height = "half",
    options = h.tbl.extend(select_opts, default_opts),
    sink = function(entry)
      local index = tonumber(vim.split(entry, "|")[1])
      on_choice(items[tonumber(index)], tonumber(index))
    end,
  }
end

vim.ui.select = fzf_ui_select
