local h = require "helpers"
local marks = require "marks"
local ns_id = vim.api.nvim_create_namespace "homegrown-diff"

vim.keymap.set("n", "<C-b>", function()
  local curr_cursor = vim.api.nvim_win_get_cursor(0)
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local curr_bufname = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(curr_bufnr))

  local curr_filetype = vim.bo.filetype
  local index_lines = vim.api.nvim_buf_get_lines(curr_bufnr, 0, -1, false)

  vim.cmd.tabnew()
  local head_winnr = vim.api.nvim_tabpage_get_win(0)
  local head_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(head_bufnr)

  local worktree_bufnr = vim.api.nvim_create_buf(false, true)
  local worktree_winnr = vim.api.nvim_open_win(worktree_bufnr, true, {
    split = "right",
    win = 0,
  })

  vim.system({ "git", "show", "HEAD:" .. curr_bufname, }, {}, function(out)
    local stdout = (function()
      if out.code ~= 0 then return "" end
      if out.stdout == nil then return "" end
      return out.stdout
    end)()
    local head_lines = vim.split(stdout, "\n")

    vim.schedule(function()
      local start_time = os.clock()
      local diff = h.utils.diff(head_lines, index_lines)
      local end_time = os.clock()
      h.notify.doing(("lcs-diff: %ss"):format((end_time - start_time) * 1000))

      local head_records = {}
      local worktree_records = {}

      for _, record in ipairs(diff) do
        if record.type == "=" then
          table.insert(head_records, record)
          table.insert(worktree_records, record)
        elseif record.type == "+" then
          table.insert(worktree_records, record)
        elseif record.type == "-" then
          table.insert(head_records, record)
        end
      end

      local get_line_from_record = function(record) return record.line end

      vim.api.nvim_buf_set_lines(head_bufnr, 0, -1, false, vim.tbl_map(get_line_from_record, head_records))
      vim.api.nvim_buf_set_lines(worktree_bufnr, 0, -1, false, vim.tbl_map(get_line_from_record, worktree_records))

      local apply_syntax_highlighting = function()
        local lang = vim.treesitter.language.get_lang(curr_filetype)
        vim.treesitter.start(0, lang)
      end

      vim.api.nvim_buf_call(head_bufnr, apply_syntax_highlighting)
      vim.api.nvim_buf_call(worktree_bufnr, apply_syntax_highlighting)

      --- @class HighlightLineOpts
      --- @field idx_1i number
      --- @field record { type: "+"|"-"|"=", line: string }
      --- @field bufnr number
      --- @param opts HighlightLineOpts
      local highlight_line = function(opts)
        if opts.record.type == "=" then return end

        local idx_0i = opts.idx_1i - 1
        local end_col_1i = #opts.record.line
        local end_col_0i = end_col_1i - 1

        vim.api.nvim_buf_set_extmark(opts.bufnr, ns_id, idx_0i, 0, {
          end_col = end_col_0i + 1,
          hl_group = opts.record.type == "+" and "DiffAdd" or "DiffDelete",
        })

        vim.api.nvim_buf_call(opts.bufnr, function()
          local letter = marks.get_next_avail_local_mark()
          vim.api.nvim_buf_set_mark(0, letter, opts.idx_1i, 0, {})
          marks.refresh_signs()
        end)
      end

      for idx_1i, record in ipairs(worktree_records) do
        highlight_line { bufnr = worktree_bufnr, idx_1i = idx_1i, record = record, }
      end

      for idx_1i, record in ipairs(head_records) do
        highlight_line { bufnr = head_bufnr, idx_1i = idx_1i, record = record, }
      end

      --- @class SyncCursorOpts
      --- @field this_winnr number
      --- @field that_winnr number
      --- @param opts SyncCursorOpts
      local sync_cursor = function(opts)
        local cursor = vim.api.nvim_win_get_cursor(opts.this_winnr)
        local ok = pcall(vim.api.nvim_win_set_cursor, opts.that_winnr, cursor)
        if ok then
          vim.api.nvim_win_call(opts.that_winnr, function()
            vim.cmd.normal { "zz", bang = true, }
          end)
        end
      end

      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = head_bufnr,
        callback = function()
          sync_cursor { this_winnr = head_winnr, that_winnr = worktree_winnr, }
        end,
      })

      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = worktree_bufnr,
        callback = function()
          sync_cursor { this_winnr = worktree_winnr, that_winnr = head_winnr, }
        end,
      })

      for _, bufnr in ipairs { worktree_bufnr, head_bufnr, } do
        vim.keymap.set("n", "<C-b>", vim.cmd.tabclose, { buffer = bufnr, })
        vim.keymap.set("n", "<C-^>", "<Nop>", { buffer = bufnr, })
        vim.keymap.set("n", "<C-o>", "<Nop>", { buffer = bufnr, })
        vim.keymap.set("n", "<C-i>", "<Nop>", { buffer = bufnr, })
        vim.keymap.set("n", "<leader>d", "<Nop>", { buffer = bufnr, })
      end

      pcall(vim.api.nvim_win_set_cursor, head_winnr, curr_cursor)
      vim.api.nvim_win_set_cursor(worktree_winnr, curr_cursor)

      vim.bo[worktree_bufnr].modifiable = false
      vim.bo[head_bufnr].modifiable = false

      vim.wo[worktree_winnr].winbar = "Worktree"
      vim.wo[head_winnr].winbar = "HEAD"
    end)
  end)
end)
