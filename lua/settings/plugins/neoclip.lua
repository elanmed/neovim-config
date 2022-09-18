local ok, neoclip = pcall(require, "neoclip")
if not ok then
  return
end

-- TODO: figure out remaps
neoclip.setup()
