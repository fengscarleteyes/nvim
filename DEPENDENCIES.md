# Neovim 配置依赖工具清单（全新机器配置用）

> 用途：在一台**全新电脑**上把这份 Neovim 配置完整跑起来时，需要预先安装的外部工具。
> 依据：`:checkhealth`（vim.health / vim.provider / lsp / mason / nvim-treesitter / conform / nvim-lint / neo-tree / fzf-lua）＋ 配置文件里的硬性要求（`lua/plugins/*.lua`、`lua/custom/*.lua`）。
> 写法：每个工具一个小节，固定四行 —— **功能 · 主页 · Windows 安装 · Linux 安装**；安装方式**优先包管理器**，Linux 按发行版分行缩进列出。

## 安装方式优先级

按下面顺序选，能用上一级就不用下一级：

1. **系统 / 发行版包管理器**：Windows —— `winget`；Linux —— `pacman`（Arch）/ `apt`（Ubuntu）/ `dnf`（Fedora）/ `snap`
2. **语言包管理器**：`cargo install`（Rust）/ `npm install -g`（Node）/ `go install`（Go）
3. **Neovim 内的 Mason**：本配置 `lua/plugins/mason.lua` 的 `ensure_installed` 已含 `stylua`、`lua-language-server`、`panache`，首次启动会自动装
4. **手动下载**（官方 Releases / AppImage / 解压后加入 PATH）：仅当前三级都没有时

优先级图例：

- **A 必需**：不装，配置会报错或核心功能直接失效
- **B 强烈建议**：配置里的功能 / 快捷键依赖它，不装会明显退化
- **C 可选**：只影响边缘功能，或有替代品可用

## 目录

- **A 必需（10）**：neovim · git · ripgrep · fzf · tree-sitter-cli · zig · unzip · gzip · wget · 7-Zip
- **B 强烈建议（6）**：fd · lazygit · win32yank · lua-language-server · stylua · panache
- **C 可选（9）**：Rust · Node.js/npm · Python · Go · LuaRocks · pwsh · trash CLI · clang/LLVM · Ruby/PHP/Java/Julia

## A 类：必需

### A1. neovim

- **功能**：编辑器本体。本配置用了 `vim.pack.add`（`lua/plugins/*.lua`）、`vim.health`、原生剪贴板等，需要 **Neovim ≥ 0.12**
- **主页**：https://neovim.io/
- **Windows 安装**：`winget install --id Neovim.Neovim -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S neovim`
  - Ubuntu：`sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim`
  - Fedora：`sudo dnf install neovim`
  - 通用：`sudo snap install nvim --classic`（或官方 AppImage）

### A2. git

- **功能**：版本控制；gitsigns、fzf-lua 的 git 功能、`vim.pack` 插件管理、Treesitter 的 `require("nvim-treesitter.install").prefer_git = true` 都依赖它
- **主页**：https://git-scm.com/
- **Windows 安装**：`winget install --id Git.Git -e`
- **Linux 安装**（三发行版同名包 `git`）：
  - Arch：`sudo pacman -S git`
  - Ubuntu：`sudo apt install git`
  - Fedora：`sudo dnf install git`

### A3. ripgrep（`rg`）

- **功能**：全文搜索后端：fzf-lua 的 `live_grep` / grep；也是 `:checkhealth vim.health` 的 External Tools 之一
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

- **功能**：nvim-treesitter 安装 / 编译 parser 必需（要求 **≥ 0.26.1**；官方说明用包管理器安装，**不要用 npm**）
- **主页**：https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md
- **Windows 安装**：winget 无此包 → 用语言包管理器：`cargo install tree-sitter-cli`（需先装 Rust，见 C1）
- **Linux 安装**：
  - Arch：AUR —— `paru -S tree-sitter-cli`（或 `yay -S tree-sitter-cli`）
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

- **功能**：本配置指定用它编译 Treesitter parser：`require("nvim-treesitter.install").compilers = { "zig" }`（即 `zig cc`）
- **主页**：https://ziglang.org/
- **Windows 安装**：`winget install --id zig.zig -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S zig`
  - Fedora：`sudo dnf install zig`
  - 通用：`sudo snap install zig --classic`（Ubuntu 用这条；也可从 ziglang.org 下 tar.xz 解压后加 PATH）

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
- **Windows 安装**：`winget install --id JernejSimoncic.Wget -e`（系统自带 `curl`，够用可不装）
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

