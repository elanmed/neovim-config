local h = require "helpers"

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
