# Neovim 配置依赖工具清单（全新机器配置用）

> 用途：在一台**全新电脑**上把这份 Neovim 配置完整跑起来时，需要预先安装的外部工具。
> 依据：`:checkhealth`（vim.health / vim.provider / lsp / mason / nvim-treesitter / conform / nvim-lint / neo-tree / fzf-lua）＋ 配置文件里的硬性要求（`lua/plugins/*.lua`、`lua/custom/*.lua`）。
> 每条只给四件事：**工具 · 功能 · 主页 · 安装方式**（Windows 优先 winget；Linux 优先通用方式，无通用方式时按 Arch / Ubuntu / Fedora 分别列出）。

优先级图例：

- **A 必需**：不装，配置会报错或核心功能直接失效
- **B 强烈建议**：配置里的功能 / 快捷键依赖它，不装会明显退化
- **C 可选**：只影响边缘功能，或有替代品可用

## A 类：必需

| 工具 | 功能 | 主页 | Windows 安装（优先 winget） | Linux 安装（通用优先；无通用则分发行版） |
| --- | --- | --- | --- | --- |
| **neovim** | 编辑器本体。本配置用了 `vim.pack.add`（`lua/plugins/*.lua`）、`vim.health`、原生剪贴板等，需要 **Neovim ≥ 0.12** | https://neovim.io/ | `winget install --id Neovim.Neovim -e` | 通用：官方 Releases 的 AppImage / tar.gz（https://github.com/neovim/neovim/releases）；Arch：`sudo pacman -S neovim` ／ Ubuntu（仓库版本偏旧，建议官方 PPA）：`sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim` ／ Fedora：`sudo dnf install neovim` |
| **git** | 版本控制；gitsigns、fzf-lua 的 git 功能、`vim.pack` 插件管理、Treesitter 的 `require("nvim-treesitter.install").prefer_git = true` 都依赖它 | https://git-scm.com/ | `winget install --id Git.Git -e` | 无通用方式 → Arch：`sudo pacman -S git` ／ Ubuntu：`sudo apt install git` ／ Fedora：`sudo dnf install git` |
| **ripgrep（`rg`）** | 全文搜索后端：fzf-lua 的 `live_grep` / grep；也是 `:checkhealth vim.health` 的 External Tools 之一 | https://github.com/BurntSushi/ripgrep | `winget install --id BurntSushi.ripgrep.MSVC -e` | 通用：`cargo install ripgrep`（三个发行版也都有同名包 `ripgrep`） |
| **fzf** | fzf-lua 的模糊匹配后端；不装选择器会退化（慢、体验差） | https://github.com/junegunn/fzf | `winget install --id junegunn.fzf -e` | 通用：`git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install`（发行版也有 `fzf` 包） |
| **tree-sitter-cli** | nvim-treesitter 安装 / 编译 parser 必需（要求 **≥ 0.26.1**；官方说明用包管理器安装，**不要用 npm**） | https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md | winget 无此包 → 通用：`cargo install tree-sitter-cli`（需先装 Rust，见 C 类），或从项目 Releases 下载 `.zip` 解压后加入 PATH | 通用：`cargo install tree-sitter-cli`（发行版仓库里的版本通常低于 0.26.1，不推荐） |
| **zig** | 本配置指定用它编译 Treesitter parser：`require("nvim-treesitter.install").compilers = { "zig" }`（即 `zig cc`） | https://ziglang.org/ | `winget install --id zig.zig -e` | 通用：从 https://ziglang.org/download/ 下载 `zig-x86_64-linux-*.tar.xz`，解压后把目录加入 PATH（例如 `sudo tar -xf zig-*.tar.xz -C /opt && sudo ln -s /opt/zig*/zig /usr/local/bin/zig`）；或 `sudo snap install zig --classic` |
| **unzip** | Mason 下载工具后解包（`:checkhealth mason` 的 core utils） | http://infozip.sourceforge.net/UnZip.html | `winget install --id GnuWin32.UnZip -e` | 多数发行版自带；缺则 Arch：`sudo pacman -S unzip` ／ Ubuntu：`sudo apt install unzip` ／ Fedora：`sudo dnf install unzip` |
| **gzip** | Mason core utils（解压 `.gz` / `.tar.gz`） | https://www.gnu.org/software/gzip/ | `winget install --id GnuWin32.Gzip -e` | 系统自带，无需安装 |
| **wget** | Mason core utils（下载；和 `curl` 有其一即可） | https://www.gnu.org/software/wget/ | `winget install --id JernejSimoncic.Wget -e` | 多数发行版自带；缺则 Arch：`sudo pacman -S wget` ／ Ubuntu：`sudo apt install wget` ／ Fedora：`sudo dnf install wget` |
| **7-Zip（`7z`）** | Mason core utils（解 `zip` / `7z` / `rar` 等） | https://www.7-zip.org/ | `winget install --id 7zip.7zip -e` | 有 unzip 即可，属可选：Arch：`sudo pacman -S 7zip` ／ Ubuntu：`sudo apt install 7zip` ／ Fedora：`sudo dnf install 7zip` |