- **功能**：fzf-lua 找文件的后端（比 `find` 快很多）；不装会回退到 `find`，仍可用
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
  - 通用：`go install github.com/jesseduffield/lazygit@latest`，或 `sudo snap install lazygit`

### B3. win32yank（仅 Windows 需要）

- **功能**：用外部程序读写 Windows 剪贴板（Neovim 原生剪贴板也可用，想统一走 win32yank 时再装）
- **主页**：https://github.com/equalsraf/win32yank
- **Windows 安装**：`winget install --id equalsraf.win32yank -e`
- **Linux 安装**：不需要 —— Neovim 用内置剪贴板 provider；X11 / Wayland 下可选装 `xclip` / `wl-clipboard`：
  - Arch：`sudo pacman -S xclip wl-clipboard`
  - Ubuntu：`sudo apt install xclip wl-clipboard`
  - Fedora：`sudo dnf install xclip wl-clipboard`

### B4. lua-language-server

- **功能**：Lua 的 LSP（本配置的 Lua 补全 / 诊断）
- **主页**：https://github.com/LuaLS/lua-language-server
- **Windows 安装**：`winget install --id LuaLS.lua-language-server -e`
- **Linux 安装**：
  - Arch：AUR —— `paru -S lua-language-server`（或从发行版仓库装 `lua-language-server`）
  - 通用：Mason —— Neovim 里 `:MasonInstall lua-language-server`（本配置已自动安装）

### B5. stylua

- **功能**：Lua 格式化器：conform 的 `lua = { "stylua" }`，保存时自动格式化
- **主页**：https://github.com/JohnnyMorganz/StyLua
- **Windows 安装**：`winget install --id JohnnyMorganz.StyLua -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S stylua`
  - Fedora：`sudo dnf install stylua`
  - 通用：`cargo install stylua`，或 Mason —— `:MasonInstall stylua`（本配置已自动安装）

### B6. panache

- **功能**：Markdown / Quarto / R Markdown 的 formatter + linter + language server：conform 的 `markdown = { "panache" }`、nvim-lint 的 `markdown = { "panache" }`
- **主页**：https://github.com/jolars/panache
- **Windows 安装**：winget 无此包 → 用语言包管理器：`cargo install panache`（需先装 Rust，见 C1）
- **Linux 安装**：
  - 通用：`cargo install panache`，或 Mason —— `:MasonInstall panache`（本配置已自动安装）
  - Arch / Ubuntu / Fedora：发行版仓库暂无，必要时从项目 Releases 取二进制

## C 类：可选

### C1. Rust（rustup / cargo）

- **功能**：Mason 的「语言运行时」之一；更实用的是它自带 `cargo` —— 上面多个工具靠 `cargo install` 安装（ripgrep / fd-find / stylua / tree-sitter-cli / panache）
- **主页**：https://rustup.rs/
- **Windows 安装**：`winget install --id Rustlang.Rustup -e`
- **Linux 安装**（三发行版同名包 `rustup`）：
  - Arch：`sudo pacman -S rustup`
  - Ubuntu：`sudo apt install rustup`
  - Fedora：`sudo dnf install rustup`
  - 通用：官方脚本 —— `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && sh rustup.sh`

### C2. Node.js / npm

- **功能**：Mason 语言运行时；`npm install -g` 系工具（如 trash-cli）的前提，启用 prettier 等前端格式化器也会用到
- **主页**：https://nodejs.org/
- **Windows 安装**：`winget install --id OpenJS.NodeJS -e`（LTS 用 `OpenJS.NodeJS.LTS`）
- **Linux 安装**（同行列出 `nodejs` + `npm`）：
  - Arch：`sudo pacman -S nodejs npm`
  - Ubuntu：`sudo apt install nodejs npm`
  - Fedora：`sudo dnf install nodejs npm`

### C3. Python（含 venv）

