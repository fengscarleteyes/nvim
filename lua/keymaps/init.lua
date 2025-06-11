local keymaps = {
  {
    "n",
    "<leader>fe",
    "<cmd>Neotree filesystem toggle<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "Neotree", --映射的描述
    },
  },

  {
    "n",
    "<leader>ff",
    "<Cmd>FzfLua files<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua files", --映射的描述
    },
  },

  {
    "n",
    "<leader>fc",
    "<Cmd>FzfLua colorschemes<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua colorschemes", --映射的描述
    },
  },

  {
    "n",
    "<leader>fg",
    "<Cmd>FzfLua live_grep<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua live_grep", --映射的描述
    },
  },

  {
    "n",
    "<leader>fh",
    "<Cmd>FzfLua helptags<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua helptags", --映射的描述
    },
  },

  {
    "n",
    "<leader>fb",
    "<Cmd>FzfLua buffers<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua buffers", --映射的描述
    },
  },

  {
    "n",
    "<leader>fl",
    "<Cmd>FzfLua lines<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua lines", --映射的描述
    },
  },

  {
    "n",
    "<leader>ft",
    "<Cmd>FzfLua tabs<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua tabs", --映射的描述
    },
  },

  {
    "n",
    "<leader>fj",
    "<Cmd>FzfLua lgrep_curbuf<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua lgrep_curbuf", --映射的描述
    },
  },

  {
    "n",
    "<leader>fd",
    "<Cmd>FzfLua diagnostics_document<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua diagnostics_document", --映射的描述
    },
  },

  {
    "n",
    "<leader>fD",
    "<Cmd>FzfLua diagnostics_workspace<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua diagnostics_workspace", --映射的描述
    },
  },

  {
    "n",
    "<leader>fk",
    "<Cmd>FzfLua keymaps<CR>",
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "FzfLua keymaps", --映射的描述
    },
  },

  {
    "i",
    "<C-]>",
    function()
      require("fittencode").accept_all_suggestions()
    end,
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "Fittencode accept all suggestions", --映射的描述
    },
  },

  {
    "n",
    "<leader>nn",
    function()
      require("notify").dismiss({ pending = true, silent = true })
    end,
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "Hide notifications", --映射的描述
    },
  },

  {
    "n",
    "<leader>nh",
    function()
      require("notify.integrations").pick()
    end,
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "show notifications history", --映射的描述
    },
  },

  {
    "n",
    "<leader>nh",
    function()
      require("notify.integrations").pick()
    end,
    {
      noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
      silent = true, -- 是否静默执行（不显示命令）
      nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
      expr = false, -- 是否将 rhs 视为表达式（VimScript）
      desc = "show notifications history", --映射的描述
    },
  },

  -- TODO: add surround keymaps
  --   { "<leader>s", group = "Surround" },
  --   { "<leader>ss", mode = { "n" }, "<Plug>(nvim-surround-normal-cur)",      desc = "surround normal cur",      noremap = true, silent = false },
  --   { "<leader>sS", mode = { "n" }, "<Plug>(nvim-surround-normal)",          desc = "surround normal",          noremap = true, silent = false },
  --   { "<leader>sd", mode = { "n" }, "<Plug>(nvim-surround-delete)",          desc = "surround delete",          noremap = true, silent = false },
  --   { "<leader>sl", mode = { "n" }, "<Plug>(nvim-surround-normal-cur-line)", desc = "surround normal cur line", noremap = true, silent = false },
  --   { "<leader>sL", mode = { "n" }, "<Plug>(nvim-surround-normal-line)",     desc = "surround normal line",     noremap = true, silent = false },
  --   { "<leader>sr", mode = { "n" }, "<Plug>(nvim-surround-change)",          desc = "surround change",          noremap = true, silent = false },
  --   { "<leader>sR", mode = { "n" }, "<Plug>(nvim-surround-change-line)",     desc = "surround change line",     noremap = true, silent = false },
  --   { "<leader>sv", mode = { "x" }, "<Plug>(nvim-surround-visual-line)",     desc = "surround visual line",     noremap = true, silent = false },
  --   { "<leader>sV", mode = { "x" }, "<Plug>(nvim-surround-visual)",          desc = "surround visual",          noremap = true, silent = false },
  -- {
  --   "i",
  --   "<A-s>",
  --   "<Plug>(nvim-surround-insert)",
  --   {
  --     noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
  --     silent = true, -- 是否静默执行（不显示命令）
  --     nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
  --     expr = false, -- 是否将 rhs 视为表达式（VimScript）
  --     desc = "surround insert", --映射的描述
  --   },
  -- },

  -- {
  --   "i",
  --   "<A-S>",
  --   "<Plug>(nvim-surround-insert-line)",
  --   {
  --     noremap = true, -- 是否禁用递归映射（推荐设为 true，避免无限循环）
  --     silent = true, -- 是否静默执行（不显示命令）
  --     nowait = false, -- 是否立即应用映射，不等待可能的更长匹配
  --     expr = false, -- 是否将 rhs 视为表达式（VimScript）
  --     desc = "surround insert line", --映射的描述
  --   },
  -- },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set(
    keymap[1], -- mode
    keymap[2], -- key lhs
    keymap[3], -- handler rhs
    keymap[4] -- opts
  )
end

-- {
-- 	"n",
-- 	"<leader>se",
-- 	function() require("scissors").editSnippet() end,
-- 	{ desc = "Snippet: Edit" }
-- )

-- -- when used in visual mode, prefills the selection as snippet body
-- {
-- 	{ "n", "x" },
-- 	"<leader>sa",
-- 	function() require("scissors").addNewSnippet() end,
-- 	{ desc = "Snippet: Add" }
-- )
