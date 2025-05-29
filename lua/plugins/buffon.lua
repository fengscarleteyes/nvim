-- https://github.com/francescarpi/buffon.nvim

return {
  {
    "francescarpi/buffon.nvim",
    branch = "main",
    opts = {
      Cyclic_navigation = true,
      new_buffer_position = "start",
      open = {
        by_default = true,
        offset = {
          x = -1,
          y = 2,
        },
        ignore_ft = {
          "gitcommit",
          "gitrebase",
        },
        default_position = "top_right",
      },
      num_pages = 1,
      leader_key = ";",
      mapping_chars = "1234567890",
      keybindings = {
        goto_next_buffer = "", -- "<s-j>",
        goto_previous_buffer = "", -- "<s-k>",
        move_buffer_up = "", -- "<s-l>",
        move_buffer_down = "", -- "<s-h>",
        move_buffer_top = "", -- "<s-t>",
        move_buffer_bottom = "", -- "<s-b>",
        toggle_buffon_window = "<buffonleader>n",
        toggle_buffon_window_position = "<buffonleader>nn",
        switch_previous_used_buffer = "", -- "<buffonleader><buffonleader>",
        close_buffer = "<buffonleader>d",
        close_buffers_above = "", -- "<buffonleader>v",
        close_buffers_below = "", -- "<buffonleader>b",
        close_all_buffers = "<buffonleader>cc",
        close_others = "<buffonleader>cd",
        reopen_recent_closed_buffer = "", -- "<buffonleader>t",
        show_help = "<buffonleader>h",
        previous_page = "<buffonleader>z",
        next_page = "<buffonleader>x",
        move_to_previous_page = "<buffonleader>a",
        move_to_next_page = "<buffonleader>s",
      },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
  },
}
