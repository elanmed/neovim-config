vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf, })
    if filetype == "tree" or filetype == "nvim-undotree" then return end
    vim.cmd "normal! zz"
  end,
  desc = "Center the screen on movement",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" then
      vim.api.nvim_set_option_value("buflisted", false, { buf = args.buf, })
    end
  end,
  desc = "Avoid listing unnamed buffers",
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})

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

      local lines = vim.lsp.util.convert_input_to_markdown_lines(doc)
      vim.lsp.util.open_floating_preview(lines, "markdown", {
        anchor_bias = "below",
        border = "rounded",
        width = pum_pos.width,
        max_height = pum_pos.height,
        offset_x = pum_pos.width - #item.word + 3,
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.keymap.set("i", "<Cr>", function()
      local current_line = vim.api.nvim_get_current_line()
      local patterns = {
        "%s*local%s+function%(%s*%)%s*",
        "%s*function%(%s*%)%s*",
        "%s+do%s*$",
        "%s+then%s*$",
      }
      local has_match = false
      for _, pattern in ipairs(patterns) do
        if current_line:match(pattern) then
          has_match = true
          break
        end
      end

      if not has_match then return "<Cr>" end
      if current_line:match "end%s*$" then return "<Cr>" end

      local indent = current_line:match "^%s*"
      vim.print(#indent)
      return "\r" .. "end<C-o>O"
    end, { expr = true, buffer = true, })
  end,
})
