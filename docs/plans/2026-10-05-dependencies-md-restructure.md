# DEPENDENCIES.md 文档结构重排: Implementation Plan

**Spec:** docs/specs/2026-10-05-dependencies-md-restructure-design.md
**Goal:** 把 DEPENDENCIES.md 从四行粗体标签条目重排为按 OS 分表的表格结构，内容不变。
**Architecture:** 单文件重写。保留 A/B/C/D 四章，每章一张工具总览表加 Windows / Arch / Ubuntu / Fedora / 通用 安装表，D 章只放一张单表。表外保留引言、安装优先级、分类图例、目录、补充说明。

## Global constraints
- 单文件 DEPENDENCIES.md，不动 README.md 与 AGENTS.md
- 29 个工具不增不减，安装命令、版本要求、主页 URL 与当前版逐条一致
- 保留 A/B/C/D 四章及其必要性语义
- D 类不按 OS 拆表
- 无 em dash、无分号，行尾 LF
- panache 是本仓库 Markdown 规范格式器，其换行规则优先，段落允许被它 reflow

### Task 1: 重写 DEPENDENCIES.md 为表格结构 → verify: `grep -q 'Windows 安装\|Linux 安装' DEPENDENCIES.md` 退出码 1，且 `grep -q '^### Windows' DEPENDENCIES.md` 退出码 0，且 `grep -q '^### 通用' DEPENDENCIES.md` 退出码 0

**Files:**
- Modify: `DEPENDENCIES.md`

- [ ] Step 1: 读当前 DEPENDENCIES.md，作为 29 个工具迁移内容的唯一来源（安装命令、版本要求、主页 URL）
- [ ] Step 2: 顶部引言改为 `> 全新机器跑起这份配置前要装的外部工具。按 A/B/C/D 四档必要性分章，每章先给工具总览（功能与主页），再按 Windows / Arch / Ubuntu / Fedora / 通用分安装表。优先用包管理器。D 类是与 Neovim 配置无关的终端 AI 代理，按需安装。`
- [ ] Step 3: A/B/C 三章：每章先写工具总览表（`| 工具 | 功能 | 备注 |`，工具名写成主页链接），再写 Windows / Arch / Ubuntu / Fedora / 通用 五张安装表（`| 工具 | 安装 |`）
- [ ] Step 4: 边界：win32yank 只进 Windows 表；cargo / npm / go 装法的只进通用表；C9 Ruby / PHP / Java / Julia 合并为一行工具组；Mason 三件（stylua、lua-language-server、panache）备注写「本配置已由 Mason 自动装，可跳过手动」；版本要求进总览功能或备注列
- [ ] Step 5: D 章只写一张 `| 工具 | 安装 |` 表（pi / vibekit / pi-file-permissions）
- [ ] Step 6: 内容与当前版逐条一致，全文不出现 em dash、分号
- [ ] Step 7: Run `grep -q 'Windows 安装\|Linux 安装' DEPENDENCIES.md`，期望退出码 1
- [ ] Step 8: Commit

### Task 2: 内容完整性核对 → verify: `[ "$(grep -cE '^\| \[' DEPENDENCIES.md)" -ge 29 ]` 退出码 0，且关键命令 grep 退出码 0，且无 em dash/分号 grep 退出码 1

**Files:**
- Modify: `DEPENDENCIES.md`（仅当核对发现遗漏时）

- [ ] Step 1: Run `[ "$(grep -cE '^\| \[' DEPENDENCIES.md)" -ge 29 ]`，期望退出码 0
- [ ] Step 2: Run `grep -qE 'neovim-ppa/unstable|0\.26\.1|EclipseAdoptium.Temurin.21|Git\.Git -e|@earendil-works/pi-coding-agent|pi-file-permissions' DEPENDENCIES.md`，期望退出码 0
- [ ] Step 3: Run `grep -qE '；|—|–' DEPENDENCIES.md`，期望退出码 1
- [ ] Step 4: 任一步失败则定位丢失的工具或命令并补回，再重跑
- [ ] Step 5: Commit（若有改动）

### Task 3: panache 格式化与 lint → verify: `"$LOCALAPPDATA/nvim-data/mason/bin/panache.cmd" format --check DEPENDENCIES.md` 退出码 0，且 `"$LOCALAPPDATA/nvim-data/mason/bin/panache.cmd" lint DEPENDENCIES.md` 退出码 0

**Files:**
- Modify: `DEPENDENCIES.md`（panache format 就地重排）

- [ ] Step 1: Run `"$LOCALAPPDATA/nvim-data/mason/bin/panache.cmd" format DEPENDENCIES.md`
- [ ] Step 2: Run `"$LOCALAPPDATA/nvim-data/mason/bin/panache.cmd" lint DEPENDENCIES.md`，期望退出码 0
- [ ] Step 3: Commit
