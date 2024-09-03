local h = require "shared.helpers"

vim.api.nvim_create_user_command("FindAndReplace", function(opts)
  vim.cmd(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.cmd("cfdo update")
  vim.cmd("cfdo bdelete")
end, { nargs = "*" })

vim.api.nvim_create_user_command("PrintHighlights", function()
  vim.cmd(
    "enew | setlocal buftype=nofile | redir => m | silent hi | redir END | put=m")
end, {})

vim.api.nvim_create_user_command("PrintRemaps", function()
  print("Custom remaps:")
  for _, val in pairs(h.remaps) do
    print(val)
  end
end, { nargs = "*" })

vim.api.nvim_create_user_command("WebSearch", function(opts)
  local query = opts.args:gsub(" ", "+")
  local url = "https://www.google.com/search?q=" .. query
  os.execute("open '" .. url .. "' > /dev/null 2>&1 &")
end, { nargs = 1 })
