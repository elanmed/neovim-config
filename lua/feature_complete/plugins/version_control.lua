local h = require "helpers"
local marks = require "marks"
local ns_id = vim.api.nvim_create_namespace "homegrown-diff"

vim.keymap.set("n", "<C-b>", function()
  local curr_cursor = vim.api.nvim_win_get_cursor(0)
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local curr_bufname = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(curr_bufnr))

  local curr_filetype = vim.bo.filetype
  local new_lines = vim.api.nvim_buf_get_lines(curr_bufnr, 0, -1, false)

  vim.cmd.tabnew()
  local old_bufnr = vim.api.nvim_create_buf(false, true)
  local new_bufnr = vim.api.nvim_create_buf(false, true)
  local old_winnr = vim.api.nvim_tabpage_get_win(0)

  vim.api.nvim_set_current_buf(old_bufnr)
  local new_winnr = vim.api.nvim_open_win(new_bufnr, true, {
    split = "right",
    win = 0,
  })

  vim.system({ "git", "show", "HEAD:" .. curr_bufname, }, {}, function(out)
    local stdout = (function()
      if out.code ~= 0 then return "" end
      if out.stdout == nil then return "" end
      return out.stdout
    end)()
    local old_lines = vim.split(stdout, "\n")

    local start_time = os.clock()
    local diff = require "lcs-diff".diff(old_lines, new_lines)
    local end_time = os.clock()
    vim.schedule(function()
      h.notify.doing(("lcs-diff: %ss"):format((end_time - start_time) * 1000))
    end)

    local old_records = {}
    local new_records = {}

    for _, record in ipairs(diff) do
      if record.type == "=" then
        table.insert(old_records, record)
        table.insert(new_records, record)
      elseif record.type == "+" then
        table.insert(new_records, record)
      elseif record.type == "-" then
        table.insert(old_records, record)
      end
    end

    vim.schedule(function()
      local get_line_from_record = function(record)
        return record.line
      end

      vim.api.nvim_buf_set_lines(old_bufnr, 0, -1, false, vim.tbl_map(get_line_from_record, old_records))
      vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, vim.tbl_map(get_line_from_record, new_records))

      local apply_syntax_highlighting = function()
        local lang = vim.treesitter.language.get_lang(curr_filetype)
        vim.treesitter.start(0, lang)
      end

      vim.api.nvim_buf_call(old_bufnr, apply_syntax_highlighting)
      vim.api.nvim_buf_call(new_bufnr, apply_syntax_highlighting)

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
        -- TODO: not working
        vim.api.nvim_buf_call(opts.bufnr, marks.toggle_next_local_mark)
      end

      for idx_1i, record in ipairs(new_records) do
        highlight_line { bufnr = new_bufnr, idx_1i = idx_1i, record = record, }
      end

      for idx_1i, record in ipairs(old_records) do
        highlight_line { bufnr = old_bufnr, idx_1i = idx_1i, record = record, }
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
        buffer = old_bufnr,
        callback = function()
          sync_cursor { this_winnr = old_winnr, that_winnr = new_winnr, }
          vim.keymap.set("n", "<C-b>", "<nop>", { buffer = true, })
        end,
      })

      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = new_bufnr,
        callback = function()
          sync_cursor { this_winnr = new_winnr, that_winnr = old_winnr, }
          vim.keymap.set("n", "<C-b>", "<nop>", { buffer = true, })
        end,
      })

      vim.api.nvim_win_set_cursor(new_winnr, curr_cursor)
    end)
  end)
end)
