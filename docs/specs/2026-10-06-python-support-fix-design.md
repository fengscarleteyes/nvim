---
title: python 支持一致性修复
date: 2026-10-06
status: approved
---

# python 支持一致性修复: Design

## Problem

Python 支持在三处不一致。

mason.lua 把 `basedpyright` 列进 `ensure_installed`，但 mason 的 pypi
安装要在一个 venv 里跑真 python/pip，本机只有 Microsoft Store
的占位，装不成，于是每次启动都重试一次 `MasonInstall basedpyright`。basedpyright
实际由 `uv tool` 提供（`~/.local/bin`，在 Windows 用户 PATH 上），能正常解析。

conform.lua 同时用 `format_on_save` 和手写的 `BufWritePre` autocmd
做保存时格式化，同一次保存会各调一次。

conform 的 python 格式化器 `ruff_format, ruff_fix, ruff_organize_imports`
里，`ruff_organize_imports` 只跑 `ruff check --fix --select=I001`，是
`ruff_fix`（`ruff check --fix`，读 ruff.toml 且选了 I）的子集，冗余；且 fix 排在
format 之后，先格式化再改动，可能留下未格式化的结果。

## Goals

- `lua/plugins/mason.lua` 的 `ensure_installed` 不再含 `basedpyright`，启动后
  `:messages` 无 basedpyright 的安装尝试或失败。
- `docs/DEPENDENCIES.md` 含一条 basedpyright，安装命令为
  `uv tool install basedpyright`，且 panache lint 通过。
- `lua/plugins/conform.lua` 只剩一条保存时格式化路径，`formatters_by_ft.python`
  为 `{ "ruff_fix", "ruff_format" }`。
- 三个改动过的 Lua 文件经 `loadfile` 通过。

## Non-goals

- 不移除 mason，不动基于 basedpyright 之外的 mason 工具。
- 不把 `~/.local/bin` 加进 `vim.env.PATH`（用户选了做法 1，不做兜底）。
- 不改 `ruff.toml`（上一轮已定）。
- 不新增依赖，不新增 Python 源码。

## Constraints

- mason 保留，继续管 stylua、lua-language-server、panache、ruff。
- basedpyright 由 `uv tool install basedpyright` 提供，已在 `~/.local/bin`。
- 行尾 LF，Lua 走 stylua，Markdown 走 panache。

## Approach

mason.lua 删掉 `basedpyright` 那一行（注释掉的 `-- "ty"` 删除）。DEPENDENCIES.md
的 B 强烈建议补充 basedpyright：总览表一行，通用表一行
`uv add --dev basedpyright` `uv tool install basedpyright`。conform.lua 删掉末尾手写的 `BufWritePre` autocmd
块，保留 `format_on_save`。python 格式化器改为 `{ "ruff_fix", "ruff_format" }`。

pushback 判定"已是最小"。用户先选"只修 basedpyright"，追加了第 3、4 条（conform
重复格式化与 ruff 格式化器重叠），基座选做法 1。

## Alternatives considered

- 全删 mason 改外部装 5 个工具：Arch 官方库有
  stylua、lua-language-server、ruff，panache 走
  cargo，可行，但改动面大，用户选了保留 mason。
- 折中（Python 走 uv、Lua 与 Markdown 留 mason）：与本次做法等价，未单独实施。
- 做法的 PATH 兜底（做法 2）：用户选了做法 1，不做。
- 保留 basedpyright 在 mason.lua
  只修自动安装逻辑：仍留一个装不成的误导项，未选。

## Testing

- `nvim --headless -u NONE "+lua assert(loadfile('lua/plugins/mason.lua'))"`，conform.lua
  同法，期望退出码 0。
- `panache lint docs/DEPENDENCIES.md`，期望无 issue。
- 实测：启动 nvim 看 `:messages` 不再有 basedpyright 的安装尝试；打开 Python
  文件保存，确认只格式化一次且无报错。

## Open questions

N/A: 无未决问题，做法 1 与 2 的取舍已定为做法 1。
