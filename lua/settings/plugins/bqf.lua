local ok, bqf = pcall(require, "bqf")
if not ok then
  return
end

bqf.setup({
  auto_resize_height = true,
  func_map = {
    openc = '<cr>',
  },
})
