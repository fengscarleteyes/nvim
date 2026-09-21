vim.pack.add({
  "https://github.com/williamboman/mason.nvim",
})

local opts = {
  ensure_installed = {
    "stylua", -- formater: lua
    "lua-language-server", -- lsp: lua
    "panache", -- lsp + formatter + linter: Markdown/Quarto/R Markdown
    -- "prettier", -- formater: Angular, CSS, Flow, GraphQL, HTML, JSON, JSX, JavaScript, LESS, Markdown, SCSS, TypeScript, Vue, YAML
    -- "pyright", -- python lsp
    -- "basedpyright", -- python lsp
    -- "ty", -- python type checker lsp
    -- "ruff", -- python linter & formater
    -- "taplo", -- toml lsp & formater
  },
}

require("mason").setup(opts)

-- :MasonUpdate 需要联网拉取 registry，离线/网络异常时会抛错。
-- 若直接调用，错误会经 require("plugins") 冒泡并中断 root init.lua，
-- 后面的 require("keymaps") 就不再执行（键位全丢）。这里把错误收在本地：只警告，不抛出。
local ok, err = pcall(vim.cmd, "MasonUpdate")
if not ok then
  vim.g.mason_update_error = tostring(err) -- 完整报错留在这里，便于 :lua print(vim.g.mason_update_error) 排查
  local reason = tostring(err):match("Failed to update registries[^\n]*") or tostring(err):match("^[^\n]*")
  vim.notify(
    "mason: MasonUpdate 失败，已跳过（不影响其它配置）：" .. (reason or ""),
    vim.log.levels.WARN
  )
end

local ms = require("mason-registry")

local function auto_install_tools(tool)
  if not ms.is_installed(tool) then
    if ms.has_package(tool) then
      vim.cmd([[MasonInstall ]] .. tool)
    else
      vim.notify("mason no search tool: " .. tool)
    end
  end
end

for _, tool in ipairs(opts.ensure_installed) do
  auto_install_tools(tool)
end
