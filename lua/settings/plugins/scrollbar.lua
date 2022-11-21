local ok, scrollbar = pcall(require, 'scrollbar')
if not ok then
  return
end

scrollbar.setup({
  handle = {
    --[[ TODO: use from vscode theme  ]]
    color = '#51504F'
  },
})
