local h = require "shared.helpers"

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

  if not h.tbl.contains_key(snippet_trigger_to_file_mapping, snippet_trigger) then
    h.notify.error(snippet_trigger .. " is not a valid snippet trigger!")
    return
  end

  local snippets_path = vim.fn.stdpath "config" .. "/snippets/"
  vim.cmd("-1read " .. snippets_path .. snippet_trigger_to_file_mapping[snippet_trigger].file)
  h.keys.send_keys("n", snippet_trigger_to_file_mapping[snippet_trigger].movement)
end, { nargs = "*", })
