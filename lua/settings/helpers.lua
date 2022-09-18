local function map(mode, shortcut, command, opts)
  vim.api.nvim_set_keymap(
    mode,
    shortcut,
    command,
    vim.tbl_extend("keep", opts or {}, { noremap = true, silent = true })
  ) -- silent prevents from populating the command bar
end

local function nmap(shortcut, command, opts)
  map("n", shortcut, command, opts)
end

local function imap(shortcut, command, opts)
  map("i", shortcut, command, opts)
end

local function vmap(shortcut, command, opts)
  map("v", shortcut, command, opts)
end

local function split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

local helpers = {
  set = vim.opt,
  let = vim.g,
  nmap = nmap,
  imap = imap,
  vmap = vmap,
  map = map,
  split = split,
}
return helpers
