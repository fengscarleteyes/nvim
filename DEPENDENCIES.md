# Neovim 配置依赖工具清单（全新机器配置用）

> 用途：在一台**全新电脑**上把这份 Neovim
> 配置完整跑起来时，需要预先安装的外部工具。 依据：`:checkhealth`（vim.health /
> vim.provider / lsp / mason / nvim-treesitter / conform / nvim-lint / neo-tree
> / fzf-lua）＋
> 配置文件里的硬性要求（`lua/plugins/*.lua`、`lua/custom/*.lua`、`lua/neovide.lua`）。
> 写法：每个工具一个小节，固定四行 ------ **功能 · 主页 · Windows 安装 · Linux
> 安装**；安装方式**优先包管理器**，Linux 按发行版分行缩进列出。
>
> 例外：**D 类（Pi 编码代理）** 与本配置没有依赖关系，是把终端 AI 代理一并收进来
> 的额外清单，不装不影响 Neovim 的任何功能。

## 安装方式优先级

按下面顺序选，能用上一级就不用下一级：

1. **系统 / 发行版包管理器**：Windows ------ `winget`；Linux ------
   `pacman`（Arch）/ `apt`（Ubuntu）/ `dnf`（Fedora）/ `snap`
2. **语言包管理器**：`cargo install`（Rust）/ `npm install -g`（Node）/
   `go install`（Go）
3. **Neovim 内的 Mason**：本配置 `lua/plugins/mason.lua` 的 `ensure_installed`
   已含 `stylua`、`lua-language-server`、`panache`，首次启动会自动装
4. **手动下载**（官方 Releases / AppImage / 解压后加入
   PATH）：仅当前三级都没有时

优先级图例：

- **A 必需**：不装，配置会报错或核心功能直接失效
- **B 强烈建议**：配置里的功能 / 快捷键依赖它，不装会明显退化
- **C 可选**：只影响边缘功能，或有替代品可用
- **D 额外**：与 Neovim 配置无关，按需安装（终端 AI 编码代理，见文件末尾）

## 目录

- **A 必需（10）**：neovim · git · ripgrep · fzf · tree-sitter-cli · zig · unzip
  · gzip · wget · 7-Zip
- **B 强烈建议（6）**：fd · lazygit · win32yank · lua-language-server · stylua ·
  panache
- **C 可选（10）**：Rust · Node.js/npm · Python · Go · LuaRocks · pwsh · trash
  CLI · clang/LLVM · Ruby/PHP/Java/Julia · neovide
- **D 额外（3）**：pi · vibekit（Pi 包）· pi-file-permissions（Pi 扩展）

## A 类：必需

### A1. neovim

- **功能**：编辑器本体。本配置用了
  `vim.pack.add`（`lua/plugins/*.lua`）、`vim.health`、原生剪贴板等，需要
  **Neovim ≥ 0.12**
- **主页**：https://neovim.io/
- **Windows 安装**：`winget install --id Neovim.Neovim -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S neovim`
  - Ubuntu：`sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim`
  - Fedora：`sudo dnf install neovim`
  - 通用：`sudo snap install nvim --classic`（或官方 AppImage）

### A2. git

- **功能**：版本控制；gitsigns、fzf-lua 的 git 功能、`vim.pack`
  插件管理、Treesitter 的 `require("nvim-treesitter.install").prefer_git = true`
  都依赖它
- **主页**：https://git-scm.com/
- **Windows 安装**：`winget install --id Git.Git -e --source winget`
- **Linux 安装**（三发行版同名包 `git`）：
  - Arch：`sudo pacman -S git`
  - Ubuntu：`sudo apt install git`
  - Fedora：`sudo dnf install git`

### A3. ripgrep（`rg`）

- **功能**：全文搜索后端：fzf-lua 的 `live_grep` / grep；也是
  `:checkhealth vim.health` 的 External Tools 之一
- **主页**：https://github.com/BurntSushi/ripgrep
- **Windows 安装**：`winget install --id BurntSushi.ripgrep.MSVC -e`
- **Linux 安装**（三发行版同名包 `ripgrep`）：
  - Arch：`sudo pacman -S ripgrep`
  - Ubuntu：`sudo apt install ripgrep`
  - Fedora：`sudo dnf install ripgrep`
  - 通用：`cargo install ripgrep`

