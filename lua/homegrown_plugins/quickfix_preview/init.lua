local QuickfixPreview = require "homegrown_plugins.quickfix_preview.class"
local qf_preview = QuickfixPreview:new()

local M = {}

M.close = function()
  qf_preview:close()
end

M.refresh = function()
  qf_preview:refresh()
end

M.is_closed = function()
  qf_preview:is_closed()
end

--- @param is_disabled boolean
M.set_preview_disabled = function(is_disabled)
  qf_preview:set_preview_disabled(is_disabled)
end

--- @class QuickfixPreviewOpts
--- @field enable boolean Enable the plugin, defaults to `false`
--- @field keymaps QuickfixPreviewKeymaps Keymaps, defaults to none

--- @class QuickfixPreviewKeymaps
--- @field toggle string Toggle the preview

--- @param opts QuickfixPreviewOpts | nil
M.setup = function(opts)
  opts = opts or {}
  local keymaps = opts.keymaps or {}
  local enable = opts.enable or false
  if not enable then return end

  vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", }, {
    pattern = "*",
    callback = function()
      if vim.bo.filetype ~= "qf" then return end
      qf_preview:close()
    end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", }, {
    pattern = "*",
    callback = function()
      if vim.bo.filetype ~= "qf" then return end
      qf_preview:refresh()
    end,
  })

  vim.api.nvim_create_autocmd({ "FileType", }, {
    pattern = "*",
    callback = function()
      if vim.bo.filetype ~= "qf" then return end

      if keymaps.toggle then
        vim.keymap.set("n", keymaps.toggle, function()
          if qf_preview:is_closed() then
            qf_preview:open()
            qf_preview:set_preview_disabled(false)
          else
            qf_preview:close()
            qf_preview:set_preview_disabled(true)
          end
        end, { buffer = true, })
      end
    end,
  })
end

return M
