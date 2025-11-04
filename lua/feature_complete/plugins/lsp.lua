local h = require "helpers"

-- require "conform".setup {
--   formatters_by_ft = {
--     css = { "prettier", },
--     graphql = { "prettier", },
--     html = { "prettier", },
--     javascript = { "prettier", },
--     javascriptreact = { "prettier", },
--     json = { "prettier", },
--     less = { "prettier", },
--     markdown = { "prettier", },
--     scss = { "prettier", },
--     typescript = { "prettier", },
--     typescriptreact = { "prettier", },
--     yaml = { "prettier", },
--     java = {},
--     lua = { lsp_format = "fallback", },
--   },
--   format_after_save = {
--     async = true,
--   },
-- }

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local prettier_ft = {
      "css",
      "graphql",
      "html",
      "javascript",
      "javascriptreact",
      "json",
      "less",
      "markdown",
      "scss",
      "typescript",
      "typescriptreact",
      "yaml",
    }

    if vim.list_contains(prettier_ft, vim.bo.filetype) then
      vim.keymap.set("n", "<leader>w", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local unformatted = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local content = table.concat(unformatted, "\n")

        vim.system(
          { "npx", "prettier", "--stdin-filepath", bufname, },
          {
            stdin = content,
            text = true,
          },
          function(result)
            if result.code ~= 0 then
              vim.schedule(function() h.notify.error(result.stderr or "") end)
              return
            end

            if result.stdout == nil then
              vim.schedule(function() h.notify.error "prettier `result.stdout` is `nil`" end)
              return
            end

            local formatted = vim.split(result.stdout, "\n")

            local start_time = os.clock()
            local diff = require "lcs-diff".diff(unformatted, formatted)
            local end_time = os.clock()
            vim.print(("lcs-diff: %ss"):format((end_time - start_time) * 1000))

            vim.schedule(function()
              local linenr = 0

              for _, record in ipairs(diff) do
                if record.type == "-" then
                  vim.api.nvim_buf_set_lines(bufnr, linenr, linenr + 1, false, {})
                elseif record.type == "+" then
                  vim.api.nvim_buf_set_lines(bufnr, linenr, linenr, false, { record.line, })
                end

                if record.type == "=" or record.type == "+" then
                  linenr = linenr + 1
                end
              end
            end)
          end)
      end, { desc = "Format with prettier", })
    elseif vim.bo.filetype == "lua" then
      vim.keymap.set("n", "<leader>w", function()
        vim.lsp.buf.format { async = true, }
      end, { desc = "Format with lua ls", })
    else
      vim.keymap.set("n", "<leader>w", function()
        if vim.bo.readonly then
          h.notify.error "Buffer is readonly, aborting"
          return
        end
        if vim.bo.buftype ~= "" then
          h.notify.error "`buftype` is set, aborting"
          return
        end

        local view = vim.fn.winsaveview()
        vim.cmd.normal { "gg=G", bang = true, }
        vim.fn.winrestview(view)
        vim.cmd.write()
      end, { desc = "Format with vim formatting", })
    end
  end,
})
