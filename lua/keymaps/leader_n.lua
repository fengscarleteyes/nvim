--stylua: ignore start
return {
    { "<leader>n", group = "Notification" }, -- group
    { "<leader>nn", mode = { "n" }, function() require("notify").dismiss()           end,   desc = "Hide notifications"         },
    { "<leader>nh", mode = { "n" }, function() require("notify.integrations").pick() end, desc = "show notifications history" },
    { "<leader>nc", mode = { "n" }, function() require("notify").clear_history()     end, desc = "show notifications history" },
  }
-- stylua: ignore end
