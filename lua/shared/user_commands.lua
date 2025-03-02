local h = require "shared.helpers"

vim.api.nvim_create_user_command("Far", function(opts)
  vim.cmd(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.cmd "cfdo update"
  vim.cmd "cfdo bdelete"
end, { nargs = "*", })

vim.api.nvim_create_user_command("PrintHighlights", function()
  vim.cmd "redir! > highlights.txt | silent hi | redir END"
end, {})

vim.api.nvim_create_user_command("PrintRemaps", function()
  local file = io.open("remaps.txt", "w")

  if not file then
    print "Error opening file!"
    return
  end

  for _, val in pairs(h.remaps) do
    file:write(val .. "\n")
  end

  file:close()
end, { nargs = "*", })

vim.api.nvim_create_user_command("WebSearch", function(opts)
  local query = opts.args:gsub(" ", "+")
  local url = "https://www.google.com/search?q=" .. query
  local open_cmd = h.os.is_linux() and "xdg-open" or "open"
  os.execute(open_cmd .. " '" .. url .. "' > /dev/null 2>&1 &")
end, { nargs = 1, })

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
    print(snippet_trigger .. " is not a valid snippet trigger!")
    return
  end

  local snippets_path = vim.fn.stdpath "config" .. "/snippets/"
  vim.cmd("-1read " .. snippets_path .. snippet_trigger_to_file_mapping[snippet_trigger].file)
  h.keys.send_keys("n", snippet_trigger_to_file_mapping[snippet_trigger].movement)
end, { nargs = "*", })
