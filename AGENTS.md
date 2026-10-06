# AGENTS.md

> 本文件是给 AI 编码代理（Cline / Pi / Claude Code / Codex 等）看的**项目地图 +
> 工作约定**， 可直接作为会话开头的 prompt 模板使用。 给人看的文档在
> `README.md`（用法 / TODO）和 `docs/DEPENDENCIES.md`（外部工具安装清单）。
>
> 一句话要求：**照着现有风格做最小改动，动手前先跟用户确认目标，改完按第 6
> 节自检并如实汇报。**

## 0. 速查（TL;DR）

- 这是什么：个人 Neovim 配置，**纯 Lua**，Windows 与 Arch Linux 共用一份
- 硬前提：**Neovim ≥ 0.12**（用了内置插件管理器 `vim.pack`）
- 插件管理器是 `vim.pack`，**不是** lazy.nvim / packer / LazyVim，不要"顺手迁移"
- 改代码前的读法：`init.lua`（加载顺序）→ 对应入口 `lua/<层>.lua` →
  同目录已有同类文件
- 四个入口文件必须待在各自子目录**外面**（`lua/plugins.lua`、`lua/options.lua`、
  `lua/keymaps.lua`、`lua/theme.lua`），放进去会自我递归 source
- 改完必跑：`stylua --check .`（或至少对改动文件跑 `stylua`）
- 新增插件 / 外部工具：必须同步更新 `docs/DEPENDENCIES.md`
- 新增自研功能：先读第 5 节「工作方式」，**用户确认目标后再写代码**
- 跑全仓库 `glob` / `grep` 时排除 `.venv/`（7000+ 文件，见第 1 节）

## 1. 项目是什么

  | 项            | 内容                                                                    |
  | ---           | ---                                                                     |
  | 类型          | 个人 Neovim 配置（不是插件、不是发行版框架）                            |
  | 语言          | 纯 Lua；仓库里没有 Vimscript，也没有 `vim/` 目录                        |
  | 插件管理      | `vim.pack.add()`（Neovim 0.12 内置），每个插件一个文件显式声明          |
  | 锁文件        | 根目录 `nvim-pack-lock.json`，**已被 `.gitignore` 忽略，不要提交**      |
  | 平台          | Windows（`%LOCALAPPDATA%\nvim`）+ Arch Linux（`~/.config/nvim`）        |
  | 行尾          | 全仓库 LF（`.gitattributes`、`.editorconfig`、`.stylua.toml` 三处一致） |
  | 文档语言      | 注释与说明文档用**中文**；`git log` 的提交信息用英文短句                |
  | 格式化 / 检查 | stylua（Lua）、panache（Markdown，走 conform + nvim-lint）              |

根目录其余配置文件（别乱动）：`.editorconfig` / `.gitattributes`（LF
策略）、`.stylua.toml` （格式化规则）、`.luarc.json`（lua_ls
缩进）、`.gitignore`、`ruff.toml`（ruff 的 lint/format
规则）、`pyproject.toml`（uv 的 dev 依赖：basedpyright + ruff，配合同级
`.venv/`）

根目录还有两个**目录**，同样别动、也别当垃圾清理：

- `.venv/`：README 里用 `uv venv .venv --python 3.15` 建的 Python
  虚拟环境，site-packages 里有 `basedpyright`、`ruff` 和 `nodejs_wheel`（Node
  24）。已在 `.gitignore` 里，但文件数 7000+：跑全仓库 `glob` / `grep`
  时排除它，否则结果会被淹没（其中不含 `.lua`，所以 `stylua` 不受影响）
- `.ruff_cache/`：ruff 的缓存目录，自带 `.gitignore`，不用管

## 2. 目录结构与加载顺序

`init.lua` 只有 6 行
`require`，顺序固定；**新功能一律加进对应目录，不要改这个顺序**：