### A4. fzf

- **功能**：fzf-lua 的模糊匹配后端；不装选择器会退化（慢、体验差）
- **主页**：https://github.com/junegunn/fzf
- **Windows 安装**：`winget install --id junegunn.fzf -e`
- **Linux 安装**（三发行版同名包 `fzf`）：
  - Arch：`sudo pacman -S fzf`
  - Ubuntu：`sudo apt install fzf`
  - Fedora：`sudo dnf install fzf`
  - 通用：`go install github.com/junegunn/fzf@latest`

### A5. tree-sitter-cli

- **功能**：nvim-treesitter 安装 / 编译 parser 必需（要求 **≥
  0.26.1**；官方说明用包管理器安装，**不要用 npm**）
- **主页**：https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md
- **Windows 安装**：winget 无此包 →
  用语言包管理器：`cargo install tree-sitter-cli`（需先装 Rust，见 C1）
- **Linux 安装**：
  - Arch：AUR ------ `paru -S tree-sitter-cli`（或 `yay -S tree-sitter-cli`）
  - Ubuntu / Fedora：仓库版本通常低于 0.26.1，用下面的通用方式
  - 通用：`cargo install tree-sitter-cli`

```markdown
- **Tree-sitter CLI**: <https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md>
- **cargo-binstall**: <https://github.com/cargo-bins/cargo-binstall>
  - Windows
    - `Set-ExecutionPolicy Unrestricted -Scope Process; iex (iwr "https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.ps1").Content`
  - Linux
    - `curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash`
    - `cargo binstall tree-sitter-cli`
```

### A6. zig

- **功能**：本配置指定用它编译 Treesitter
  parser：`require("nvim-treesitter.install").compilers = { "zig" }`（即
  `zig cc`）
- **主页**：https://ziglang.org/
- **Windows 安装**：`winget install --id zig.zig -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S zig`
  - Fedora：`sudo dnf install zig`
  - 通用：`sudo snap install zig --classic`（Ubuntu 用这条；也可从 ziglang.org
    下 tar.xz 解压后加 PATH）

### A7. unzip

- **功能**：Mason 下载工具后解包（`:checkhealth mason` 的 core utils）
- **主页**：http://infozip.sourceforge.net/UnZip.html
- **Windows 安装**：`winget install --id GnuWin32.UnZip -e`
- **Linux 安装**（同名包 `unzip`，多数发行版已预装）：
  - Arch：`sudo pacman -S unzip`
  - Ubuntu：`sudo apt install unzip`
  - Fedora：`sudo dnf install unzip`

### A8. gzip

- **功能**：Mason core utils（解压 `.gz` / `.tar.gz`）
- **主页**：https://www.gnu.org/software/gzip/
- **Windows 安装**：`winget install --id GnuWin32.Gzip -e`
- **Linux 安装**（同名包 `gzip`，系统自带，一般不用装）：
  - Arch：`sudo pacman -S gzip`
  - Ubuntu：`sudo apt install gzip`
  - Fedora：`sudo dnf install gzip`

### A9. wget

- **功能**：Mason core utils（下载；和 `curl` 有其一即可）
- **主页**：https://www.gnu.org/software/wget/
- **Windows 安装**：`winget install --id JernejSimoncic.Wget -e`（系统自带
  `curl`，够用可不装）
- **Linux 安装**（同名包 `wget`，多数发行版已预装）：
  - Arch：`sudo pacman -S wget`
  - Ubuntu：`sudo apt install wget`
  - Fedora：`sudo dnf install wget`
- **cURL**:
  - windows: `winget install cURL`

### A10. 7-Zip（`7z`）

- **功能**：Mason core utils（解 `zip` / `7z` / `rar` 等）
- **主页**：https://www.7-zip.org/
- **Windows 安装**：`winget install --id 7zip.7zip -e`
- **Linux 安装**（有 unzip 即可，属可选）：
  - Arch：`sudo pacman -S 7zip`
  - Ubuntu：`sudo apt install 7zip`
  - Fedora：`sudo dnf install p7zip`

## B 类：强烈建议

### B1. fd

