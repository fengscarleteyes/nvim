local wk = require("which-key")

wk.add(require("keymaps.leader_a"))
wk.add(require("keymaps.leader_b"))
wk.add(require("keymaps.leader_f"))
wk.add(require("keymaps.leader_g"))
wk.add(require("keymaps.leader_j"))
wk.add(require("keymaps.leader_l"))
wk.add(require("keymaps.leader_n"))
wk.add(require("keymaps.leader_r"))
wk.add(require("keymaps.leader_s"))
wk.add(require("keymaps.leader_t"))
wk.add(require("keymaps.leader_y"))

wk.add(require("keymaps.no_leader"))

return { "<leader>", group = "leader keys" }
