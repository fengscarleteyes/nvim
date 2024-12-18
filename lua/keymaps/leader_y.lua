--stylua: ignore start
return {
  { "<leader>y", group = "yank" },
  { "<leader>yt",      mode = { "n", "x" }, "<Cmd>Telescope yank_history<CR>",           desc = "Telescope yank_history",         noremap = true, silent = false },
  { "<leader>yp",      mode = { "n", "x" }, "<Plug>(YankyPutAfter)",                     desc = "YankyPutAfter",                  noremap = true, silent = false },
  { "<leader>yP",      mode = { "n", "x" }, "<Plug>(YankyPutBefore)",                    desc = "YankyPutBefore",                 noremap = true, silent = false },
  { "<leader>ygp",     mode = { "n", "x" }, "<Plug>(YankyGPutAfter)",                    desc = "YankyGPutAfter",                 noremap = true, silent = false },
  { "<leader>ygP",     mode = { "n", "x" }, "<Plug>(YankyGPutBefore)",                   desc = "YankyGPutBefore",                noremap = true, silent = false },
  { "<leader>yb",      mode = { "n",     }, "<Plug>(YankyPreviousEntry)",                desc = "YankyPreviousEntry",             noremap = true, silent = false },
  { "<leader>yf",      mode = { "n",     }, "<Plug>(YankyNextEntry)",                    desc = "YankyNextEntry",                 noremap = true, silent = false },
  { "<leader>y]P",     mode = { "n",     }, "<Plug>(YankyPutIndentAfterLinewise)",       desc = "YankyPutIndentAfterLinewise",    noremap = true, silent = false },
  { "<leader>y[P",     mode = { "n",     }, "<Plug>(YankyPutIndentBeforeLinewise)",      desc = "YankyPutIndentBeforeLinewise",   noremap = true, silent = false },
  { "<leader>y>p",     mode = { "n",     }, "<Plug>(YankyPutIndentAfterShiftRight)",     desc = "YankyPutIndentAfterShiftRight",  noremap = true, silent = false },
  { "<leader>y<p",     mode = { "n",     }, "<Plug>(YankyPutIndentAfterShiftLeft)",      desc = "YankyPutIndentAfterShiftLeft",   noremap = true, silent = false },
  { "<leader>y>P",     mode = { "n",     }, "<Plug>(YankyPutIndentBeforeShiftRight)",    desc = "YankyPutIndentBeforeShiftRight", noremap = true, silent = false },
  { "<leader>y<P",     mode = { "n",     }, "<Plug>(YankyPutIndentBeforeShiftLeft)",     desc = "YankyPutIndentBeforeShiftLeft",  noremap = true, silent = false },
  { "<leader>y=p",     mode = { "n",     }, "<Plug>(YankyPutAfterFilter)",               desc = "YankyPutAfterFilter",            noremap = true, silent = false },
  { "<leader>y=P",     mode = { "n",     }, "<Plug>(YankyPutBeforeFilter)",              desc = "YankyPutBeforeFilter",           noremap = true, silent = false },
  -- <Plug>(YankyPutAfter)
  -- <Plug>(YankyPutAfterBlockwise)
  -- <Plug>(YankyPutAfterBlockwiseJoined)
  -- <Plug>(YankyPutAfterCharwise)
  -- <Plug>(YankyPutAfterCharwiseJoined)
  -- <Plug>(YankyPutAfterFilter)
  -- <Plug>(YankyPutAfterFilterJoined)
  -- <Plug>(YankyPutAfterJoined)
  -- <Plug>(YankyPutAfterLinewise)
  -- <Plug>(YankyPutAfterLinewiseJoined)
  -- <Plug>(YankyPutAfterShiftLeft)
  -- <Plug>(YankyPutAfterShiftLeftJoined)
  -- <Plug>(YankyPutAfterShiftRight)
  -- <Plug>(YankyPutAfterShiftRightJoined)
  -- <Plug>(YankyPutBefore)
  -- <Plug>(YankyPutBeforeBlockwise)
  -- <Plug>(YankyPutBeforeBlockwiseJoined)
  -- <Plug>(YankyPutBeforeCharwise)
  -- <Plug>(YankyPutBeforeCharwiseJoined)
  -- <Plug>(YankyPutBeforeFilter)
  -- <Plug>(YankyPutBeforeFilterJoined)
  -- <Plug>(YankyPutBeforeJoined)
  -- <Plug>(YankyPutBeforeLinewise)
  -- <Plug>(YankyPutBeforeLinewiseJoined)
  -- <Plug>(YankyPutBeforeShiftLeft)
  -- <Plug>(YankyPutBeforeShiftLeftJoined)
  -- <Plug>(YankyPutBeforeShiftRight)
  -- <Plug>(YankyPutBeforeShiftRightJoined)
  -- <Plug>(YankyGPutAfter)
  -- <Plug>(YankyGPutAfterBlockwise)
  -- <Plug>(YankyGPutAfterBlockwiseJoined)
  -- <Plug>(YankyGPutAfterCharwise)
  -- <Plug>(YankyGPutAfterCharwiseJoined)
  -- <Plug>(YankyGPutAfterFilter)
  -- <Plug>(YankyGPutAfterFilterJoined)
  -- <Plug>(YankyGPutAfterJoined)
  -- <Plug>(YankyGPutAfterLinewise)
  -- <Plug>(YankyGPutAfterLinewiseJoined)
  -- <Plug>(YankyGPutAfterShiftLeft)
  -- <Plug>(YankyGPutAfterShiftLeftJoined)
  -- <Plug>(YankyGPutAfterShiftRight)
  -- <Plug>(YankyGPutAfterShiftRightJoined)
  -- <Plug>(YankyGPutBefore)
  -- <Plug>(YankyGPutBeforeBlockwise)
  -- <Plug>(YankyGPutBeforeBlockwiseJoined)
  -- <Plug>(YankyGPutBeforeCharwise)
  -- <Plug>(YankyGPutBeforeCharwiseJoined)
  -- <Plug>(YankyGPutBeforeFilter)
  -- <Plug>(YankyGPutBeforeFilterJoined)
  -- <Plug>(YankyGPutBeforeJoined)
  -- <Plug>(YankyGPutBeforeLinewise)
  -- <Plug>(YankyGPutBeforeLinewiseJoined)
  -- <Plug>(YankyGPutBeforeShiftLeft)
  -- <Plug>(YankyGPutBeforeShiftLeftJoined)
  -- <Plug>(YankyGPutBeforeShiftRight)
  -- <Plug>(YankyGPutBeforeShiftRightJoined)
  -- <Plug>(YankyPutIndentAfter)
  -- <Plug>(YankyPutIndentAfterBlockwise)
  -- <Plug>(YankyPutIndentAfterBlockwiseJoined)
  -- <Plug>(YankyPutIndentAfterCharwise)
  -- <Plug>(YankyPutIndentAfterCharwiseJoined)
  -- <Plug>(YankyPutIndentAfterFilter)
  -- <Plug>(YankyPutIndentAfterFilterJoined)
  -- <Plug>(YankyPutIndentAfterJoined)
  -- <Plug>(YankyPutIndentAfterLinewise)
  -- <Plug>(YankyPutIndentAfterLinewiseJoined)
  -- <Plug>(YankyPutIndentAfterShiftLeft)
  -- <Plug>(YankyPutIndentAfterShiftLeftJoined)
  -- <Plug>(YankyPutIndentAfterShiftRight)
  -- <Plug>(YankyPutIndentAfterShiftRightJoined)
  -- <Plug>(YankyPutIndentBefore)
  -- <Plug>(YankyPutIndentBeforeBlockwise)
  -- <Plug>(YankyPutIndentBeforeBlockwiseJoined)
  -- <Plug>(YankyPutIndentBeforeCharwise)
  -- <Plug>(YankyPutIndentBeforeCharwiseJoined)
  -- <Plug>(YankyPutIndentBeforeFilter)
  -- <Plug>(YankyPutIndentBeforeFilterJoined)
  -- <Plug>(YankyPutIndentBeforeJoined)
  -- <Plug>(YankyPutIndentBeforeLinewise)
  -- <Plug>(YankyPutIndentBeforeLinewiseJoined)
  -- <Plug>(YankyPutIndentBeforeShiftLeft)
  -- <Plug>(YankyPutIndentBeforeShiftLeftJoined)
  -- <Plug>(YankyPutIndentBeforeShiftRight)
  -- <Plug>(YankyPutIndentBeforeShiftRightJoined)
  }
-- stylua: ignore end
