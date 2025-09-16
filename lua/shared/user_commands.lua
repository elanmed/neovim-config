vim.api.nvim_create_user_command("PrintHighlights", function()
  vim.cmd "redir! > highlights.txt | silent hi | redir END"
end, {})

vim.api.nvim_create_user_command("PrintRemaps", function()
  vim.cmd "redir! > remaps.txt | silent map | redir END"
end, {})

vim.api.nvim_create_user_command("Snippet", function(opts)
  local snippet_trigger_to_file_mapping = {
    bef = { file = "before.ts", movement = "ji\t", },
    des = { file = "describe.ts", movement = 'f"l', },
    fin = { file = "findBy.ts", movement = "f;", },
    its = { file = "it.ts", movement = 'f"l', },
    ndoc = { file = "notToBeInTheDocument.ts", movement = "f)", },
    doc = { file = "toBeInTheDocument.ts", movement = "f)", },
    cal = { file = "useCallback.ts", movement = "ji\t", },
    eff = { file = "useEffect.ts", movement = "ji\t", },
    mem = { file = "useMemo.ts", movement = "ji\t", },
    wai = { file = "waitFor.ts", movement = "f>f)", },
  }

  local snippet_trigger = opts.fargs[1]

  if snippet_trigger == nil then
    print "Available snippet triggers:"
    for trigger in pairs(snippet_trigger_to_file_mapping) do
      print(trigger)
    end
    return
  end

  local snippet_triggers = vim.tbl_keys(snippet_trigger_to_file_mapping)
  if not vim.tbl_contains(snippet_triggers, snippet_trigger) then
    vim.notify(snippet_trigger .. " is not a valid snippet trigger!", vim.log.levels.ERROR)
    return
  end

  local snippets_path = vim.fs.joinpath(vim.fn.stdpath "config", "snippets")
  local snippet_file = vim.fs.joinpath(snippets_path, snippet_trigger_to_file_mapping[snippet_trigger].file)
  vim.cmd("-1read " .. snippet_file)
  vim.cmd("normal! " .. snippet_trigger_to_file_mapping[snippet_trigger].movement)
end, { nargs = "*", })

-- https://github.com/neovim/neovim/issues/35303
-- assumes nothing lazy-loaded
vim.api.nvim_create_user_command("PackClean", function()
  local h = require "helpers"
  local active_plugins = {}
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    active_plugins[plugin.spec.name] = plugin.active
  end

  for _, plugin in ipairs(vim.pack.get()) do
    if not active_plugins[plugin.spec.name] then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    h.notify.doing "No unused plugins"
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end, {})

vim.api.nvim_create_user_command("Tree", function(opts)
  if #opts.fargs > 1 then
    require "helpers".notify.error "Tree requires zero or one arg!"
    return
  end

  local dir_up = (function()
    if #opts.fargs == 0 then
      return 0
    end
    return tonumber(opts.fargs[1])
  end)()

  local curr_bufnr = vim.api.nvim_get_current_buf()
  local abs_bufname = vim.api.nvim_buf_get_name(curr_bufnr)
  local dirname = vim.fs.dirname(abs_bufname)
  local tree_cwd = vim.fs.normalize(vim.fs.joinpath(dirname, ("../"):rep(dir_up)))
  if tree_cwd == vim.fn.getcwd() then
    return
  end

  local obj = vim.system({ "tree", "-J", "-f", "-a", }, { cwd = tree_cwd, }):wait()
  if not obj.stdout then return end
  local tree_json = vim.json.decode(obj.stdout)

  local curr_bufnr_line = 0
  local lines = {}

  local function indent_lines(json, indent)
    local indent_chars = ("  "):rep(indent)

    if json.type == "file" then
      local tree_cwd_rel_json_name = vim.fs.normalize(json.name)

      local vim_rel_cwd = vim.fs.relpath(vim.fn.getcwd(), tree_cwd)
      local formatted = vim.fs.joinpath(vim_rel_cwd, tree_cwd_rel_json_name)
      table.insert(lines, indent_chars .. formatted)

      local abs_json_name = vim.fs.joinpath(tree_cwd, tree_cwd_rel_json_name)
      if abs_json_name == abs_bufname then
        curr_bufnr_line = #lines
      end
    elseif json.type == "directory" then
      table.insert(lines, indent_chars .. vim.fs.basename(vim.fs.normalize(json.name)) .. "/")
      if not json.contents then return end
      for _, file_json in ipairs(json.contents) do
        indent_lines(file_json, indent + 1)
      end
    end
  end

  indent_lines(tree_json[1], 0)

  local max_line_width = 0
  for _, line in ipairs(lines) do
    max_line_width = math.max(max_line_width, #line)
  end

  local results_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = results_bufnr, })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = results_bufnr, })
  vim.api.nvim_set_option_value("buflisted", false, { buf = results_bufnr, })

  local border_height = 2
  local winnr = vim.api.nvim_open_win(results_bufnr, true, {
    relative = "editor",
    row = 1,
    col = 0,
    width = math.min(vim.o.columns, max_line_width + 2),
    height = math.min(vim.o.lines - 1 - border_height, #lines),
    border = "rounded",
    style = "minimal",
    title = "Tree",
  })
  vim.api.nvim_set_option_value("foldmethod", "indent", { win = winnr, })

  vim.api.nvim_win_set_buf(winnr, results_bufnr)
  vim.api.nvim_buf_set_lines(results_bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(winnr, { curr_bufnr_line, 0, })
  vim.cmd "normal! ^"

  vim.keymap.set("n", "<cr>", function()
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_win_close(winnr, true)
    vim.cmd("edit " .. vim.trim(line))
  end, { buffer = results_bufnr, })

  vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(winnr, true) end, { buffer = results_bufnr, })
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(winnr, true) end, { buffer = results_bufnr, nowait = true, })
end, { nargs = "*", })
