local function active_buf_mode()
  local layers = require("layers")
  local custom_buf_mode = layers.mode.new()
  custom_buf_mode:auto_show_help()
  custom_buf_mode:keymaps({
    n = {
      {
        "j",
        function()
          vim.cmd("<Cmd>CybuNext<CR>")
        end,
        { desc = "j buf next" },
      },
      {
        "k",
        function()
          vim.cmd("<Cmd>CybuPrev<CR>")
        end,
        { desc = "k buf prev" },
      },
      {
        "J",
        function()
          vim.cmd("<Cmd>CybuLastusedNext<CR>")
        end,
        { desc = "J buf last used next" },
      },
      {
        "K",
        function()
          vim.cmd("<Cmd>CybuLastusedPrev<CR>")
        end,
        { desc = "K buf last used prev" },
      },

      {
        "<esc>",
        function()
          custom_buf_mode:deactivate()
        end,
        { desc = "exit" },
      },
    },
  })
  custom_buf_mode:activate()
end

--stylua: ignore start
return {
  { "<leader>b", group = "Buffer" },
  { "<leader>bt", mode = { "n" }, "<Cmd>ASToggle<CR>",                  desc = "Toggle auto-save"            },
  { "<leader>bs", mode = { "n" }, ":lua Snacks.scratch()<CR>",          desc = "Snacks scaratch"             },
  { "<leader>bS", mode = { "n" }, ":lua Snacks.scratch.select()<CR>",   desc = "Snacks scaratch select"      },
  { "<leader>bb", mode = { "n" }, ":lua Snacks.bufdelete()<CR>",        desc = "Snacks delete Buffer"        },
  { "<leader>ba", mode = { "n" }, ":lua Snacks.bufdelete.all()<CR>",    desc = "Snacks delete Buffer All"    },
  { "<leader>bd", mode = { "n" }, ":lua Snacks.bufdelete.delete()<CR>", desc = "Snacks delete Buffer delete" },
  { "<leader>bo", mode = { "n" }, ":lua Snacks.bufdelete.other()<CR>",  desc = "Snacks delete Buffer other"  },
  { "<leader>b1", mode = { "n" }, "<Cmd>BufferGoto 1<CR>",              desc = "BarBar BufferGoto 1", noremap = true, silent = true },
  { "<leader>b2", mode = { "n" }, "<Cmd>BufferGoto 2<CR>",              desc = "BarBar BufferGoto 2", noremap = true, silent = true },
  { "<leader>b3", mode = { "n" }, "<Cmd>BufferGoto 3<CR>",              desc = "BarBar BufferGoto 3", noremap = true, silent = true },
  { "<leader>b4", mode = { "n" }, "<Cmd>BufferGoto 4<CR>",              desc = "BarBar BufferGoto 4", noremap = true, silent = true },
  { "<leader>b5", mode = { "n" }, "<Cmd>BufferGoto 5<CR>",              desc = "BarBar BufferGoto 5", noremap = true, silent = true },
  { "<leader>b6", mode = { "n" }, "<Cmd>BufferGoto 6<CR>",              desc = "BarBar BufferGoto 6", noremap = true, silent = true },
  { "<leader>b7", mode = { "n" }, "<Cmd>BufferGoto 7<CR>",              desc = "BarBar BufferGoto 7", noremap = true, silent = true },
  { "<leader>b8", mode = { "n" }, "<Cmd>BufferGoto 8<CR>",              desc = "BarBar BufferGoto 8", noremap = true, silent = true },
  { "<leader>b9", mode = { "n" }, "<Cmd>BufferGoto 9<CR>",              desc = "BarBar BufferGoto 9", noremap = true, silent = true },
  { "<leader>b0", mode = { "n" }, "<Cmd>BufferLast<CR>",                desc = "BarBar Buffer Last",  noremap = true, silent = true },
  { "<leader>bm", mode = { "n" }, active_buf_mode,                desc = "...",  noremap = true, silent = true },
  -- { "key", mode = 'n', '<A-,>',     '<Cmd>BufferPrevious<CR>',            desc = "BufferPrevious",            noremap = true, silend = true },
  -- { "key", mode = 'n', '<A-.>',     '<Cmd>BufferNext<CR>',                desc = "BufferNext",                noremap = true, silend = true },
  -- { "key", mode = 'n', '<A-<>',     '<Cmd>BufferMovePrevious<CR>',        desc = "BufferMovePrevious",        noremap = true, silend = true },
  -- { "key", mode = 'n', '<A->>',     '<Cmd>BufferMoveNext<CR>',            desc = "BufferMoveNext",            noremap = true, silend = true },
  -- { "key", mode = 'n', '<A-p>',     '<Cmd>BufferPin<CR>',                 desc = "BufferPin",                 noremap = true, silend = true },
  -- { "key", mode = 'n', '<A-c>',     '<Cmd>BufferClose<CR>',               desc = "BufferClose",               noremap = true, silend = true },
  -- { "key", mode = 'n', '<C-p>',     '<Cmd>BufferPick<CR>',                desc = "BufferPick",                noremap = true, silend = true },
  -- { "key", mode = 'n', '<C-s-p>'  , '<Cmd>BufferPickDelete<CR>',          desc = "BufferPickDelete",          noremap = true, silend = true },
  -- { "key", mode = 'n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', desc = "BufferOrderByBufferNumber", noremap = true, silend = true },
  -- { "key", mode = 'n', '<Space>bn', '<Cmd>BufferOrderByName<CR>',         desc = "BufferOrderByName",         noremap = true, silend = true },
  -- { "key", mode = 'n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>',    desc = "BufferOrderByDirectory",    noremap = true, silend = true },
  -- { "key", mode = 'n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>',     desc = "BufferOrderByLanguage",     noremap = true, silend = true },
  -- { "key", mode = 'n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', desc = "BufferOrderByWindowNumber", noremap = true, silend = true },
  }
-- stylua: ignore end
