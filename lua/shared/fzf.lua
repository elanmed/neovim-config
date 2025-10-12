local h = require "helpers"

local M = {}

--- @class FzfOpts
--- @field source string|table
--- @field options? table
--- @field sink? fun(entry: string)
--- @field sinklist? fun(entry:string[])
--- @field height "full"|"half"

--- @param opts FzfOpts
M.fzf = function(opts)
  opts.options = opts.options or {}

  local sink_temp = vim.fn.tempname()
  local source_temp = vim.fn.tempname()
  vim.fn.writefile({}, sink_temp)

  local editor_height = vim.o.lines - 1
  local border_height = 2

  local term_bufnr = vim.api.nvim_create_buf(false, false)
  local term_winnr = vim.api.nvim_open_win(term_bufnr, true, {
    relative = "editor",
    row = editor_height,
    col = 0,
    width = vim.o.columns,
    height = opts.height == "full"
        and editor_height - border_height
        or math.floor(editor_height * 0.5 - border_height),
    border = "rounded",
    title = "FZF term",
  })

  local source = (function()
    if type(opts.source) == "string" then
      return opts.source
    else
      vim.fn.writefile(opts.source, source_temp)
      return ([[cat %s]]):format(source_temp)
    end
  end)()

  local cmd = ("%s | fzf %s > %s"):format(source, table.concat(opts.options, " "), sink_temp)
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      vim.api.nvim_win_close(term_winnr, true)
      local sink_content = vim.fn.readfile(sink_temp)
      if #sink_content == 0 then return end

      if opts.sink then
        opts.sink(sink_content[1])
      elseif opts.sinklist then
        opts.sinklist(sink_content)
      end

      vim.fn.delete(sink_temp)
      vim.fn.delete(source_temp)
    end,
  })
  vim.cmd "startinsert"
end

local guicursor = vim.opt.guicursor:get()
-- :h cursor-blinking
table.insert(guicursor, "a:blinkon0")
vim.opt.guicursor = guicursor

M.default_opts = {
  "--cycle",
  [[--preview-window='up:40%']],
  [[--bind='ctrl-d:preview-page-down']],
  [[--bind='ctrl-u:preview-page-up']],
  [[--header-border='rounded']],
}

M.multi_select_opts = {
  "--multi",
  [[--bind='ctrl-a:toggle-all']],
  [[--bind='tab:select+up']],
  [[--bind='shift-tab:down+deselect']],
}

M.single_select_opts = {
  [[--bind='tab:up']],
  [[--bind='shift-tab:down']],
}

M.qf_preview_opts = {
  [[--delimiter='|']],
  [[--preview='bat --style=numbers --color=always {1} --highlight-line {2}']],
  [[--preview-window='+{2}/3']],
}

local function maybe_close_tree()
  if vim.bo.filetype == "tree" then
    vim.cmd "close"
  end
end

--- @param script_name "get_marks"|"delete_mark"|"get_cmd_history"|"get_qf_list"|"get_qf_stack"|"get_buffers"|"get_lines"|"delete_buffer"
local function get_fzf_script(script_name)
  local lua_script = vim.fs.joinpath(vim.fn.stdpath "config", "fzf_scripts", "%s.lua"):format(script_name)
  return table.concat(
    { "nvim", "--clean", "-u", "NONE", "--headless", "-l", lua_script, vim.v.servername, },
    " ")
end

vim.keymap.set("n", "<leader>zm", function()
  maybe_close_tree()

  local source = get_fzf_script "get_marks"
  local delete_mark_source = get_fzf_script "delete_mark"

  local marks_opts_tbl = {
    [[--delimiter='|']],
    ([[--bind='ctrl-x:execute(%s {1})+reload(%s)']]):format(delete_mark_source, source),
    [[--ghost='Marks']],
  }

  M.fzf {
    height = "half",
    source = source,
    options = h.tbl.extend(marks_opts_tbl, M.default_opts, M.multi_select_opts),
    sinklist = function(entries)
      for _, entry in ipairs(entries) do
        local _, filename = unpack(vim.split(entry, "|"))
        vim.cmd("edit " .. filename)
      end
    end,
  }
end)