- **功能**：fzf-lua 找文件的后端（比 `find` 快很多）；不装会回退到
  `find`，仍可用
- **主页**：https://github.com/sharkdp/fd
- **Windows 安装**：`winget install --id sharkdp.fd -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S fd`
  - Ubuntu：`sudo apt install fd-find`（装出的命令叫 `fdfind`）
  - Fedora：`sudo dnf install fd-find`
  - 通用：`cargo install fd-find`

### B2. lazygit

- **功能**：面板（dashboard）快捷键 `g` 直接调它打开 Git TUI
- **主页**：https://github.com/jesseduffield/lazygit
- **Windows 安装**：`winget install --id JesseDuffield.lazygit -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S lazygit`
  - Fedora：`sudo dnf install lazygit`
  - Ubuntu：仓库不一定有 → 用下面的通用方式
  - 通用：`go install github.com/jesseduffield/lazygit@latest`，或
    `sudo snap install lazygit`

### B3. win32yank（仅 Windows 需要）

- **功能**：用外部程序读写 Windows 剪贴板（Neovim 原生剪贴板也可用，想统一走
  win32yank 时再装）
- **主页**：https://github.com/equalsraf/win32yank
- **Windows 安装**：`winget install --id equalsraf.win32yank -e`
- **Linux 安装**：不需要 ------ Neovim 用内置剪贴板 provider；X11 / Wayland
  下可选装 `xclip` / `wl-clipboard`：
  - Arch：`sudo pacman -S xclip wl-clipboard`
  - Ubuntu：`sudo apt install xclip wl-clipboard`
  - Fedora：`sudo dnf install xclip wl-clipboard`

### B4. lua-language-server

- **功能**：Lua 的 LSP（本配置的 Lua 补全 / 诊断）
- **主页**：https://github.com/LuaLS/lua-language-server
- **Windows 安装**：`winget install --id LuaLS.lua-language-server -e`
- **Linux 安装**：
  - Arch：AUR ------ `paru -S lua-language-server`（或从发行版仓库装
    `lua-language-server`）
  - 通用：Mason ------ Neovim 里
    `:MasonInstall lua-language-server`（本配置已自动安装）

### B5. stylua

- **功能**：Lua 格式化器：conform 的 `lua = { "stylua" }`，保存时自动格式化
- **主页**：https://github.com/JohnnyMorganz/StyLua
- **Windows 安装**：`winget install --id JohnnyMorganz.StyLua -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S stylua`
  - Fedora：`sudo dnf install stylua`
  - 通用：`cargo install stylua`，或 Mason ------
    `:MasonInstall stylua`（本配置已自动安装）

### B6. panache

- **功能**：Markdown / Quarto / R Markdown 的 formatter + linter + language
  server：conform 的 `markdown = { "panache" }`、nvim-lint 的
  `markdown = { "panache" }`
- **主页**：https://github.com/jolars/panache
- **Windows 安装**：winget 无此包 →
  用语言包管理器：`cargo install panache`（需先装 Rust，见 C1）
- **Linux 安装**：
  - 通用：`cargo install panache`，或 Mason ------
    `:MasonInstall panache`（本配置已自动安装）
  - Arch / Ubuntu / Fedora：发行版仓库暂无，必要时从项目 Releases 取二进制

## C 类：可选

### C1. Rust（rustup / cargo）

- **功能**：Mason 的「语言运行时」之一；更实用的是它自带 `cargo` ------
  上面多个工具靠 `cargo install` 安装（ripgrep / fd-find / stylua /
  tree-sitter-cli / panache）
- **主页**：https://rustup.rs/
- **Windows 安装**：`winget install --id Rustlang.Rustup -e`
- **Linux 安装**（三发行版同名包 `rustup`）：
  - Arch：`sudo pacman -S rustup`
  - Ubuntu：`sudo apt install rustup`
  - Fedora：`sudo dnf install rustup`
  - 通用：官方脚本 ------
    `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && sh rustup.sh`

### C2. Node.js / npm

- **功能**：Mason 语言运行时；`npm install -g` 系工具（如
  trash-cli）的前提，启用 prettier 等前端格式化器也会用到