- **功能**：Mason 语言运行时。启用 `pyright` / `basedpyright` / `ty` / `ruff` 等 Python 工具时会用到
- **主页**：https://www.python.org/
- **Windows 安装**：`winget install --id Python.Python.3.13 -e`
- **Linux 安装**（多数发行版已预装 `python3`）：
  - Arch：`sudo pacman -S python`
  - Ubuntu：`sudo apt install python3 python3-venv`
  - Fedora：`sudo dnf install python3`

### C4. Go

- **功能**：Mason 语言运行时（如 gopls）；也是用 `go install` 装 fd / lazygit 的前提
- **主页**：https://go.dev/
- **Windows 安装**：`winget install --id GoLang.Go -e`
- **Linux 安装**：
  - Arch：`sudo pacman -S go`
  - Ubuntu：`sudo apt install golang-go`
  - Fedora：`sudo dnf install golang`

### C5. LuaRocks

- **功能**：Mason 语言运行时（Lua 相关工具依赖它）
- **主页**：https://luarocks.org/
- **Windows 安装**：`winget install --id DEVCOM.Lua -e`（winget 没有单独的 `luarocks` 包，这个包自带 Lua 5.4 + LuaRocks）
- **Linux 安装**（三发行版同名包 `luarocks`）：
  - Arch：`sudo pacman -S luarocks`
  - Ubuntu：`sudo apt install luarocks`
  - Fedora：`sudo dnf install luarocks`

### C6. pwsh（PowerShell 7）

- **功能**：neo-tree 把文件删到回收站的后端之一（Windows 自带的 Windows PowerShell 5.1 也可用）
- **主页**：https://github.com/PowerShell/PowerShell
- **Windows 安装**：`winget install --id Microsoft.PowerShell -e`
- **Linux 安装**：
  - Arch：AUR —— `paru -S powershell-bin`
  - Ubuntu：`sudo snap install powershell --classic`
  - Fedora：先加微软官方源，再 `sudo dnf install powershell`

### C7. trash CLI

- **功能**：neo-tree 的回收站后端（macOS / Linux 常用；Windows 用 pwsh 即可）
- **主页**：https://github.com/sindresorhus/trash
- **Windows 安装**：需先有 Node（见 C2）—— `npm install --global trash-cli`
- **Linux 安装**：
  - 通用：`npm install --global trash-cli`（需先有 Node，见 C2）
  - 发行版仓库的同名包 `trash-cli` 是另一个实现（命令为 `trash-put`），不一定兼容本工具，建议用上面的 npm 方式

### C8. clang / LLVM

- **功能**：Treesitter parser 的备选编译器：只在不用 zig 时，把 `compilers` 改成 `{ "clang" }` 才需要
- **主页**：https://llvm.org/
- **Windows 安装**：`winget install --id LLVM.LLVM -e`（也可用 `BrechtSanders.WinLibs.*`）
- **Linux 安装**（三发行版同名包 `clang`）：
  - Arch：`sudo pacman -S clang`
  - Ubuntu：`sudo apt install clang`
  - Fedora：`sudo dnf install clang`

### C9. Ruby / PHP / Java / Julia 等

- **功能**：`:checkhealth mason` 的 Languages 段会逐条列出，只有安装对应语言的 LSP / formatter 时才需要
- **主页**：各语言官网 —— Ruby：https://www.ruby-lang.org/ ／ PHP：https://www.php.net/ ／ Java：https://adoptium.net/ ／ Julia：https://julialang.org/
- **Windows 安装**：需要时再装（如 Java：`winget install --id EclipseAdoptium.Temurin.21.JDK -e`）
- **Linux 安装**：需要时用发行版包管理器装：
  - Arch：`sudo pacman -S ruby php jdk-openjdk julia`
  - Ubuntu：`sudo apt install ruby php openjdk-21-jdk julia`
  - Fedora：`sudo dnf install ruby php java-21-openjdk julia`

## 补充说明

- **Linux 包名以发行版仓库为准**：上面用的都是各发行版包管理器，个别包名在不同版本里会有微调（例如 Fedora 的 7-Zip 包名是 `p7zip`）。
- **装完外部工具要重开 Neovim**（PATH 只在进程启动时读取），再用 `:checkhealth`、`:checkhealth mason`、`:checkhealth nvim-treesitter` 复查。