> Windows 一次性装完 A 类（PowerShell 里复制执行）：
>
> ```powershell
> winget install --id Neovim.Neovim -e; winget install --id Git.Git -e; winget install --id BurntSushi.ripgrep.MSVC -e; winget install --id junegunn.fzf -e; winget install --id zig.zig -e; winget install --id GnuWin32.UnZip -e; winget install --id GnuWin32.Gzip -e; winget install --id JernejSimoncic.Wget -e; winget install --id 7zip.7zip -e
> ```
>
> 另加一条（winget 无包，需先有 Rust）：`cargo install tree-sitter-cli`

## B 类：强烈建议

| 工具 | 功能 | 主页 | Windows 安装（优先 winget） | Linux 安装（通用优先；无通用则分发行版） |
| --- | --- | --- | --- | --- |
| **fd** | fzf-lua 找文件的后端（比 `find` 快很多）；不装会回退到 `find`，仍可用 | https://github.com/sharkdp/fd | `winget install --id sharkdp.fd -e` | 通用：`cargo install fd-find`（注意 Ubuntu 包名是 `fd-find`，装出的命令叫 `fdfind`） |
| **lazygit** | 面板（dashboard）快捷键 `g` 直接调它打开 Git TUI | https://github.com/jesseduffield/lazygit | `winget install --id JesseDuffield.lazygit -e` | 通用：`go install github.com/jesseduffield/lazygit@latest` ／ Arch：`sudo pacman -S lazygit` ／ Ubuntu：`sudo apt install lazygit` ／ Fedora：`sudo dnf install lazygit` |
| **win32yank** | 用外部程序读写 Windows 剪贴板（Neovim 原生剪贴板也可用，想统一走 win32yank 时再装；仅 Windows 需要） | https://github.com/equalsraf/win32yank | `winget install --id equalsraf.win32yank -e` | 不需要（Linux 用内置 provider，或 `xclip` / `wl-clipboard`） |
| **lua-language-server** | Lua 的 LSP（本配置的 Lua 补全 / 诊断）：`lua/plugins/mason.lua` 会由 Mason 自动安装，此处为独立安装方式 | https://github.com/LuaLS/lua-language-server | `winget install --id LuaLS.lua-language-server -e` | 通用：从 GitHub Releases 下载解压（发行版仓库也有 `lua-language-server`） |
| **stylua** | Lua 格式化器：conform 的 `lua = { "stylua" }`，保存时自动格式化；Mason 会自动安装，此处为独立安装方式 | https://github.com/JohnnyMorganz/StyLua | `winget install --id JohnnyMorganz.StyLua -e` | 通用：`cargo install stylua` |
| **panache** | Markdown / Quarto / R Markdown 的 formatter + linter + language server：conform 的 `markdown = { "panache" }`、nvim-lint 的 `markdown = { "panache" }`；Mason 会自动安装，此处为独立安装方式 | https://github.com/jolars/panache | 通用：`cargo install panache`（或项目 Releases 的二进制）；winget 无此包 | 通用：`cargo install panache` |

## C 类：可选