- **主页**：https://nodejs.org/
- **Windows 安装**：`winget install --id OpenJS.NodeJS -e`（LTS 用
  `OpenJS.NodeJS.LTS`）
- **Linux 安装**（同行列出 `nodejs` + `npm`）：
  - Arch：`sudo pacman -S nodejs npm`
  - Ubuntu：`sudo apt install nodejs npm`
  - Fedora：`sudo dnf install nodejs npm`

### C3. Python（含 venv）

- **功能**：Mason 语言运行时。启用 `pyright` / `basedpyright` / `ty` / `ruff` 等
  Python 工具时会用到
- **主页**：https://www.python.org/
- **Windows 安装**：`winget install --id Python.Python.3.13 -e`
- **Linux 安装**（多数发行版已预装 `python3`）：
  - Arch：`sudo pacman -S python`
  - Ubuntu：`sudo apt install python3 python3-venv`
  - Fedora：`sudo dnf install python3`

### C4. Go

- **功能**：Mason 语言运行时（如 gopls）；也是用 `go install` 装 fd / lazygit
  的前提
- **主页**：https://go.dev/
- **Windows 安装**：`winget install --id GoLang.Go -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S go`
  - Ubuntu：`sudo apt install golang-go`
  - Fedora：`sudo dnf install golang`

### C5. LuaRocks

- **功能**：Mason 语言运行时（Lua 相关工具依赖它）
- **主页**：https://luarocks.org/
- **Windows 安装**：`winget install --id DEVCOM.Lua -e`（winget 没有单独的
  `luarocks` 包，这个包自带 Lua 5.4 + LuaRocks）
- **Linux 安装**（三发行版同名包 `luarocks`）：
  - Arch：`sudo pacman -S luarocks`
  - Ubuntu：`sudo apt install luarocks`
  - Fedora：`sudo dnf install luarocks`

### C6. pwsh（PowerShell 7）

- **功能**：neo-tree 把文件删到回收站的后端之一（Windows 自带的 Windows
  PowerShell 5.1 也可用）
- **主页**：https://github.com/PowerShell/PowerShell
- **Windows 安装**：`winget install --id Microsoft.PowerShell -e`
- **Linux 安装**：
  - Arch：AUR ------ `paru -S powershell-bin`
  - Ubuntu：`sudo snap install powershell --classic`
  - Fedora：先加微软官方源，再 `sudo dnf install powershell`

### C7. trash CLI

- **功能**：neo-tree 的回收站后端（macOS / Linux 常用；Windows 用 pwsh 即可）
- **主页**：https://github.com/sindresorhus/trash
- **Windows 安装**：需先有 Node（见 C2）------ `npm install --global trash-cli`
- **Linux 安装**：
  - 通用：`npm install --global trash-cli`（需先有 Node，见 C2）
  - 发行版仓库的同名包 `trash-cli` 是另一个实现（命令为
    `trash-put`），不一定兼容本工具，建议用上面的 npm 方式

### C8. clang / LLVM

- **功能**：Treesitter parser 的备选编译器：只在不用 zig 时，把 `compilers` 改成
  `{ "clang" }` 才需要
- **主页**：https://llvm.org/
- **Windows 安装**：`winget install --id LLVM.LLVM -e`（也可用
  `BrechtSanders.WinLibs.*`）
- **Linux 安装**（三发行版同名包 `clang`）：
  - Arch：`sudo pacman -S clang`
  - Ubuntu：`sudo apt install clang`
  - Fedora：`sudo dnf install clang`

### C9. Ruby / PHP / Java / Julia 等

- **功能**：`:checkhealth mason` 的 Languages 段会逐条列出，只有安装对应语言的
  LSP / formatter 时才需要
- **主页**：各语言官网 ------ Ruby：https://www.ruby-lang.org/ ／
  PHP：https://www.php.net/ ／ Java：https://adoptium.net/ ／
  Julia：https://julialang.org/
- **Windows 安装**：需要时再装（如
  Java：`winget install --id EclipseAdoptium.Temurin.21.JDK -e`）
- **Linux 安装**：需要时用发行版包管理器装：
  - Arch：`sudo pacman -S ruby php jdk-openjdk julia`
  - Ubuntu：`sudo apt install ruby php openjdk-21-jdk julia`
  - Fedora：`sudo dnf install ruby php java-21-openjdk julia`

