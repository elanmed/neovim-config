local ok, lightspeed = pcall(require, "lightspeed")
if not ok then
  return
end

lightspeed.setup({
  ignore_case = true,
})
