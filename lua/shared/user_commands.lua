local h = require "shared.helpers"

vim.api.nvim_create_user_command("Far", function(opts)
  vim.cmd(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.cmd("cfdo update")
  vim.cmd("cfdo bdelete")
end, { nargs = "*" })

vim.api.nvim_create_user_command("PrintHighlights", function()
  vim.cmd("redir! > highlights.txt | silent hi | redir END")
end, {})

vim.api.nvim_create_user_command("PrintRemaps", function()
  local file = io.open("remaps.txt", "w")

  if not file then
    print("Error opening file!")
    return
  end

  for _, val in pairs(h.remaps) do
    file:write(val .. "\n")
  end

  file:close()
end, { nargs = "*" })

vim.api.nvim_create_user_command("WebSearch", function(opts)
  local query = opts.args:gsub(" ", "+")
  local url = "https://www.google.com/search?q=" .. query
  local open_cmd = h.is_mac() and "open" or "xdg-open"
  os.execute(open_cmd .. " '" .. url .. "' > /dev/null 2>&1 &")
end, { nargs = 1 })