### C10. neovide

- **功能**：Neovim 的 GUI 前端（Rust
  写的独立窗口，支持动效、透明、高刷新率）。本配置 `init.lua` 里有
  `require("neovide")`，`lua/neovide.lua` 会在 Neovide 下设置
  `neovide_refresh_rate = 144`、`neovide_opacity = 0.95` 等；这段用
  `if vim.g.neovide then` 包着，**在终端里跑 Neovim
  时会自动跳过，所以纯终端用户不用装**。要求 Neovim ≥ 0.10（本配置 A1 已要求 ≥
  0.12，满足）
- **主页**：https://neovide.dev/（仓库：https://github.com/neovide/neovide）
- **Windows 安装**：`winget install --id Neovide.Neovide -e`；或 Scoop ------
  `scoop bucket add extras && scoop install neovide`
- **Linux 安装**：
  - Arch：官方 `extra` 仓库 ------ `sudo pacman -S neovide`（X11 下还需
    `sudo pacman -S libxkbcommon-x11`；想跟开发版用 AUR 的 `neovide-git`）
  - Ubuntu：官方仓库无此包 → 用下面的通用方式；snap 里有个
    `neovide`（`sudo snap install neovide`）但版本很旧（0.8.0，2021 年），不建议
  - Fedora：官方仓库无此包 → 社区
    COPR（`sudo dnf copr enable agraven/neovide && sudo dnf install neovide`）或
    Terra 仓库，或下面的通用方式
  - Nix / NixOS：`nix-shell -p neovide`（NixOS 在 `environment.systemPackages`
    里加 `pkgs.neovide`）
  - 通用：从官方 Releases
    下载自带依赖的二进制（https://github.com/neovide/neovide/releases）；或源码构建
    `cargo install --git https://github.com/neovide/neovide.git`（需先装 Rust +
    CMake + LLVM，见 C1）

```toml
# `Linux/macOS: ~/.config/neovide/config.toml`
# `Windows: %APPDATA%\neovide\config.toml`

# --- 基本窗口设置 ---
# 窗口尺寸与布局：size 和 grid 互斥，maximized 也与它们互斥
# size = "1200x800"    # 初始窗口像素尺寸
maximized = false      # 启动时最大化窗口
frame = "full"         # 窗口装饰模式: "full", "none", "transparent"(macOS), "buttonless"(macOS)

# --- 字体设置 ---
# 优先使用 Nerd Font，方便显示图标；size 为字号
[font]
normal = ["JetBrainsMono Nerd Font", "Fira Code Nerd Font", "Maple Mono NF CN", ]
size = 14.0

# --- 渲染与性能 ---
vsync = true           # 垂直同步，防止画面撕裂（默认开）
idle = true            # 空闲时暂停渲染以省电；若动画卡顿可改为 false
srgb = false           # macOS/Linux 默认 false，Windows 默认 true

# --- Neovim 后端 ---
# neovim-bin = "/usr/bin/nvim"  # 如果 Neovim 不在 PATH 中，指定绝对路径
# fork = true                   # 从终端启动时是否让 Neovide 后台运行

# --- 鼠标与交互 ---
mouse-cursor-icon = "arrow"  # 鼠标图标样式: "arrow" 或 "i-beam"

# --- 多网格 (Multigrid) ---
# 开启后支持平滑滚动、浮动窗口模糊背景、窗口动画
# 若遇到显示异常（如与终端版 Neovim 表现不一致），可设为 true 禁用
no-multigrid = false
```

## D 类：Pi 编码代理（额外，与 Neovim 配置无关）

本配置里没有任何 Pi 相关代码，这一节是按需收录：想在终端里用 AI 代理写代码
（vibe coding）时再装。和 C 类的区别是，C 类都还围着 Neovim 转，D 类不装不影响
编辑器。

### D1. pi

- **功能**：终端里的 AI 编码代理（Pi，官方叫 minimal agent harness），自带
  `read` / `bash` / `edit` / `write` 工具，扩展、技能、提示模板都以 Pi 包（npm /
  git）的形式分发。它是 Node 程序：走 npm / pnpm / bun 安装要求 **Node.js ≥
  22.19**（见 C2），走官方安装脚本则由脚本锁定依赖版本。原生 Windows 下 `bash`
  工具默认找 Git Bash，所以要先有 Git（见 A2）
