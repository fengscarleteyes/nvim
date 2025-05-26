-- https://github.com/nvimdev/guard.nvim

-- defaults
vim.g.guard_config = {
  -- format on write to buffer
  fmt_on_save = true,
  -- use lsp if no formatter was defined for this filetype
  lsp_as_default_formatter = false,
  -- whether or not to save the buffer after formatting
  save_on_fmt = true,
  -- automatic linting
  auto_lint = true,
  -- how frequently can linters be called
  lint_interval = 500,
}

-- Guard fmt          -- Manually call format, also works with visual mode (best effort range formatting)
-- Guard lint         -- Manually request for lint
-- Guard enable-fmt   -- Turns auto formatting on for the current buffer
-- Guard disable-fmt  -- Turns auto formatting off for the current buffer
-- Guard enable-lint  -- Turns linting on for the current buffer
-- Guard disable-lint -- Turns linting off for the current buffer

return {
  "nvimdev/guard.nvim",
  enabled = false,
  config = function()
    -- local ft = require("guard.filetype")
    -- ft('python'):fmt('isort')
    --             :append('black')
    --             :lint('mypy')
    --             :append('mypyc')
    --             :append('dmypy')
  end,
}
