vim.keymap.set("i", "<C-x><C-o>", function()
  local function trigger_omni()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), "n", false)
  end
  local function trigger_fallback()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-n>", true, false, true), "n", false)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  if vim.tbl_isempty(vim.lsp.get_clients { bufnr = bufnr, }) then
    return trigger_fallback()
  end


  local timer_id
  timer_id = vim.fn.timer_start(500, function()
    timer_id = nil
    return trigger_fallback()
  end)

  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request_all(bufnr, "textDocument/completion", params, function(results)
    if timer_id == nil then return end
    vim.fn.timer_stop(timer_id)

    local has_results = false
    for _, response in pairs(results) do
      if response.result then
        has_results = true
        break
      end
    end

    if has_results then
      trigger_omni()
    else
      trigger_fallback()
    end
  end)
end, { desc = "Omnifunc with buffer lines backup", })

vim.api.nvim_create_autocmd("CompleteChanged", {
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
      local ok, win_data = pcall(vim.api.nvim__complete_set, info["selected"], { info = doc, })
      if not ok then return end
      if not vim.api.nvim_win_is_valid(win_data.winid) then
        return
      end
      vim.api.nvim_win_set_config(win_data.winid, { border = "rounded", })
      vim.treesitter.start(win_data.bufnr, "markdown")
      vim.wo[win_data.winid].conceallevel = 3
    end)
  end,
})
