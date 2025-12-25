vim.api.nvim_create_user_command("PrintHighlights", function()
  vim.cmd "redir! > highlights.txt | silent hi | redir END"
end, {})

vim.api.nvim_create_user_command("PrintRemaps", function()
  vim.cmd "redir! > remaps.txt | silent map | redir END"
end, {})

vim.api.nvim_create_user_command("PackUpdate", function() vim.pack.update() end, {})
vim.api.nvim_create_user_command("Res", function()
  vim.cmd "mksession! Session.vim | restart source Session.vim"
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
  vim.cmd("keepalt -1read " .. snippet_file)
  vim.cmd.normal { snippet_trigger_to_file_mapping[snippet_trigger].movement, bang = true, }
end, { nargs = "*", })

-- https://github.com/neovim/neovim/issues/35303
-- assumes nothing lazy-loaded
vim.api.nvim_create_user_command("PackClean", function()
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
    require "helpers".notify.doing "No unused plugins"
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end, {})