vim.keymap.set("n", "<leader>b", function()
  maybe_close_tree()

  local source = get_fzf_script "get_buffers"
  local delete_buf_source = get_fzf_script "delete_buffer"
  local bufs_opts_tbl = {
    [[--delimiter='|']],
    [[--ghost='Buffers']],
    ([[--bind='ctrl-x:execute(%s {1})+reload(%s)']]):format(delete_buf_source, source),
  }


  M.fzf {
    height = "half",
    source = source,
    options = h.tbl.extend(bufs_opts_tbl, M.default_opts, M.single_select_opts),
    sink = function(entry)
      vim.cmd("edit " .. vim.split(entry, "|")[2])
    end,
  }
end)

vim.keymap.set("n", "<leader>z;", function()
  maybe_close_tree()

  local cmd_history_opts_tbl = {
    [[--ghost='Command history']],
  }

  local source = {}
  local num_cmd_history = vim.fn.histnr "cmd"
  for i = 1, math.min(num_cmd_history, 15) do
    local item = vim.fn.histget("cmd", i * -1)
    if item == "" then goto continue end
    table.insert(source, item)

    ::continue::
  end

  M.fzf {
    source = source,
    options = h.tbl.extend(cmd_history_opts_tbl, M.default_opts, M.single_select_opts),
    height = "half",
    sink = function(selected)
      vim.api.nvim_feedkeys(":" .. selected, "n", false)
    end,
  }
end)

vim.keymap.set("n", "<leader>i", function()
  maybe_close_tree()

  local diff_opts_tbl = {
    [[--preview='git diff --color=always {} | tail -n +5']],
  }

  M.fzf {
    source = "git diff --name-only HEAD",
    options = h.tbl.extend(diff_opts_tbl, M.default_opts, M.single_select_opts),
    height = "full",
    sink = function(entry) vim.cmd("edit " .. entry) end,
  }
end)

local function sinklist(list)
  if vim.tbl_count(list) == 1 then
    local split_entry = vim.split(list[1], "|")
    local filename = split_entry[1]
    local row_one_index = tonumber(split_entry[2])
    local col_one_index = tonumber(split_entry[3])
    local col_zero_index = col_one_index - 1
    vim.cmd("e " .. filename)
    vim.api.nvim_win_set_cursor(0, { row_one_index, col_zero_index, })
    return
  end

  local qf_list = vim.tbl_map(function(entry)
    local filename, row, col, text = unpack(vim.split(entry, "|"))
    return { filename = filename, lnum = row, col = col, text = text, }
  end, list)
  vim.fn.setqflist(qf_list)
  vim.cmd "copen"
end

-- https://junegunn.github.io/fzf/tips/ripgrep-integration/
local function rg_with_globs(default_query)
  default_query = default_query or ""
  default_query = [[']] .. default_query .. [[']]

  local header =
  [['-e by *.[ext] | -f by file | -d by **/[dir]/** | -c by case sensitive | -nc by case insensitive | -w by whole word | -nw by partial word']]

  local rg_with_globs_script = vim.fs.joinpath(vim.fn.stdpath "config", "fzf_scripts", "rg-with-globs.sh")
  local rg_options = {
    "--query", default_query,
    "--disabled",
    [[--ghost='Rg']],
    "--header", header,
    "--bind", ("'start:reload:%s {q} || true'"):format(rg_with_globs_script),
    "--bind", ("'change:reload:%s {q} || true'"):format(rg_with_globs_script),
  }

  M.fzf {
    source = rg_with_globs_script,
    options = h.tbl.extend(rg_options, M.default_opts, M.multi_select_opts, M.qf_preview_opts),
    height = "full",
    sinklist = sinklist,
  }
