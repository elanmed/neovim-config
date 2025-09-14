vim.opt.wildmode = "noselect"
vim.opt.wildoptions = "fuzzy"

local prev_cmdline = ""

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = ":",
  callback = function()
    prev_cmdline = ""
  end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    local curr_cmdline = vim.fn.getcmdline()
    local parse_cmd_ok, cmd_type = pcall(vim.api.nvim_parse_cmd, curr_cmdline, {})

    -- `feedkeys` inserts a literal ^Z when substituting, which triggers an infinite loop
    if parse_cmd_ok and cmd_type.cmd == "substitute" then
      prev_cmdline = curr_cmdline
      return
    end

    -- CmdlineChanged fires twice with the same value of getcmdline()
    -- first with the new getcmdline(), then a second time after `wildcharm` is invoked
    if curr_cmdline ~= prev_cmdline then
      -- alternatives:
      -- vim.fn.feedkeys("\26", "n")
      -- vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-Z>", true, false, true), "n")
      vim.cmd [[ call feedkeys("\<C-Z>", 'n') ]]
    end
    prev_cmdline = curr_cmdline
  end,
})

vim.keymap.set("c", "<C-e>", "<C-e><C-z>")
