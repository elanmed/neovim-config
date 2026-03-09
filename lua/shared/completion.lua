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