end

vim.keymap.set("n", "<leader>a", function()
  maybe_close_tree()
  rg_with_globs ""
end)

vim.keymap.set("n", "<leader>zf", function()
  vim.cmd "cclose"
  local source = get_fzf_script "get_qf_list"
  local quickfix_list_opts = { [[--ghost='Qf list']], }
  M.fzf {
    source = source,
    options = h.tbl.extend(quickfix_list_opts, M.default_opts, M.multi_select_opts, M.qf_preview_opts),
    height = "full",
    sinklist = sinklist,
  }
end)

vim.keymap.set("n", "<leader>zs", function()
  vim.cmd "cclose"
  local source = get_fzf_script "get_qf_stack"
  local quickfix_list_opts = { [[--ghost='Qf stack']], }
  M.fzf {
    source = source,
    options = h.tbl.extend(quickfix_list_opts, M.default_opts, M.single_select_opts),
    height = "half",
    sink = function(entry)
      local qf_id = vim.split(entry, "|")[1]
      vim.cmd("chistory " .. qf_id)
      vim.cmd "copen"
    end,
  }
end)

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

  M.fzf {
    source = source,
    height = "half",
    options = h.tbl.extend(slash_opts, M.default_opts, M.single_select_opts),
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
end)

vim.keymap.set("n", "<leader>zr", function()
  maybe_close_tree()

  local prev_rg_query_file = vim.fs.joinpath(vim.fn.stdpath "config", "fzf_scripts", "prev-rg-query.txt")
  --- @type table
  local prev_rg_query = vim.fn.readfile(prev_rg_query_file)
  rg_with_globs(prev_rg_query[1])
end)

vim.keymap.set("v", "<leader>o", function()
  local region = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".")
  if #region > 0 then
    rg_with_globs(region[1] .. " -- ")
  end
end, { desc = "Grep the current word", })

vim.keymap.set("n", "<leader>o", function()
  rg_with_globs(vim.fn.expand "<cword>" .. " -- ")
end, { desc = "Grep the current visual selection", })

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local start_idx = filepath:find "wf_modules"
  if not start_idx then
    h.notify.error "`wf_modules` not found in the filepath!"
    return nil
  end
  local stripped_start = filepath:sub(start_idx)
  local dot_idx = stripped_start:find "%." -- % escapes
  if dot_idx then
    stripped_start = stripped_start:sub(1, dot_idx - 1)
  end

  return stripped_start
end

vim.keymap.set("n", "<leader>zw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  rg_with_globs(stripped_filename .. " -- ")
end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>yw", function()
  local stripped_filename = get_stripped_filename()
  if stripped_filename == nil then return end

  vim.fn.setreg("+", stripped_filename)
end, { desc = "Yank a file name starting with `wf_modules`", })

--- @generic T
--- @param items T[]
--- @param opts vim.ui.select.Opts
--- @param on_choice fun(item: T?, idx: integer?)
local function fzf_ui_select(items, opts, on_choice)
  opts.prompt = h.utils.default(opts.prompt, "")
  opts.format_item = h.utils.default(opts.format_item, function(item) return item end)
  local select_opts = {
    [[--ghost='Select']],
    [[--delimiter='|']],
    [[--with-nth='2']],
    ([[--header='%s']]):format(opts.prompt),
  }
  local formatted_items = h.tbl.map(function(item, index)
    return ("%s|%s"):format(index, opts.format_item(item))
  end, items)

  M.fzf {
    source = formatted_items,
    height = "half",
    options = h.tbl.extend(select_opts, M.default_opts, M.single_select_opts),
    sink = function(entry)
      local index = tonumber(vim.split(entry, "|")[1])
      on_choice(items[tonumber(index)], tonumber(index))
    end,
  }
end

vim.ui.select = fzf_ui_select

return M
