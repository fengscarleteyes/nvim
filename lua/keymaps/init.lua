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
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set(
    keymap[1], -- mode
    keymap[2], -- key lhs
    keymap[3], -- handler rhs
    keymap[4] -- opts
  )
end

-- "<C-e>",     mode = { "i" }, function() require("fittencode").dismiss_suggestions()    end, desc = "Fittencode dismiss suggestions"    },
-- "<C-Right>", mode = { "i" }, function() require("fittencode").accept_word()            end, desc = "Fittencode accept word"            },
-- "<C-Down>",  mode = { "i" }, function() require("fittencode").accept_line()            end, desc = "Fittencode accept libe"            },
-- "<C-Left>",  mode = { "i" }, function() require("fittencode").revoke_word()            end, desc = "Fittencode revoke word"            },
-- "<C-Up>",    mode = { "i" }, function() require("fittencode").revoke_line()            end, desc = "Fittencode revoke libe"            },

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