- **主页**：https://pi.dev/（仓库：https://github.com/earendil-works/pi；npm：
  `@earendil-works/pi-coding-agent`。旧的 `@mariozechner/pi-coding-agent`
  已废弃，不要再用）
- **Windows 安装**：官方脚本 ------
  `powershell -c "irm https://pi.dev/install.ps1 | iex"`；或
  `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`（pnpm /
  bun 同理）。装完 `pi --version` 看版本，再用 `!printf 'Bash is working\n'`
  确认 Git Bash 能被找到
- **Linux 安装**：
  - 通用：`curl -fsSL https://pi.dev/install.sh | sh`（依赖版本被锁定，之后用
    `pi update` 升级）
  - 通用（npm）：`npm install -g --ignore-scripts @earendil-works/pi-coding-agent`
  - Nix / NixOS：`nix profile add github:earendil-works/pi/stable`（Nix 装的
    不能用 `pi update`，改用 `nix profile upgrade pi`）
- **首次使用**：`cd 项目目录 && pi` 启动，进去先 `/login` 选 provider（订阅或 API
  key），`/model` 换模型，`/tree` 可回退到任意一轮
- **配置位置**：个人配置与会话在 `~/.pi/agent/`（`settings.json`、`trust.json`）；
  项目配置在 `.pi/`（`.pi/settings.json`、`.pi/skills`、`.pi/extensions` 等），
  项目配置要授予 project trust（`/trust`）才加载
- **包管理**：`pi install npm:<包名>` / `pi install git:github.com/<owner>/<repo>`
  / `pi install ./本地目录`；`pi list` 查看，`pi remove <source>` 卸载，
  `pi update --extensions` 同步，`pi -e <source>` 只试跑一次不入配置

### D2. vibekit（Pi 包：给 vibe coding 装闸门）

- **功能**：把 `一句话需求` 变成 `你批准过的设计 → 你批准过的计划 → 没看过计划的
  agent 写的代码 → 你读得懂的验证结论` 的流水线，全部以 skill 形式提供：
  `brainstorm` 一次问一个问题、给出可观察的成功标准（没批准就不写代码）→ `plan`
  拆成带 `→ verify:` 的任务 → `exec` 每个任务派一个全新 subagent 执行并跑验证 →
  `verify` 汇总证据报 `ready` / `not ready`，失败转 `debug`（只找根因、不改代码）。
  另有常驻的 `lazy`（少写代码）和 `terse` / `plain`（少说、规矩文本）。注意作者
  只在 Claude Code / Codex / opencode / Antigravity 上实测过，Pi 那一行标的是
  not verified
- **主页**：https://github.com/rizukirr/vibekit（npm：`@rizukirr/vibekit`，MIT）
- **Windows 安装**：与系统无关，在任意终端执行
  `pi install git:github.com/rizukirr/vibekit`（也可改用
  `pi install npm:@rizukirr/vibekit`），之后 `pi list` 里应能看到它
- **Linux 安装**：同 Windows，同一条命令：
  - `pi install git:github.com/rizukirr/vibekit`
  - 更新：重跑同一条命令，或 `pi update --extensions`

### D3. pi-file-permissions（Pi 扩展：按路径限权）

- **功能**：Pi 默认不给文件系统设限（工具按当前用户权限跑，不会每步弹确认）。这个
  扩展读项目根目录的 `file-permissions.yaml`，用 `domains` 白名单限制内置工具
  （`read` / `write` / `edit` / `find` / `grep` / `ls`）能碰哪些路径，`bash` 里的
  `find` / `grep` / `ls` 之类命令也会被拦掉。它只管内置文件工具，管不了 skills、
  MCP 服务和其它扩展提供的工具
- **主页**：https://github.com/ross-jill-ws/pi-file-permissions（npm：
  `pi-file-permissions`，MIT）
- **Windows 安装**：`pi install npm:pi-file-permissions`（卸载用
  `pi remove npm:pi-file-permissions`）
- **Linux 安装**：同 Windows，同一条命令

