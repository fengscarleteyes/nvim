---
title: ruff 标准配置
date: 2026-10-06
status: approved
---

# ruff 标准配置: Design

## Problem

仓库根目录没有 ruff 配置。ruff 0.16.10 已由 Mason 安装并接入 nvim-lint（python =
ruff），但没有配置文件时只跑 ruff 默认最小集（E4/E7/E9/F），导入排序、常见 bug
检查、现代语法升级都不生效，格式化也没有统一标准。

## Goals

- 根目录新增 `ruff.toml`，`ruff check --config ruff.toml` 只报 E/F/I/UP/B/SIM
  六族内、且不在 ignore 清单里的规则。
- 六个规则族和四条 ignore 各带一行中文注释，说明用途。
- 一份未格式化的样例文件经 `ruff format --config ruff.toml` 后，再跑
  `ruff format --check` 返回 0（幂等）。
- `ruff check --config ruff.toml` 对该样例只报预期规则，不报
  E111/E114/E117/E501。

## Non-goals

- 接入 conform 的 ruff_format（已在外部修改）。
- 不开 preview、不加 per-file-ignores、不加 isort 定制。
- 不新增 Python 源码，nvim-lint、mason 的现有配置已在外部修改。

## Constraints

- ruff 0.16.10。
- 行宽 88、双引号、target-version py315，均来自用户确认。
- py315 会让 ruff 每次输出"3.15 开发中"警告，用户已接受。

## Approach

单一扁平
`ruff.toml`，三个区：顶层（target-version、line-length）、`[lint]`（select
六族、 ignore 四条）、`[format]`（quote-style
双引号，其余默认）。注释按族写，pushback 时用户选择按族、否决逐条。ignore 四条取
ruff 官方 formatter 兼容清单的 E111/E114/E117 加 E501。

## Alternatives considered

- 逐条规则注释：注释量超过配置本身，随版本漂移，否决。
- 在 pyproject.toml 加 `[tool.ruff]`：与 uv 依赖同文件，但单独复用要手拆，否决。
- ignore 留空的最省做法：违背已确认的"少量 ignore"，否决。
- 更全做法（isort 定制 + per-file-ignores + preview）：维护成本高，否决。

## Testing

- `ruff check --config ruff.toml` 跑样例，确认报 I001/F401 等预期规则，不报
  E111/E114/E117/E501。
- `ruff format` 后 `ruff format --check` 返回 0。
- 仓库自身无 Python 源码时，`ruff check --config ruff.toml` 不因缺文件报错。
- panache lint 通过。

## Open questions

N/A: 无未决问题，py315 警告已由用户确认接受。
