local h = require "shared.helpers"

require("aerial").setup()

h.nmap("zt", h.user_cmd_cb("AerialToggle left"), { desc = "Toggle aerial  window" })
h.nmap("zn", h.user_cmd_cb("AerialNext"), { desc = "Go to the next aerial symbol" })
h.nmap("zp", h.user_cmd_cb("AerialPrev"), { desc = "Go to the prev aerial symbol" })
