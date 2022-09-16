local ok, diffview = pcall(require, "diffview")
if not ok then
  return
end

diffview.setup({
  file_panel = {
    win_config = {
      position = "bottom",
      height = 10,
    },
  },
})