| 工具 | 功能 | 主页 | Windows 安装（优先 winget） | Linux 安装（通用优先；无通用则分发行版） |
| --- | --- | --- | --- | --- |
| **Rust（rustup / cargo）** | 本身是 Mason 的「语言运行时」之一；更实际的作用是：本文档多个工具用它安装（`cargo install ripgrep / fd-find / stylua / tree-sitter-cli / panache`） | https://rustup.rs/ | `winget install --id Rustlang.Rustup -e` | 通用：官方脚本（`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && sh rustup.sh`）；发行版也有 `rustup` / `cargo` 包 |
| **Node.js / npm** | Mason 语言运行时；也是 `npm install -g` 系工具（如 trash-cli）的前提。启用 prettier 等前端格式化器会用到 | https://nodejs.org/ | `winget install --id OpenJS.NodeJS -e`（LTS 用 `OpenJS.NodeJS.LTS`） | 通用：Arch：`sudo pacman -S nodejs npm` ／ Ubuntu：`sudo apt install nodejs npm` ／ Fedora：`sudo dnf install nodejs npm` |
| **Python（含 venv）** | Mason 语言运行时。启用 `pyright` / `basedpyright` / `ty` / `ruff` 等 Python 工具时会用到 | https://www.python.org/ | `winget install --id Python.Python.3.13 -e` | 通用：多数发行版自带 `python3`；Ubuntu 需补 `sudo apt install python3-venv` |
| **Go** | Mason 语言运行时（如 gopls）；也是 `go install lazygit` 的前提 | https://go.dev/ | `winget install --id GoLang.Go -e` | 通用：Arch：`sudo pacman -S go` ／ Ubuntu：`sudo apt install golang-go` ／ Fedora：`sudo dnf install golang` |
| **LuaRocks** | Mason 语言运行时（Lua 相关工具依赖它） | https://luarocks.org/ | `winget install --id DEVCOM.Lua -e`（自带 Lua 5.4 + LuaRocks）；或从 luarocks.org 下载 zip 后加 PATH | 通用：Arch：`sudo pacman -S luarocks` ／ Ubuntu：`sudo apt install luarocks` ／ Fedora：`sudo dnf install luarocks` |
| **pwsh（PowerShell 7）** | neo-tree 把文件删到回收站的后端之一（Windows 自带的 Windows PowerShell 5.1 也可用） | https://github.com/PowerShell/PowerShell | `winget install --id Microsoft.PowerShell -e` | 通用：见官方 Releases；Ubuntu：`sudo snap install powershell --classic`；Fedora 加微软源后 `sudo dnf install powershell`；Arch 用 AUR 的 `powershell-bin` |
| **trash CLI** | neo-tree 的回收站后端（macOS / Linux 常用；Windows 用 pwsh 即可） | https://github.com/sindresorhus/trash | 需先有 Node → `npm install --global trash-cli` | 通用：`npm install --global trash-cli` |
| **clang / LLVM** | Treesitter parser 的备选编译器：只在不用 zig 时，把 `compilers` 改成 `{ "clang" }` 才需要 | https://llvm.org/ | `winget install --id LLVM.LLVM -e`（也可用 `BrechtSanders.WinLibs.*`） | 通用：Arch：`sudo pacman -S clang` ／ Ubuntu：`sudo apt install clang` ／ Fedora：`sudo dnf install clang` |
| **Ruby / PHP / Java / Julia 等** | `:checkhealth mason` 的 Languages 段会逐条列出，只有安装对应语言的 LSP / formatter 时才需要 | — | 需要时再装（如 Java：`winget install --id EclipseAdoptium.Temurin.21.JDK -e`） | 需要时再装（Ruby / PHP / Java / Julia 各自官方包） |

## 补充说明

- **`curl` / `tar` 一般不用装**：Windows 10 1803+ / Windows 11 自带（`C:\Windows\System32\curl.exe`、`tar.exe`），macOS / Linux 也自带，Mason 的下载链路靠它们。
- **Mason 自动安装的工具**：`stylua`、`lua-language-server`、`panache` 写在 `lua/plugins/mason.lua` 的 `ensure_installed` 里，首次启动 Neovim 会联网自动装到 Neovim 数据目录（其 `bin` 目录由 Neovim 自己加入 PATH）；上表列出独立安装方式，是为了在终端里也能直接用、或离线时手装。
- **winget 里没有的包**：`tree-sitter-cli`、`panache`、`trash-cli`、`luarocks` → 用 `cargo install` / `npm install -g` / 项目 Releases 的二进制。
- **Windows 装 Python 后**：到「设置 → 应用 → 高级应用设置 → 应用执行别名」里关掉 `python.exe` / `python3.exe`，否则 Mason 调到的是 Microsoft Store 的占位程序，会报 9009。
- **Linux 包名以发行版仓库为准**（Arch 用 `pacman`、Ubuntu 用 `apt`、Fedora 用 `dnf`）；有通用方式（cargo / npm / snap / 官方脚本 / 官方二进制）时只列一条。
- **装完外部工具要重开 Neovim**（PATH 只在进程启动时读取），再用 `:checkhealth`、`:checkhealth mason`、`:checkhealth nvim-treesitter` 复查。
- **启用注释里的工具时**：`lua/plugins/mason.lua` / `lua/plugins/conform.lua` 中注释掉的 `prettier`、`pyright`、`basedpyright`、`ty`、`ruff`、`taplo` 一旦启用，就需要 C 类里的 Node.js（prettier）或 Python（pyright / ruff）。
