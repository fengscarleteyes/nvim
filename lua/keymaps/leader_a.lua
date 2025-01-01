---@module "snacks"

local f = require("fittencode")

-- stylua: ignore start
return {
  { "<leader>al", mode = { "n" }, function() f.login("fengscarleteyes", "Redeyes@19881218") end, desc = "Fittencode login"  },
}
-- stylua: ignore end
