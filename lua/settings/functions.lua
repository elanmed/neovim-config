local h = require "shared.helpers"

-- function _G.sample_fn()
--   print("sample_fn")
-- end
-- h.nmap("", "v:lua.sample_fn()<cr>")

vim.api.nvim_create_user_command("FindAndReplace", function(opts)
  vim.api.nvim_command(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.api.nvim_command("cfdo update")
end, { nargs = "*" })

h.nmap("<leader>ie", ":FindAndReplace ", { silent = false })

local function gen_circular_next_prev(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    success, _ = pcall(vim.cmd, catch)
    if not success then
      return
    end
  end
end

vim.api.nvim_create_user_command('Cnext', function() gen_circular_next_prev("cnext", "cfirst") end, {})
vim.api.nvim_create_user_command('Cprev', function() gen_circular_next_prev("cprev", "clast") end, {})
vim.api.nvim_create_user_command('Lnext', function() gen_circular_next_prev("lnext", "lfirst") end, {})
vim.api.nvim_create_user_command('Lprev', function() gen_circular_next_prev("lprev", "llast") end, {})
