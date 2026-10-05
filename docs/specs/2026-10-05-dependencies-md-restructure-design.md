---
title: DEPENDENCIES.md 文档结构重排
date: 2026-10-05
status: approved
---

# DEPENDENCIES.md 文档结构重排: Design

## Problem

DEPENDENCIES.md 当前每个工具用四行粗体标签列表（功能、主页、Windows 安装、Linux 安装），其中 Linux 安装再嵌套 Arch / Ubuntu / Fedora / 通用 四层列表。层级深、不可按系统扫读。上一轮已做过一次精简，但用户对条目格式仍不满意，要求重排。

## Goals

- 每个工具以表格呈现，按操作系统分表，读者按自己的系统直接抄命令。成功标准：全文不再出现 `**标签**：` 四行条目，每章含一张工具总览表加 Windows / Arch / Ubuntu / Fedora / 通用 安装表
- 29 个工具不增不减，安装命令与当前版逐条一致。成功标准：工具总数仍为 29，逐条对照无命令丢失
- Markdown lint 通过。成功标准：panache（conform + nvim-lint）保存无报错
- 格式符合 plain 规则。成功标准：全文无 em dash、无分号，行尾 LF

## Non-goals

- 不增删工具，不改任何安装命令、版本要求、主页 URL
- 不改 A/B/C/D 必要性分类，只重排呈现方式
- 不动 README.md 与 AGENTS.md，不拆分文件

## Constraints

- 单文件 DEPENDENCIES.md
- 保留 A/B/C/D 四章及其必要性语义
- D 类不按 OS 拆表，因为安装方式是脚本 / npm / `pi install`
- 遵循 plain 规则与 .editorconfig（LF 行尾）

## Approach

主结构（设计 1 至 4 已逐节确认）：

- 保留 A/B/C/D 四章。每章先一张工具总览表（工具名即主页链接 | 功能 | 备注），再按 Windows / Arch / Ubuntu / Fedora / 通用 各一张两列表（工具 | 安装）
- 功能与主页只在总览表出现一次，安装表不重复，工具名在安装表里用纯文本
- 表外保留 5 块：顶部引言（改写为描述新结构）、安装优先级、分类图例、目录、补充说明
- 边界处理：
  - 仅某平台有的工具只进对应表
  - 只有通用装法（cargo / npm / go）的只进通用表
  - 旧格式「同名包 X」注删除
  - C9 Ruby / PHP / Java / Julia 合并为一行工具组
  - Mason 自动装的三个工具在总览备注写可跳过
  - 版本要求进总览功能或备注列
- D 章只放一张「工具 | 安装」表，不拆 OS

Pushback 记录：用户最初要求改四行条目格式，pushback 提议只摊平 Linux 嵌套列表（更小改动），用户选择整条格式重排（larger framing），按整表重排执行。

## Alternatives considered

- 每工具一张小表（字段 | 内容）：改动最小，但 Linux 嵌套仍在，视觉差异不大，否决
- 紧凑段落式去标签：源码最短，但字段不可扫读、主页链接被埋，否决
- OS 顶级组织、必要性降为一列：被否决，用户选择保留 A/B/C/D 章节、章内按 OS 拆表

## Testing

- 内容核对：29 个工具不增不减，每个安装命令与当前版逐条对照
- 表格完整：每张表列数一致、无断行，主页链接可点
- Markdown lint：panache 保存无报错
- 格式：LF 行尾，无 em dash、无分号
- 人工抽检：按 Windows 和 Arch 两条路径各读一遍，命令能直接抄用

## Open questions

N/A: 全部边界与结构已在设计中逐节确认