```text
options → theme → custom → plugins → keymaps → neovide
```

  | 路径                                    | 职责                 | 加载方式                        | 新增方式                          |
  | ---                                     | ---                  | ---                             | ---                               |
  | `init.lua`                              | 唯一入口             | —                               | 不改                              |
  | `lua/options.lua` + `lua/options/*.lua` | `vim.opt.*` 选项     | `:runtime!`，文件名字典序       | 新建 `lua/options/xxx.lua`        |
  | `lua/theme.lua` + `lua/theme/*.lua`     | 配色方案             | 同上                            | 同上（`*.lua.disabled` = 停用）   |
  | `lua/custom.lua` + `lua/custom/*.lua`   | 自研功能模块         | 显式 `require(...).setup()`     | 新建模块 + 在 `custom.lua` 补一行 |
  | `lua/plugins.lua` + `lua/plugins/*.lua` | 第三方插件           | `vim.pack.add` + 各自 `setup()` | 新建 `lua/plugins/xxx.lua`        |
  | `lua/keymaps.lua` + `lua/keymaps/*.lua` | 键位映射             | `:runtime!`，文件名字典序       | 新建 `lua/keymaps/xxx.lua`        |
  | `lua/neovide.lua`                       | Neovide GUI 专属设置 | 仅 `vim.g.neovide` 为真时生效   | 直接改                            |

现有子文件（改功能前先按名字找对文件）：

- `lua/custom/`：`notify`（接管 `vim.notify`
  的浮动通知）、`clean`、`yank`、`terminal`、
  `autopair`、`diagnostics`、`tabline`、`winbar`、`lsp`、`dashboard`
- `lua/options/`：`completion`、`files`、`general`、`indent`、`leader`、`search`、`ui`
- `lua/keymaps/`：`fzf`、`indent`、`insert`、`neotree`
- `lua/plugins/`：`blink`、`conform`、`fzf-lua`、`gitsigns`、`hardtime`、`hop`、
  `live-preview`、`mason`、`neo-tree`、`nvim-lint`、`nvim-lspconfig`、`nvim-origami`、
  `nvim-treesitter`、`precognition`、`tiny-inline-diagnostic`、`bak/`（已停用）
- `lua/theme/`：`colorscheme.lua`（生效中，one_monokai）、`tokyonight.lua.disabled`（备选）

**停用而不删除**（保留用户的选择权，不要"清理"）：

- 整个文件：改名 `xxx.lua.disabled`，或移进 `bak/` 子目录（glob
  不匹配目录，因此不会加载）
- 单行 / 单块：用户注释掉的备选项（如 `lua/options/ui.lua` 里多组 `listchars`、
  `lua/plugins/mason.lua` 里注释的工具、`conform.lua` 里注释的 formatter）
  **是刻意留下的开关，保持原样，不要取消注释也不要删**

几条容易踩的顺序规则：

- 同目录内按**文件名字典序**执行，同一个设置**后加载的覆盖先加载的**
- `options` / `plugins` / `keymaps` 三层用的是 `:runtime! lua/<层>/*.lua`，它沿
  **`runtimepath`** 查找，不只本配置目录：rtp
  中靠前的目录优先。要严格只跑本目录下的文件， 用 `lua/plugins.lua`
  末尾给出的显式 `glob` + `vim.cmd.source` 写法
- 同一层内某个文件报错**不会中断该层其余文件**（`:runtime!`
  会把后面的跑完），但整体仍以 报错收尾；所以 `init.lua` 里那次 `require`
  依旧可能失败，后面的层就整个不执行了（见第 7 节）
- `custom/` 用 `require` 而不是 `:runtime!`：模块需要 `setup()` 生效，且会被别处
  `require` 复用，这样能保证全局只有一个实例
- `lua/theme/` 同时存在多个主题文件时，字典序最后的那个决定最终配色

## 3. 代码风格约定（照抄现有文件即可）

**格式化**（`.stylua.toml` 已定死，不用商量）：2 空格缩进、120 列、LF
行尾、优先双引号、 函数调用始终带括号、不把 `if ... return` 折叠成一行、require
不自动排序。

**文件头注释块**（`lua/` 下每个文件都有，新文件也要有）：

