local function active_mode_01()
  local layers = require("layers")
  local mode_1 = layers.mode.new()
  mode_1:auto_show_help()
  mode_1:keymaps({
    n = {
      {
        "j",
        function()
          local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
          local last_line = vim.api.nvim_buf_line_count(0)
          if cursor_line ~= last_line then
            vim.cmd([[move +1]])
          end
        end,
        { desc = "j move line down +1" },
      },
      {
        "k",
        function()
          vim.cmd([[move -2]])
        end,
        { desc = "k move line up" },
      },
      {
        "<esc>",
        function()
          mode_1:deactivate()
        end,
        { desc = "exit" },
      },
    },
  })
  mode_1:activate()
end

return {
  "debugloop/layers.nvim",
  opts = {}, -- see :help Layers.config
  keys = {
    {
      "<A-m>",
      active_mode_01,
      mode = "n",
      desc = "mode 01",
    },
  },
}
-- https://github.com/debugloop/layers.nvim
-- ahttps://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md
-- asd
--   asdasd
--
--   fdsf
