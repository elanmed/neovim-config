local h = require "helpers"

--- @class PollOpts
--- @field limit number
--- @field interval number
--- @field on_limit fun():nil
--- @field on_interval fun(clear: fun():nil):nil
--- @param opts PollOpts
local poll = function(opts)
  local timer_id

  local clear = function()
    if timer_id == nil then return end
    vim.fn.timer_stop(timer_id)
  end

  local i = 0
  timer_id = vim.fn.timer_start(opts.interval, function()
    if i >= opts.limit then
      opts.on_limit()
      return clear()
    end

    i = i + 1
    opts.on_interval(clear)
  end, { ["repeat"] = opts.limit + 1, }) -- run + 1 iterations to call on_limit
end

vim.keymap.set("i", "<C-x><C-o>", function()
  --- @param keys string
  local feed_ctrl_keys = function(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  if vim.tbl_isempty(vim.lsp.get_clients { bufnr = bufnr, }) then
    return feed_ctrl_keys "<C-x><C-n>"
  end

  feed_ctrl_keys "<C-x><C-o>"
  poll {
    interval = 50,
    limit = 10,
    --- @param clear_interval fun():nil
    on_interval = function(clear_interval)
      local info = vim.fn.complete_info { "pum_visible", }
      if info.pum_visible == h.vimscript_true then
        clear_interval()
      end
    end,
    on_limit = function()
      feed_ctrl_keys "<C-x><C-n>"
    end,
  }
end, { desc = "Omnifunc with buffer lines backup", })

vim.api.nvim_create_autocmd("CompleteChanged", {
  group = vim.api.nvim_create_augroup("LspCompletionPopup", { clear = true, }),
  callback = function()
    local info = vim.fn.complete_info { "selected", "items", }
    if info.selected == -1 then return end
    local item = info.items[info.selected + 1]
    if not item then return end
    if not item.word then return end

    local completion_item = vim.tbl_get(item, "user_data", "nvim", "lsp", "completion_item")
    if not completion_item then return end

    local client_id = vim.tbl_get(item, "user_data", "nvim", "lsp", "client_id")
    if not client_id then return end

    local client = vim.lsp.get_client_by_id(client_id)
    if not client then return end

    local pum_pos = vim.fn.pum_getpos()
    if not pum_pos then return end

    client:request("completionItem/resolve", completion_item, function(err, result)
      if err then return end
      local doc = vim.tbl_get(result, "documentation", "value")
      if not doc then return end

      -- https://github.com/neovim/neovim/issues/29225
      local win_data = vim.api.nvim__complete_set(info["selected"], { info = doc, })
      if vim.tbl_count(win_data) == 0 then return end
      if not vim.api.nvim_win_is_valid(win_data.winid) then return end

      vim.api.nvim_win_set_config(win_data.winid, { border = "single", })
      vim.treesitter.start(win_data.bufnr, "markdown")
      vim.wo[win_data.winid].conceallevel = 3
    end)
  end,
})