配置：项目根目录放一个 `file-permissions.yaml`，没有这个文件就完全不限制。

```yaml
# file-permissions.yaml（项目根目录）
domains:
  - path: ./                  # 项目根：给全套权限
    permissions: [read, write, edit, find, grep, ls]
  - path: ~/notes             # 只读参考目录
    permissions: [read, find, ls]
  - path: ~/data/fixtures     # 只读测试数据
    permissions: [read, grep]
```

规则要点：只有 allow 语义，没列出的路径等于拒绝；`path` 可写绝对路径、`./` 相对
路径（按项目根解析）或 `~/` 家目录；项目根和 `~/.pi` 默认全权限，但只要被显式
domain 覆盖就按 domain 来；多个 domain 命中同一路径时最长（最具体）的赢；
`domains:` 留空等于只允许项目根和 `~/.pi`。

## Pi vibe coding 最小流程

三个都装好后，一个改动的完整路径如下（都在项目目录里操作）：

1. 准备：`cd 项目`，确认它在 git 仓库里（没有就 `git init`），需要的话写一份
   `AGENTS.md` 说明项目约定（Pi 启动时会读）
2. 装一次就够：`pi install git:github.com/rizukirr/vibekit`；要限权再加
   `pi install npm:pi-file-permissions` 并写好 `file-permissions.yaml`
3. 启动登录：`pi`，第一次用 `/login` 选 provider 和模型
4. 出需求：`/skill:vibe "给设置面板加一个深色模式开关"`。vibekit 文档里写的
   `/vibekit:vibe` 是 Claude Code 的写法，Pi 这边的 skill 调用语法是
   `/skill:<名字>`，所以在 Pi 下同一件事写成 `/skill:vibe`
5. 审设计再放行：brainstorm 一次一个问题地问你，最后给一版带成功标准的 spec；
   你不批准它就不写代码。批准后 plan 出任务表，exec 逐条执行，verify 出结论
6. 失败交给 debug：verify 报 `not ready` 会自动转 `debug`，它只定位根因（还会派
   只读 agent 反驳自己的结论），不动代码；看完结论再决定改什么
7. 小改动走快路：`/skill:quick "把 README 里的旧域名换掉"` 会跳过 spec / plan /
   subagent，但仍要跑一个可运行检查，并在最后一行说明跳过了哪些阶段。要动依赖、
   schema、权限或支付这类信任边界、跨文件太多、需求有两种读法时，它会拒绝快路并
   让你改走 `/skill:vibe`
8. 收尾自己看：`git diff`、测试输出和 verify 结论对一遍（vibekit 不替你 merge），
   确认后再合并或提 PR；Pi 里 `/tree` 能回到任意一轮重来，`/export` 导出会话
9. 日常维护：`pi list` 看已装包，`pi remove <source>` 卸载，
   `pi update --extensions` 同步；改过 skill 后在会话里 `/reload` 重载
10. 安全底线：Pi 的工具以你当前用户权限直接运行，不会逐条弹确认；file-permissions
    只拦内置文件工具的路径，挡不住 skills、MCP 和其它扩展工具，也挡不住 `bash`
    里的任意命令。跑不熟的仓库时用容器或沙箱，加上 git / 备份兜底

## 补充说明

- **Linux
  包名以发行版仓库为准**：上面用的都是各发行版包管理器，个别包名在不同版本里会有微调（例如
  Fedora 的 7-Zip 包名是 `p7zip`）。
- **装完外部工具要重开 Neovim**（PATH 只在进程启动时读取），再用
  `:checkhealth`、`:checkhealth mason`、`:checkhealth nvim-treesitter` 复查。
- **用 Neovide 时建议装一款 Nerd Font**：本配置的 tabline / winbar / `listchars`
  用了图标字形，Neovide 不会自动挑字体；装好字体后在 `lua/neovide.lua` 的
  `if vim.g.neovide then` 分支里加 `vim.opt.guifont = "字体名:h14"`（或
  `vim.g.neovide_scale_factor` 调整体缩放）。
- **D 类（Pi）装完要重开终端**：`pi` 才会进 PATH；Pi 的工具是在自己的进程里跑的，
  改完 skill / 扩展在会话里执行 `/reload` 就行，不用重启 Neovim。
