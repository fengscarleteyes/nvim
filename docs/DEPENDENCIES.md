# Neovim 配置依赖清单

> 全新机器跑起这份配置前要装的外部工具。**按平台分章**：Windows 与 Arch Linux
> 是本配置的 目标平台，Ubuntu / Fedora 供参考。
>
> 每张表用「档」标注必要性：**A** 必需（不装会报错或核心功能失效）· **B**
> 强烈建议（不装会 退化）· **C** 可选（边缘功能或有替代品）。**D** 档与 Neovim
> 无关，单独成章。
>
> 平台表里没列出的工具，去「通用（跨平台命令）」章或「装到
> `~/.local/bin`」一节找：后者是 `lua-language-server` / `stylua` / `panache` /
> `ruff` / `basedpyright` 这 5 个的推荐装法。

## 安装优先级

1. 优先系统 / 发行版包管理器：Windows `winget`；Linux `pacman` / `apt` / `dnf` /
   `snap`
2. 其次语言包管理器：`uv tool`（Python）、`cargo` /
   `cargo binstall`（Rust）、`npm install -g`、`go install`
3. 最后手动下载官方 Releases，解压后放进 PATH（或按下面「装到
   `~/.local/bin`」一节处理）

## Windows

  | 档  | 工具                                                                                                                               | 功能                                                       | 安装                                                                 |
  | --- | ---                                                                                                                                | ---                                                        | ---                                                                  |
  | A   | [neovim](https://neovim.io/)                                                                                                       | 编辑器本体，需要 Neovim ≥ 0.12                             | `winget install --id Neovim.Neovim -e`                               |
  | A   | [git](https://git-scm.com/)                                                                                                        | gitsigns、fzf-lua、vim.pack、Treesitter 依赖               | `winget install --id Git.Git -e --source winget`                     |
  | A   | [ripgrep](https://github.com/BurntSushi/ripgrep)                                                                                   | fzf-lua 的 live_grep 后端                                  | `winget install --id BurntSushi.ripgrep.MSVC -e`                     |
  | A   | [fzf](https://github.com/junegunn/fzf)                                                                                             | fzf-lua 的模糊匹配后端                                     | `winget install --id junegunn.fzf -e`                                |
  | A   | [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md)                                     | Treesitter 编译 parser 需要（≥ 0.26.1，勿用 npm）          | 见「通用」章：`cargo install tree-sitter-cli`                        |
  | A   | [zig](https://ziglang.org/)                                                                                                        | 用 zig cc 编译 Treesitter parser                           | `winget install --id zig.zig -e`                                     |
  | A   | [curl](https://curl.se/)                                                                                                           | 下载归档 / 解析 release tag                                | 系统自带 `C:\Windows\System32\curl.exe`                              |
  | A   | [unzip](http://infozip.sourceforge.net/UnZip.html)                                                                                 | 解 zip                                                     | 无需安装：自带的 `tar.exe`（bsdtar）就能解 zip                       |
  | B   | [fd](https://github.com/sharkdp/fd)                                                                                                | fzf-lua 找文件后端                                         | `winget install --id sharkdp.fd -e`                                  |
  | B   | [lazygit](https://github.com/jesseduffield/lazygit)                                                                                | dashboard 快捷键 g 打开 Git TUI                            | `winget install --id JesseDuffield.lazygit -e`                       |
  | B   | [win32yank](https://github.com/equalsraf/win32yank)                                                                                | Windows 剪贴板读写（仅 Windows）                           | `winget install --id equalsraf.win32yank -e`                         |
  | B   | [lua-language-server](https://github.com/LuaLS/lua-language-server)                                                                | Lua 的 LSP                                                 | 见「装到 `~/.local/bin`」                                            |
  | B   | [stylua](https://github.com/JohnnyMorganz/StyLua)                                                                                  | Lua 格式化（conform 保存时调用）                           | 见「装到 `~/.local/bin`」                                            |
  | B   | [panache](https://github.com/jolars/panache)                                                                                       | Markdown formatter + linter                                | 见「装到 `~/.local/bin`」                                            |
  | B   | [ruff](https://github.com/astral-sh/ruff)                                                                                          | Python lint / format（conform + nvim-lint）                | 见「装到 `~/.local/bin`」                                            |
  | B   | [basedpyright](https://github.com/DetachHead/basedpyright)                                                                         | Python 的 LSP                                              | 见「装到 `~/.local/bin`」                                            |
  | C   | [Rust](https://rustup.rs/)                                                                                                         | `cargo install` 装上面多个工具的前提                       | `winget install --id Rustlang.Rustup -e`                             |
  | C   | [Node.js / npm](https://nodejs.org/)                                                                                               | `npm install -g` 工具和 prettier 需要                      | `winget install --id OpenJS.NodeJS -e`（LTS 用 `OpenJS.NodeJS.LTS`） |
  | C   | [Python](https://www.python.org/)                                                                                                  | pyright / ruff 等 Python 工具需要                          | `winget install --id Python.Python.3.13 -e`                          |
  | C   | [uv](https://docs.astral.sh/uv/)                                                                                                   | Python 包/项目管理器（可装 Python；也是 `uv tool` 的来源） | `winget install --id astral-sh.uv -e`                                |
  | C   | [Go](https://go.dev/)                                                                                                              | gopls 运行时，也是 `go install` 前提                       | `winget install --id GoLang.Go -e`                                   |
  | C   | [LuaRocks](https://luarocks.org/)                                                                                                  | Lua 相关工具运行环境                                       | `winget install --id DEVCOM.Lua -e`（自带 Lua 5.4 + LuaRocks）       |
  | C   | [pwsh](https://github.com/PowerShell/PowerShell)                                                                                   | neo-tree 回收站后端                                        | `winget install --id Microsoft.PowerShell -e`                        |
  | C   | [trash CLI](https://github.com/sindresorhus/trash)                                                                                 | neo-tree 回收站后端                                        | 不用装：Windows 用 pwsh 即可                                         |
  | C   | [clang / LLVM](https://llvm.org/)                                                                                                  | Treesitter parser 备选编译器                               | `winget install --id LLVM.LLVM -e`                                   |
  | C   | [Ruby](https://www.ruby-lang.org/) / [PHP](https://www.php.net/) / [Java](https://adoptium.net/) / [Julia](https://julialang.org/) | 装对应语言 LSP / formatter 才需要                          | Java：`winget install --id EclipseAdoptium.Temurin.21.JDK -e`        |
  | C   | [neovide](https://neovide.dev/)                                                                                                    | Neovim GUI 前端                                            | `winget install --id Neovide.Neovide -e`（纯终端用户不用装）         |

## Arch

  | 档  | 工具                                                                                                                               | 功能                                                       | 安装                                                                      |
  | --- | ---                                                                                                                                | ---                                                        | ---                                                                       |
  | A   | [neovim](https://neovim.io/)                                                                                                       | 编辑器本体，需要 Neovim ≥ 0.12                             | `sudo pacman -S neovim`                                                   |
  | A   | [git](https://git-scm.com/)                                                                                                        | gitsigns、fzf-lua、vim.pack、Treesitter 依赖               | `sudo pacman -S git`                                                      |
  | A   | [ripgrep](https://github.com/BurntSushi/ripgrep)                                                                                   | fzf-lua 的 live_grep 后端                                  | `sudo pacman -S ripgrep`                                                  |
  | A   | [fzf](https://github.com/junegunn/fzf)                                                                                             | fzf-lua 的模糊匹配后端                                     | `sudo pacman -S fzf`                                                      |
  | A   | [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md)                                     | Treesitter 编译 parser 需要（≥ 0.26.1，勿用 npm）          | `paru -S tree-sitter-cli`（AUR）                                          |
  | A   | [zig](https://ziglang.org/)                                                                                                        | 用 zig cc 编译 Treesitter parser                           | `sudo pacman -S zig`                                                      |
  | A   | [curl](https://curl.se/)                                                                                                           | 下载归档 / 解析 release tag                                | `sudo pacman -S curl`（一般已随系统安装）                                 |
  | A   | [unzip](http://infozip.sourceforge.net/UnZip.html)                                                                                 | 解 zip（Linux 上 stylua 的产物是 zip）                     | `sudo pacman -S unzip`                                                    |
  | B   | [fd](https://github.com/sharkdp/fd)                                                                                                | fzf-lua 找文件后端                                         | `sudo pacman -S fd`                                                       |
  | B   | [lazygit](https://github.com/jesseduffield/lazygit)                                                                                | dashboard 快捷键 g 打开 Git TUI                            | `sudo pacman -S lazygit`                                                  |
  | B   | [win32yank](https://github.com/equalsraf/win32yank)                                                                                | Windows 剪贴板读写                                         | 不适用：Linux 用 xclip / wl-clipboard                                     |
  | B   | [lua-language-server](https://github.com/LuaLS/lua-language-server)                                                                | Lua 的 LSP                                                 | `paru -S lua-language-server`（AUR），细节见「装到 `~/.local/bin`」       |
  | B   | [stylua](https://github.com/JohnnyMorganz/StyLua)                                                                                  | Lua 格式化（conform 保存时调用）                           | `sudo pacman -S stylua`；其他装法见「装到 `~/.local/bin`」                |
  | B   | [panache](https://github.com/jolars/panache)                                                                                       | Markdown formatter + linter                                | 见「装到 `~/.local/bin`」                                                 |
  | B   | [ruff](https://github.com/astral-sh/ruff)                                                                                          | Python lint / format（conform + nvim-lint）                | 见「装到 `~/.local/bin`」                                                 |
  | B   | [basedpyright](https://github.com/DetachHead/basedpyright)                                                                         | Python 的 LSP                                              | 见「装到 `~/.local/bin`」                                                 |
  | C   | [Rust](https://rustup.rs/)                                                                                                         | `cargo install` 装上面多个工具的前提                       | `sudo pacman -S rustup`                                                   |
  | C   | [Node.js / npm](https://nodejs.org/)                                                                                               | `npm install -g` 工具和 prettier 需要                      | `sudo pacman -S nodejs npm`                                               |
  | C   | [Python](https://www.python.org/)                                                                                                  | pyright / ruff 等 Python 工具需要                          | `sudo pacman -S python`                                                   |
  | C   | [uv](https://docs.astral.sh/uv/)                                                                                                   | Python 包/项目管理器（可装 Python；也是 `uv tool` 的来源） | `sudo pacman -S uv`                                                       |
  | C   | [Go](https://go.dev/)                                                                                                              | gopls 运行时，也是 `go install` 前提                       | `sudo pacman -S go`                                                       |
  | C   | [LuaRocks](https://luarocks.org/)                                                                                                  | Lua 相关工具运行环境                                       | `sudo pacman -S luarocks`                                                 |
  | C   | [pwsh](https://github.com/PowerShell/PowerShell)                                                                                   | neo-tree 回收站后端                                        | `paru -S powershell-bin`（AUR）                                           |
  | C   | [trash CLI](https://github.com/sindresorhus/trash)                                                                                 | neo-tree 回收站后端                                        | 见「通用」章：`npm install --global trash-cli`                            |
  | C   | [clang / LLVM](https://llvm.org/)                                                                                                  | Treesitter parser 备选编译器                               | `sudo pacman -S clang`                                                    |
  | C   | [Ruby](https://www.ruby-lang.org/) / [PHP](https://www.php.net/) / [Java](https://adoptium.net/) / [Julia](https://julialang.org/) | 装对应语言 LSP / formatter 才需要                          | `sudo pacman -S ruby php jdk-openjdk julia`                               |
  | C   | [neovide](https://neovide.dev/)                                                                                                    | Neovim GUI 前端                                            | `sudo pacman -S neovide`（X11 下还需 libxkbcommon-x11；纯终端用户不用装） |

## Ubuntu

  | 档  | 工具                                                                                                                               | 功能                                                       | 安装                                                                                            |
  | --- | ---                                                                                                                                | ---                                                        | ---                                                                                             |
  | A   | [neovim](https://neovim.io/)                                                                                                       | 编辑器本体，需要 Neovim ≥ 0.12                             | `sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim` |
  | A   | [git](https://git-scm.com/)                                                                                                        | gitsigns、fzf-lua、vim.pack、Treesitter 依赖               | `sudo apt install git`                                                                          |
  | A   | [ripgrep](https://github.com/BurntSushi/ripgrep)                                                                                   | fzf-lua 的 live_grep 后端                                  | `sudo apt install ripgrep`                                                                      |
  | A   | [fzf](https://github.com/junegunn/fzf)                                                                                             | fzf-lua 的模糊匹配后端                                     | `sudo apt install fzf`                                                                          |
  | A   | [curl](https://curl.se/)                                                                                                           | 下载归档 / 解析 release tag                                | `sudo apt install curl`（一般已随系统安装）                                                     |
  | A   | [unzip](http://infozip.sourceforge.net/UnZip.html)                                                                                 | 解 zip（Linux 上 stylua 的产物是 zip）                     | `sudo apt install unzip`                                                                        |
  | B   | [fd](https://github.com/sharkdp/fd)                                                                                                | fzf-lua 找文件后端                                         | `sudo apt install fd-find`（命令名是 `fdfind`）                                                 |
  | C   | [Rust](https://rustup.rs/)                                                                                                         | `cargo install` 装上面多个工具的前提                       | `sudo apt install rustup`                                                                       |
  | C   | [Node.js / npm](https://nodejs.org/)                                                                                               | `npm install -g` 工具和 prettier 需要                      | `sudo apt install nodejs npm`                                                                   |
  | C   | [Python](https://www.python.org/)                                                                                                  | pyright / ruff 等 Python 工具需要                          | `sudo apt install python3 python3-venv`                                                         |
  | C   | [uv](https://docs.astral.sh/uv/)                                                                                                   | Python 包/项目管理器（可装 Python；也是 `uv tool` 的来源） | `curl -LsSf https://astral.sh/uv/install.sh \| sh`                                              |
  | C   | [Go](https://go.dev/)                                                                                                              | gopls 运行时，也是 `go install` 前提                       | `sudo apt install golang-go`                                                                    |
  | C   | [LuaRocks](https://luarocks.org/)                                                                                                  | Lua 相关工具运行环境                                       | `sudo apt install luarocks`                                                                     |
  | C   | [clang / LLVM](https://llvm.org/)                                                                                                  | Treesitter parser 备选编译器                               | `sudo apt install clang`                                                                        |
  | C   | [Ruby](https://www.ruby-lang.org/) / [PHP](https://www.php.net/) / [Java](https://adoptium.net/) / [Julia](https://julialang.org/) | 装对应语言 LSP / formatter 才需要                          | `sudo apt install ruby php openjdk-21-jdk julia`                                                |

## Fedora

  | 档  | 工具                                                                                                                               | 功能                                                       | 安装                                                                                   |
  | --- | ---                                                                                                                                | ---                                                        | ---                                                                                    |
  | A   | [neovim](https://neovim.io/)                                                                                                       | 编辑器本体，需要 Neovim ≥ 0.12                             | `sudo dnf install neovim`                                                              |
  | A   | [git](https://git-scm.com/)                                                                                                        | gitsigns、fzf-lua、vim.pack、Treesitter 依赖               | `sudo dnf install git`                                                                 |
  | A   | [ripgrep](https://github.com/BurntSushi/ripgrep)                                                                                   | fzf-lua 的 live_grep 后端                                  | `sudo dnf install ripgrep`                                                             |
  | A   | [fzf](https://github.com/junegunn/fzf)                                                                                             | fzf-lua 的模糊匹配后端                                     | `sudo dnf install fzf`                                                                 |
  | A   | [zig](https://ziglang.org/)                                                                                                        | 用 zig cc 编译 Treesitter parser                           | `sudo dnf install zig`                                                                 |
  | A   | [curl](https://curl.se/)                                                                                                           | 下载归档 / 解析 release tag                                | `sudo dnf install curl`                                                                |
  | A   | [unzip](http://infozip.sourceforge.net/UnZip.html)                                                                                 | 解 zip（Linux 上 stylua 的产物是 zip）                     | `sudo dnf install unzip`                                                               |
  | B   | [fd](https://github.com/sharkdp/fd)                                                                                                | fzf-lua 找文件后端                                         | `sudo dnf install fd-find`                                                             |
  | B   | [lazygit](https://github.com/jesseduffield/lazygit)                                                                                | dashboard 快捷键 g 打开 Git TUI                            | `sudo dnf install lazygit`                                                             |
  | B   | [stylua](https://github.com/JohnnyMorganz/StyLua)                                                                                  | Lua 格式化（conform 保存时调用）                           | `sudo dnf install stylua`；其他装法见「装到 `~/.local/bin`」                           |
  | C   | [Rust](https://rustup.rs/)                                                                                                         | `cargo install` 装上面多个工具的前提                       | `sudo dnf install rustup`                                                              |
  | C   | [Node.js / npm](https://nodejs.org/)                                                                                               | `npm install -g` 工具和 prettier 需要                      | `sudo dnf install nodejs npm`                                                          |
  | C   | [Python](https://www.python.org/)                                                                                                  | pyright / ruff 等 Python 工具需要                          | `sudo dnf install python3`                                                             |
  | C   | [uv](https://docs.astral.sh/uv/)                                                                                                   | Python 包/项目管理器（可装 Python；也是 `uv tool` 的来源） | `sudo dnf install uv`                                                                  |
  | C   | [Go](https://go.dev/)                                                                                                              | gopls 运行时，也是 `go install` 前提                       | `sudo dnf install golang`                                                              |
  | C   | [LuaRocks](https://luarocks.org/)                                                                                                  | Lua 相关工具运行环境                                       | `sudo dnf install luarocks`                                                            |
  | C   | [pwsh](https://github.com/PowerShell/PowerShell)                                                                                   | neo-tree 回收站后端                                        | 加微软官方源后 `sudo dnf install powershell`                                           |
  | C   | [clang / LLVM](https://llvm.org/)                                                                                                  | Treesitter parser 备选编译器                               | `sudo dnf install clang`                                                               |
  | C   | [Ruby](https://www.ruby-lang.org/) / [PHP](https://www.php.net/) / [Java](https://adoptium.net/) / [Julia](https://julialang.org/) | 装对应语言 LSP / formatter 才需要                          | `sudo dnf install ruby php java-21-openjdk julia`                                      |
  | C   | [neovide](https://neovide.dev/)                                                                                                    | Neovim GUI 前端                                            | `sudo dnf copr enable agraven/neovide && sudo dnf install neovide`（纯终端用户不用装） |

## 通用（cargo / npm / go / snap / uv tool）

平台表里没有的工具用这里的命令；这几条不依赖发行版。

  | 档  | 工具                                                                                           | 功能                                                       | 安装                                                                                     |
  | --- | ---                                                                                            | ---                                                        | ---                                                                                      |
  | A   | [neovim](https://neovim.io/)                                                                   | 编辑器本体，需要 Neovim ≥ 0.12                             | `sudo snap install nvim --classic` 或官方 AppImage                                       |
  | A   | [ripgrep](https://github.com/BurntSushi/ripgrep)                                               | fzf-lua 的 live_grep 后端                                  | `cargo install ripgrep`                                                                  |
  | A   | [fzf](https://github.com/junegunn/fzf)                                                         | fzf-lua 的模糊匹配后端                                     | `go install github.com/junegunn/fzf@latest`                                              |
  | A   | [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) | Treesitter 编译 parser 需要（≥ 0.26.1，勿用 npm）          | `cargo install tree-sitter-cli`（需 Rust，见 C 档）                                      |
  | A   | [zig](https://ziglang.org/)                                                                    | 用 zig cc 编译 Treesitter parser                           | `sudo snap install zig --classic`（Ubuntu 用这条）                                       |
  | B   | [fd](https://github.com/sharkdp/fd)                                                            | fzf-lua 找文件后端                                         | `cargo install fd-find`                                                                  |
  | B   | [lazygit](https://github.com/jesseduffield/lazygit)                                            | dashboard 快捷键 g 打开 Git TUI                            | `go install github.com/jesseduffield/lazygit@latest` 或 `sudo snap install lazygit`      |
  | B   | [lua-language-server](https://github.com/LuaLS/lua-language-server)                            | Lua 的 LSP                                                 | 见「装到 `~/.local/bin`」                                                                |
  | B   | [stylua](https://github.com/JohnnyMorganz/StyLua)                                              | Lua 格式化（conform 保存时调用）                           | 见「装到 `~/.local/bin`」                                                                |
  | B   | [panache](https://github.com/jolars/panache)                                                   | Markdown formatter + linter                                | 见「装到 `~/.local/bin`」                                                                |
  | B   | [ruff](https://github.com/astral-sh/ruff)                                                      | Python lint / format（conform + nvim-lint）                | `uv tool install ruff`，细节见「装到 `~/.local/bin`」                                    |
  | B   | [basedpyright](https://github.com/DetachHead/basedpyright)                                     | Python 的 LSP                                              | `uv tool install basedpyright`，细节见「装到 `~/.local/bin`」                            |
  | C   | [Rust](https://rustup.rs/)                                                                     | `cargo install` 装上面多个工具的前提                       | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && sh rustup.sh` |
  | C   | [uv](https://docs.astral.sh/uv/)                                                               | Python 包/项目管理器（可装 Python；也是 `uv tool` 的来源） | `curl -LsSf https://astral.sh/uv/install.sh \| sh`（或 `pip install uv`）                |
  | C   | [pwsh](https://github.com/PowerShell/PowerShell)                                               | neo-tree 回收站后端                                        | `sudo snap install powershell --classic`（Ubuntu）                                       |
  | C   | [trash CLI](https://github.com/sindresorhus/trash)                                             | neo-tree 回收站后端                                        | `npm install --global trash-cli`（需 Node，见 C 档）                                     |
  | C   | [neovide](https://neovide.dev/)                                                                | Neovim GUI 前端                                            | 官方 Releases 下载二进制（纯终端用户不用装）                                             |

## 装到 `~/.local/bin`

`lua-language-server` / `stylua` / `panache` / `ruff` / `basedpyright` 这 5
个建议统一装到
**`~/.local/bin`**（Windows：`%USERPROFILE%\.local\bin`）。理由：两个平台的用户
PATH 里本就 有这个目录（`uv tool install` 的产物默认也落这里），装完**终端与
Neovim 都能直接解析**， 不需要改 `vim.env.PATH`。装完先确认能否解析：

```powershell
Get-Command stylua, panache, ruff, lua-language-server, basedpyright-langserver
```

```sh
command -v stylua panache ruff lua-language-server basedpyright-langserver
```

### ruff / basedpyright（两个平台完全相同）

```sh
uv tool install ruff
uv tool install basedpyright

# 也可以只装进项目内的 .venv（见根目录 pyproject.toml 的 dev 组）
uv add --dev ruff
uv add --dev basedpyright
```

`uv tool install` 默认就把可执行文件放进 `~/.local/bin`，无需额外参数；Neovim
用的是这一条。

### stylua

- <https://github.com/JohnnyMorganz/StyLua>

```shell
winget install --id JohnnyMorganz.StyLua -e

cargo install stylua

cargo binstall stylua

pip install git+https://github.com/johnnymorganz/stylua
uv tool install git+https://github.com/johnnymorganz/stylua
```

`cargo install` 需要链接器（MSVC / gcc），没装链接器的机器用 `cargo binstall`
走预编译产物， 详见「实测踩过的坑」第 2 条。

### panache

- <https://github.com/jolars/panache>

Windows PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://panache.bz/install.ps1 | iex"
```

macOS 与 Linux：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://panache.bz/install | sh
```

> 这两个 installer 内部用的是普通 `curl`（不带 `--ssl-no-revoke`），并会查
> GitHub API；在 访问不到证书吊销服务器、或 `api.github.com`
> 解析异常的机器上会失败。详见「实测踩过的坑」 第 1、6 条。

### lua-language-server

Windows：

```powershell
winget install --id LuaLS.lua-language-server -e --accept-package-agreements --accept-source-agreements
```

它会被装到
`%LOCALAPPDATA%\Microsoft\WinGet\Packages\LuaLS.lua-language-server_*\bin\`
下，但 **winget 不会建 shim**（见坑 3），所以要自己补一个
`%USERPROFILE%\.local\bin\lua-language-server.cmd`：

```bat
@echo off
"%LOCALAPPDATA%\Microsoft\WinGet\Packages\LuaLS.lua-language-server_Microsoft.Winget.Source_8wekyb3d8bbwe\bin\lua-language-server.exe" %*
```

Arch：

```sh
paru -S lua-language-server
```

AUR 包会装进 `/usr/bin`，那本就在 PATH 上，**不需要 shim**。

> `lua-language-server` 是**目录型**工具（运行时需要同目录的 `main.lua`、`meta/`
> 等），不能 只把 exe 复制出来单独放。

## D 额外：Pi 编码代理

与 Neovim 配置无关，想在终端用 AI 代理写代码时再装。

  | 档  | 工具                                                                       | 功能                                             | 安装                                                                                                                                                                                          |
  | --- | ---                                                                        | ---                                              | ---                                                                                                                                                                                           |
  | D   | [pi](https://pi.dev/)                                                      | 终端 AI 编码代理（Node 程序，要求 Node ≥ 22.19） | Windows：`powershell -c "irm https://pi.dev/install.ps1 \| iex"`，Linux：`curl -fsSL https://pi.dev/install.sh \| sh`，npm：`npm install -g --ignore-scripts @earendil-works/pi-coding-agent` |
  | D   | [vibekit](https://github.com/rizukirr/vibekit)                             | vibe coding 闸门（skill 流水线）                 | `pi install git:github.com/rizukirr/vibekit`                                                                                                                                                  |
  | D   | [pi-file-permissions](https://github.com/ross-jill-ws/pi-file-permissions) | 按路径限制内置文件工具                           | `pi install npm:pi-file-permissions`                                                                                                                                                          |

## 实测踩过的坑

1. **curl 必须加 `--ssl-no-revoke`。** 否则报
   `curl: (35) schannel: next InitializeSecurityContext failed: CRYPT_E_NO_REVOCATION_CHECK (0x80092012)`
   ------访问不到证书吊销服务器，一个字节都下不来。`cargo` / `winget` 用各自的
   TLS 栈，不受影响。
2. **`cargo install` 在没装链接器的机器上不可用。** 例如 `rustc` 的 host 是
   `x86_64-pc-windows-msvc`，但机器上没有 `link.exe` / `cl.exe` / VS Build Tools
   / gcc， 链接阶段必然失败。要装 Rust 程序就用
   `cargo binstall <crate>`（走预编译产物，需要已装
   `cargo-binstall`；`--install-path` 指定落点，`--disable-strategies compile`
   强制不走编译）。 注意 binstall 对这两个工具也不好用：`stylua`
   只能落到第三方镜像 QuickInstall（官方 crate-metadata 策略失败），`panache`
   **完全不行**（官方归档缺它自己声明的 `distill_quarto_schema` 二进制，binstall
   直接拒绝）。所以这两项直接下官方 release 最干净。
3. **winget 装 portable 包不会建 shim。** 创建 shim
   要符号链接权限，没权限就静默跳过，结果是 二进制躺在 `WinGet\Packages`
   里却不在 PATH 上。必须自己补 `.cmd` shim（或把该目录加进 PATH）。
4. **Neovim / libuv 认 `.cmd` shim。** `vim.fn.executable()` 与 `vim.system()`
   都会按 PATHEXT 找到 `.cmd` 并成功 spawn（mason 当年就是这么做的），所以第 3
   条的 shim 对 LSP 是可用的。
5. **PowerShell 5.1 用 ANSI 码页解码没有 BOM 的 `.ps1`。**
   中文注释会被误解码，视字节序列
   甚至**吞掉换行符、把多行粘成一行**，直接破坏语法。要写 `.ps1` 就只用
   ASCII，或存成 **带 BOM** 的 UTF-8。
6. **别用 GitHub API 查版本。** 部分网络下 `api.github.com` 解析异常。用
   `releases/latest` 的 302 `Location` 头解析 tag 更稳，也不需要 token。
7. **Linux 解压注意。** GNU tar 不能解 zip（Windows 自带的是 bsdtar 可以）；zip
   用 `unzip -o` 或 `bsdtar -xf`。从归档里解出/复制出来的二进制在 Linux 上**必须
   `chmod 755`**，否则不可执行。

## 补充说明

- Linux 包名以发行版仓库为准，个别版本会微调（如 Ubuntu 的 fd 包名是 fd-find）
- 装完外部工具重开 Neovim（PATH 只在启动时读取），再用
  `:checkhealth`、`:checkhealth nvim.treesitter` 与 `Get-Command <工具名>` 复查
- 用 Neovide 建议装一款 Nerd Font（tabline、winbar、listchars 用了图标字形）
