local h = require "shared.helpers"

require("aerial").setup()

h.nmap("<leader>at", h.user_cmd_cb("AerialToggle left"))
h.nmap("zn", h.user_cmd_cb("AerialNext"))
h.nmap("zp", h.user_cmd_cb("AerialPrev"))