```lua
-- ============================================================
-- 一句话说清这个文件做什么
-- ------------------------------------------------------------
-- 需要展开的细节：配置项表、命令表、键位表、注意事项
-- ============================================================
```

**自研模块模板**（可直接照 `lua/custom/yank.lua` 抄）：

```lua
local M = {}
local DEFAULTS = { key = "value" }
local initialized = false

function M.setup(opts)
  local cfg = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
  if initialized then
    return M
  end
  initialized = true
  -- 注册命令 / 键位 / 自动命令（自动命令带 augroup + clear = true，避免重复累积）
  return M
end

return M
```

- 用
  `vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})`，不要就地改
  `DEFAULTS`
- `setup()` 必须幂等（`initialized` 守卫）；`require` 本身不要有副作用
- 命令用 `nvim_create_user_command` 并带 `desc`；命名沿用现有前缀风格
  （`:NotifyTest`、`:DiagToggle`、`:WinbarToggle`、`:DashboardToggle`、`:LspRename`
  ...）
- 涉及键位时默认**不绑**，由 `setup({ map_keys = true })` 开启 （见
  `lua/custom/lsp.lua`、`lua/custom/terminal.lua`）

**键位写法**（`lua/keymaps/`）：

```lua
vim.keymap.set("n", "<leader>ff", "<Cmd>FzfLua files<CR>", { silent = true, desc = "FzfLua files" })
```

- 只写 `silent` / `desc`（`noremap`/`nowait`/`expr` 用默认值），右侧优先
  `<Cmd>…</Cmd>`
- `desc` 用英文短标题（现有约定）；`<leader>` = 空格、`<localleader>` =
  `\`（`lua/options/leader.lua`）

**选项写法**（`lua/options/`）：一行一个设置，行尾用中文注释说明用途/原因；追加用
`vim.opt.shortmess:append("I")` 这种形式。

**插件写法**（`lua/plugins/`）：

```lua
vim.pack.add({ "https://github.com/owner/repo" })

