-- https://github.com/iquzart/toggleword.nvim

return {
  "iquzart/toggleword.nvim",
  enabled = false, -- wait issue
  opts = {
    key = nil,
    toggle_groups = {
      { "start", "stop" },
      { "open", "close" },
      { "active", "inactive" },
      { "True", "False" },
    },
  },
}
