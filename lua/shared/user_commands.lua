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

vim.api.nvim_create_user_command("Format", function()
  if vim.bo.readonly or vim.bo.buftype ~= "" then
    return vim.notify("Aborting", vim.log.levels.ERROR)
  end

  local view = vim.fn.winsaveview()
  vim.cmd "keepjumps normal! gg=G"
  vim.fn.winrestview(view)
  vim.cmd.write { mods = { silent = true, }, }
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
    vim.notify("No unused plugins", vim.log.levels.INFO)
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end, {})

--- @class QfItem
--- @field bufnr number
--- @field lnum number
--- @field col number
--- @field text string
--- @field user_data { eslint: boolean }

--- @param user_data any
local filter_user_data = function(user_data)
  local curr_qf_items = vim.fn.getqflist()
  local filtered_qf_items = vim.iter(curr_qf_items):filter(
  --- @param qf_item QfItem
    function(qf_item)
      return vim.tbl_get(qf_item, "user_data", user_data) ~= true
    end):totable()
  vim.fn.setqflist(filtered_qf_items, "r")
end

local scheduled_notify = vim.schedule_wrap(vim.notify)

vim.api.nvim_create_user_command("Eslint", require "helpers".async(function()
  --- @param cmd string[]
  --- @return Promise
  local vim_system = function(cmd)
    return function(resolve)
      vim.system(cmd, function(out) resolve(out) end)
    end
  end

  local h = require "helpers"
  --- @type vim.SystemCompleted
  local out = h.await(vim_system { "npx", "eslint", "--format", "json", vim.api.nvim_buf_get_name(0), })
  if out.code == 0 then
    scheduled_notify(("[tsc] non-zero exit code: %s\nstdout: %s\nstderr: %s"):format(out.code, out.stdout, out.stderr),
      vim.log.levels.WARN)
  end
  local stdout = vim.json.decode(out.stdout)

  --- @type QfItem[]
  local qf_items = {}

  for _, entry in ipairs(stdout) do
    local filePath = entry.filePath
    for _, message in ipairs(entry.messages) do
      --- @type QfItem
      local item = {
        bufnr = 0,
        filename = filePath,
        col = message.column,
        lnum = message.line,
        text = message.message,
        user_data = { eslint = true, },
      }
      table.insert(qf_items, item)
    end
  end

  if #qf_items == 0 then
    vim.notify("No Eslint errors reported", vim.log.levels.INFO)
    return
  end

  vim.schedule(function()
    filter_user_data "eslint"
    vim.fn.setqflist(qf_items, "a")
    vim.cmd.copen()
  end)
end), {})

vim.api.nvim_create_user_command("Tsc", require "helpers".async(function()
  --- @param cmd string[]
  --- @return Promise
  local vim_system = function(cmd)
    return function(resolve)
      vim.system(cmd, function(out) resolve(out) end)
    end
  end

  local h = require "helpers"
  --- @type vim.SystemCompleted
  local out = h.await(vim_system { "npx", "tsc", "--noEmit", "--pretty", "false", vim.api.nvim_buf_get_name(0), })
  if out.code ~= 0 then
    scheduled_notify(("[tsc] non-zero exit code: %s\nstdout: %s\nstderr: %s"):format(out.code, out.stdout, out.stderr),
      vim.log.levels.WARN)
    return
  end
  local stdout = vim.split(out.stdout, "\n", { trimempty = true, })

  --- @type QfItem[]
  local qf_items = {}

  for _, line in ipairs(stdout) do
    -- index.ts(2,7): error TS2322: Type 'number' is not assignable to type 'string'.
    --
    -- ^([^(]+)   capture filename (everything up to but not including '(')
    -- %((%d+)    capture row number after literal '('
    -- ,(%d+)     capture column number after literal ','
    -- %)         literal ')'
    -- :%s*       literal ':' followed by optional whitespace
    -- (.*)$      capture the rest of the line as the error message
    local filename, lnum, col, text = line:match "^([^(]+)%((%d+),(%d+)%):%s*(.*)$"

    --- @type QfItem
    local item = {
      bufnr = 0,
      filename = filename,
      col = col,
      lnum = lnum,
      text = text,
      user_data = { tsc = true, },
    }
    table.insert(qf_items, item)
  end

  if #qf_items == 0 then
    vim.notify("No Tsc errors reported", vim.log.levels.INFO)
    return
  end

  vim.schedule(function()
    filter_user_data "tsc"
    vim.fn.setqflist(qf_items, "a")
    vim.cmd.copen()
  end)
end), {})