require("plugin").setup({ ... })
```

- 只写 `vim.pack.add` + `setup`，没有 lazy 加载字段（`vim.pack` 是启动即加载）
- 依赖插件在同一个文件里一起 `add`；插件配套的键位/自动命令就地写在这个文件
- 首次 `vim.pack.add` 会联网下载：验证前先确认网络前提，离线时的表现见第 7 节

**文档写法**（`docs/DEPENDENCIES.md`）：按 **A 必需 / B 强烈建议 / C 可选 / D
额外** 分章。 A / B / C
三章的结构是：先一张工具总览表（`工具 | 功能 | 备注`，工具名链到主页），再按
**Windows / Arch / Ubuntu / Fedora / 通用**
各给一张安装表（`工具 | 安装`，单元格里直接写 安装命令）；D 章是与 Neovim
无关的终端代理，只有一张总览表（表头 `工具 | 功能 | 安装`）。
新增工具要同时进总览表和相关发行版的安装表，并更新开头「目录」里各档的计数。

## 4. 常见任务怎么做（cookbook）

  | 想做什么               | 改哪里                                                                                        | 关键注意                                                               |
  | ---                    | ---                                                                                           | ---                                                                    |
  | 加自研功能             | 新建 `lua/custom/<name>.lua`，再在 `lua/custom.lua` 末尾补 `require("custom.<name>").setup()` | 命令/键位/自动命令都放同一文件；配置项进 `DEFAULTS`                    |
  | 加第三方插件           | 新建 `lua/plugins/<name>.lua`                                                                 | 同步 `docs/DEPENDENCIES.md`；停用就移进 `bak/`                         |
  | 加/改键位              | `lua/keymaps/<group>.lua`                                                                     | 必须带 `desc`；先查有无重复 lhs                                        |
  | 改选项                 | `lua/options/<topic>.lua`                                                                     | 同名设置按字典序覆盖，注意别被后面的文件盖掉                           |
  | 换主题                 | `lua/theme/colorscheme.lua`；备选主题去掉 `.disabled` 即可                                    | 同目录多个主题文件时字典序最后的生效                                   |
  | 调 LSP / 格式化 / 检查 | `nvim-lspconfig.lua`、`conform.lua`、`nvim-lint.lua`、`mason.lua`                             | 新增工具要同时进 mason 的 `ensure_installed` 与 `docs/DEPENDENCIES.md` |
  | 改 Neovide 外观        | `lua/neovide.lua`                                                                             | 全部在 `if vim.g.neovide then` 内，终端里无法验证，要说明这一点        |
  | 文档 / 依赖清单        | `README.md`、`docs/DEPENDENCIES.md`                                                           | 依赖变了必须动 `docs/DEPENDENCIES.md`                                  |

## 5. 工作方式（用户既有约定，优先遵守）

这一节来自仓库 `README.md` 里「custom
目录添加新文件」的既有约定，**优先级高于你的默认习惯**：

1. 动手前先想清楚：这个需求要动哪些模块、每个模块是否**必要**
2. 非必要的部分、扩展功能：**先抛出选项 + 描述给用户**，让用户决定做不做
3. 等用户确认最终目标之后，**再开始写代码**
4. 目标是功能简洁：先把基础功能实现好，不顺手加花活

落到具体行为上：

- 一次只推进一件事；需求有歧义或存在多种读法时先问，不要替用户做选择
- 需要用户确认时，单独起一行写出「待你确认：」，不要埋在汇报段落中间让用户去找
- 提问要给编号选项，每项写清做什么、动哪些文件、代价是什么，并标出推荐项。不要只问「要不要继续」这种没有内容的问句
- 每轮反馈结尾固定收一句：有待确认就列成选项，没有就写「无待确认事项」。用户不需要从上下文里猜
- 不擅自重构、不顺手重命名、不批量重排格式（避免整库 diff）
- 不删用户注释掉的备选配置（见第 2 节）
- 不确定的第三方 API：先查本机 `nvim-data` 里的插件源码或官方文档，不要凭印象写
- 交付时说明：改了哪些文件、验证到什么程度、哪些没测到

## 6. 做完了怎么自检（本仓库没有测试框架，按这张表走）

  | 项目           | 命令 / 操作                                                                               | 说明                                                                                                                                           |
  | ---            | ---                                                                                       | ---                                                                                                                                            |
  | Lua 格式       | `stylua --check .`，或只对改动文件 `stylua <文件>`                                        | `stylua` 由 Mason 安装，PATH 里可能没有：Windows `%LOCALAPPDATA%\nvim-data\mason\bin\stylua.cmd`，Linux `~/.local/share/nvim/mason/bin/stylua` |
  | Lua 语法       | `nvim --headless -u NONE "+lua assert(loadfile('lua/xxx.lua'))" +qa`                      | `-u NONE` 不加载配置，不会触发 `vim.pack` 联网下载                                                                                             |
  | 启动是否有报错 | 正常启动后看 `:messages`（或 `nvim --headless "+lua print('loaded')" +qa`，会联网，谨慎） | 配置加载期的错误会在启动时直接显示                                                                                                             |
  | 健康检查       | `:checkhealth`、`:checkhealth mason`、`:checkhealth vim.treesitter`                       | 与改动相关的项不能退化                                                                                                                         |
  | Markdown       | 写 `.md` 时 panache 会自动格式化 + lint（conform + nvim-lint）                            | 改 `README.md` / `docs/DEPENDENCIES.md` / 本文件后确认没有报错                                                                                 |
  | 行尾           | 保持 LF，`.editorconfig` + `.gitattributes` 已兜底                                        | 在 Windows 上编辑文档尤其注意                                                                                                                  |
  | 手工验证       | 用命令或键位实际跑一次新功能，再看 `:messages`                                            | 汇报写"实测通过 / 未测"，不要写"应该可以"                                                                                                      |

**Definition of Done**：格式通过 + 启动无报错 + 相关 `:checkhealth` 不退化 +
文档同步 （`docs/DEPENDENCIES.md`，必要时 `README.md`）+
清楚说明哪些部分没验证到。

## 7. 已知坑（都踩过，代码注释里写了原因）

- `pcall(vim.cmd, "…")` 会被 lua_ls 判成 `Cannot assign table to parameter fun`
  （`vim.cmd` 是"函数兼表"），要写成 `pcall(function() vim.cmd("…") end)` ------
  见 `lua/plugins/mason.lua`、`lua/custom/winbar.lua` 的注释
- 启动阶段某个 `require` 抛错会**中断 `init.lua` 后续所有 `require`** （如
  `require("plugins")` 失败 → `require("keymaps")` 不执行 → 键位全丢）。
  所以外部命令 / 网络 / parser 这类可能失败的调用要用 `pcall` 兜住并降级
  `vim.notify` ------ 见 `mason.lua` 的 `MasonUpdate`、`nvim-treesitter.lua` 的
  `vim.treesitter.start`
- 四个入口文件放进对应子目录会自我递归 source（第 2 节）
- 同一个选项写在两个文件里时，只改一个可能"没生效"
  （机制：同目录按字典序执行、后加载覆盖先加载，见第 2 节）
- 入口文件顶部注释里的执行顺序是**手工维护**的副本，会跟目录实际内容漂移：
  发现对不上就以目录内文件名为准，并顺手把注释改对（`lua/options.lua`
  就曾把已删除的 `folds` 留在列表里）
- `lua/plugins/bak/`、`*.lua.disabled` 是**停用位**，不是待清理的垃圾
- Neovide 设置只在 GUI（`vim.g.neovide` 为真）里生效，终端里测不出来； Neovide
  自己的 `config.toml` 与本文件部分项重叠（以实际效果为准）
- `vim.pack.add`
  首次运行会联网拉插件：离线/网络差时启动会失败或变慢，别据此判断代码有 bug
- vibekit 的斜杠命令在 pi 里是 `/skill:name`（`/skill:vibe`、`/skill:quick`
  等），不是 `/vibekit:vibe` / `/vibekit:quick`：后者是 Claude Code
  的命令格式，vibekit 的 `package.json` 里 `pi` 清单只声明 skills，pi 不加载
  `commands/` 目录（见 `docs/PI-NEOVIM-WORKFLOW.md`）

## 8. git 与提交

- 提交信息用**英文短句**，沿用现有前缀习惯：`feat:` / `fix:` / `doc:` /
  `change:`
  （近期示例：`doc: change`、`fix: format code`、`feat: add lsp custom`）
- 一次提交只做一件事；纯文档改动用 `doc:`
- 动 git 前先 `git status` 看清工作区；**不要** `git reset --hard`、不要强推
- 不要提交 `nvim-pack-lock.json`（已在 `.gitignore`）
- 不要执行 `:RemoveStateDir` / `:RemoveShadaDir`
  这类破坏性维护命令，除非用户明确要求

## 9. 环境速查

```text
Neovim    ≥ 0.12（本机 0.12.5；vim.pack 依赖它）
配置目录   Windows: %LOCALAPPDATA%\nvim        Linux: ~/.config/nvim
数据目录   Windows: %LOCALAPPDATA%\nvim-data   Linux: ~/.local/share/nvim
Mason 工具 Windows: %LOCALAPPDATA%\nvim-data\mason\bin   Linux: ~/.local/share/nvim/mason/bin
           已装：stylua（Lua 格式化）、lua-language-server、panache（Markdown）、
           basedpyright（Python LSP，含 basedpyright-langserver）、
           ruff（Python lint / format）
外部依赖   清单以 docs/DEPENDENCIES.md 为准（A 必需 / B 强烈建议 / C 可选 / D 额外，
           逐发行版给安装命令）。本文件不复制清单，避免两处不一致
```

<!-- 维护提示：本文件只描述"怎么在这个仓库里干活"。改了目录结构、加载方式、文档格式或依赖
     策略后，请同步更新第 2 / 3 / 6 / 9 节；不要在这里复制 `README.md` 的用法说明，也不要
     复制 `docs/DEPENDENCIES.md` 的工具清单——复制来的副本一定会过期。 -->
