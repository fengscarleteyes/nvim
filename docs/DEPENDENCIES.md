# Neovim 配置依赖清单

> 全新机器跑起这份配置前要装的外部工具。按 A/B/C/D
> 四档必要性分章，每章先给工具总览（功能与主页），再按 Windows / Arch / Ubuntu /
> Fedora / 通用分安装表。优先用包管理器。D 类是与 Neovim 配置无关的终端 AI
> 代理，按需安装。

## 安装优先级

1. 系统 / 发行版包管理器：Windows `winget`，Linux `pacman`（Arch）/
   `apt`（Ubuntu）/ `dnf`（Fedora）/ `snap`
2. 语言包管理器：`cargo install`（Rust）、`npm install -g`（Node）、`go install`（Go）
3. Mason：`lua/plugins/mason.lua` 的 `ensure_installed` 已含
   `stylua`、`lua-language-server`、`panache`
4. 手动下载（官方 Releases / AppImage / 解压后加 PATH）

分类：A 必需（不装会报错或核心功能失效）· B
强烈建议（功能或快捷键依赖，不装会退化）· C 可选（边缘功能或有替代品）· D
额外（与 Neovim 无关）

## 目录

- A 必需（10）：neovim · git · ripgrep · fzf · tree-sitter-cli · zig · unzip ·
  gzip · wget · 7-Zip
- B 强烈建议（6）：fd · lazygit · win32yank · lua-language-server · stylua ·
  panache
- C 可选（11）：Rust · Node.js/npm · Python · uv · Go · LuaRocks · pwsh · trash
  CLI · clang/LLVM · Ruby/PHP/Java/Julia · neovide
- D 额外（3）：pi · vibekit · pi-file-permissions

## A 必需

  | 工具                                                                                           | 功能                                         | 备注               |
  | ---                                                                                            | ---                                          | ---                |
  | [neovim](https://neovim.io/)                                                                   | 编辑器本体，需要 Neovim ≥ 0.12               |                    |
  | [git](https://git-scm.com/)                                                                    | gitsigns、fzf-lua、vim.pack、Treesitter 依赖 |                    |
  | [ripgrep](https://github.com/BurntSushi/ripgrep)                                               | fzf-lua 的 live_grep 后端                    |                    |
  | [fzf](https://github.com/junegunn/fzf)                                                         | fzf-lua 的模糊匹配后端                       |                    |
  | [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) | Treesitter 编译 parser 需要                  | ≥ 0.26.1，勿用 npm |
  | [zig](https://ziglang.org/)                                                                    | 本配置用 zig cc 编译 Treesitter parser       |                    |
  | [unzip](http://infozip.sourceforge.net/UnZip.html)                                             | Mason 下载工具后解包                         |                    |
  | [gzip](https://www.gnu.org/software/gzip/)                                                     | Mason 解压 .gz / .tar.gz                     |                    |
  | [wget](https://www.gnu.org/software/wget/)                                                     | Mason 下载                                   | 和 curl 有其一即可 |
  | [7-Zip](https://www.7-zip.org/)                                                                | Mason 解 zip / 7z / rar                      |                    |

### Windows

  | 工具    | 安装                                                                      |
  | ---     | ---                                                                       |
  | neovim  | `winget install --id Neovim.Neovim -e`                                    |
  | git     | `winget install --id Git.Git -e --source winget`                          |
  | ripgrep | `winget install --id BurntSushi.ripgrep.MSVC -e`                          |
  | fzf     | `winget install --id junegunn.fzf -e`                                     |
  | zig     | `winget install --id zig.zig -e`                                          |
  | unzip   | `winget install --id GnuWin32.UnZip -e`                                   |
  | gzip    | `winget install --id GnuWin32.Gzip -e`                                    |
  | wget    | `winget install --id JernejSimoncic.Wget -e`（系统自带 curl，够用可不装） |
  | 7-Zip   | `winget install --id 7zip.7zip -e`                                        |

### Arch

  | 工具            | 安装                             |
  | --------------- | -------------------------------- |
  | neovim          | `sudo pacman -S neovim`          |
  | git             | `sudo pacman -S git`             |
  | ripgrep         | `sudo pacman -S ripgrep`         |
  | fzf             | `sudo pacman -S fzf`             |
  | tree-sitter-cli | `paru -S tree-sitter-cli`（AUR） |
  | zig             | `sudo pacman -S zig`             |
  | unzip           | `sudo pacman -S unzip`           |
  | gzip            | `sudo pacman -S gzip`            |
  | wget            | `sudo pacman -S wget`            |
  | 7-Zip           | `sudo pacman -S 7zip`            |

### Ubuntu

  | 工具    | 安装                                                                                            |
  | ---     | ---                                                                                             |
  | neovim  | `sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim` |
  | git     | `sudo apt install git`                                                                          |
  | ripgrep | `sudo apt install ripgrep`                                                                      |
  | fzf     | `sudo apt install fzf`                                                                          |
  | unzip   | `sudo apt install unzip`                                                                        |
  | gzip    | `sudo apt install gzip`                                                                         |
  | wget    | `sudo apt install wget`                                                                         |
  | 7-Zip   | `sudo apt install 7zip`                                                                         |

### Fedora

  | 工具    | 安装                       |
  | ------- | -------------------------- |
  | neovim  | `sudo dnf install neovim`  |
  | git     | `sudo dnf install git`     |
  | ripgrep | `sudo dnf install ripgrep` |
  | fzf     | `sudo dnf install fzf`     |
  | zig     | `sudo dnf install zig`     |
  | unzip   | `sudo dnf install unzip`   |
  | gzip    | `sudo dnf install gzip`    |
  | wget    | `sudo dnf install wget`    |
  | 7-Zip   | `sudo dnf install p7zip`   |

### 通用（cargo / npm / go / snap / Mason）

  | 工具            | 安装                                               |
  | --------------- | -------------------------------------------------- |
  | neovim          | `sudo snap install nvim --classic` 或官方 AppImage |
  | ripgrep         | `cargo install ripgrep`                            |
  | fzf             | `go install github.com/junegunn/fzf@latest`        |
  | tree-sitter-cli | `cargo install tree-sitter-cli`（需 Rust，见 C1）  |
  | zig             | `sudo snap install zig --classic`（Ubuntu 用这条） |

## B 强烈建议

  | 工具                                                                | 功能                             | 备注                                        |
  | ---                                                                 | ---                              | ---                                         |
  | [fd](https://github.com/sharkdp/fd)                                 | fzf-lua 找文件后端               |                                             |
  | [lazygit](https://github.com/jesseduffield/lazygit)                 | dashboard 快捷键 g 打开 Git TUI  |                                             |
  | [win32yank](https://github.com/equalsraf/win32yank)                 | Windows 剪贴板读写               | 仅 Windows，Linux 可选 xclip / wl-clipboard |
  | [lua-language-server](https://github.com/LuaLS/lua-language-server) | Lua 的 LSP                       | 本配置已由 Mason 自动装，可跳过手动         |
  | [stylua](https://github.com/JohnnyMorganz/StyLua)                   | Lua 格式化（conform 保存时调用） | 本配置已由 Mason 自动装，可跳过手动         |
  | [panache](https://github.com/jolars/panache)                        | Markdown formatter + linter      | 本配置已由 Mason 自动装，可跳过手动         |
  | [basedpyright](https://github.com/DetachHead/basedpyright)          | Python 的 LSP                    | 由 uv 提供，不装则 Python 无补全 / 类型检查 |

### Windows

  | 工具                | 安装                                               |
  | ---                 | ---                                                |
  | fd                  | `winget install --id sharkdp.fd -e`                |
  | lazygit             | `winget install --id JesseDuffield.lazygit -e`     |
  | win32yank           | `winget install --id equalsraf.win32yank -e`       |
  | lua-language-server | `winget install --id LuaLS.lua-language-server -e` |
  | stylua              | `winget install --id JohnnyMorganz.StyLua -e`      |

### Arch

  | 工具                | 安装                                 |
  | ------------------- | ------------------------------------ |
  | fd                  | `sudo pacman -S fd`                  |
  | lazygit             | `sudo pacman -S lazygit`             |
  | lua-language-server | `paru -S lua-language-server`（AUR） |
  | stylua              | `sudo pacman -S stylua`              |

### Ubuntu

  | 工具 | 安装                                        |
  | ---- | ------------------------------------------- |
  | fd   | `sudo apt install fd-find`（命令名 fdfind） |

### Fedora

  | 工具    | 安装                       |
  | ------- | -------------------------- |
  | fd      | `sudo dnf install fd-find` |
  | lazygit | `sudo dnf install lazygit` |
  | stylua  | `sudo dnf install stylua`  |

### 通用（cargo / npm / go / snap / Mason）

  | 工具                | 安装                                                                                 |
  | ---                 | ---                                                                                  |
  | fd                  | `cargo install fd-find`                                                              |
  | lazygit             | `go install github.com/jesseduffield/lazygit@latest` 或 `sudo snap install lazygit`  |
  | lua-language-server | Mason `:MasonInstall lua-language-server`                                            |
  | stylua              | `cargo install stylua` 或 Mason                                                      |
  | panache             | `cargo install panache`（需 Rust，见 C1）或 Mason                                    |
  | basedpyright        | `uv add --dev basedpyright` 或 `uv tool install basedpyright`                        |

## C 可选

  | 工具                                                                                                                               | 功能                                | 备注                 |
  | ---                                                                                                                                | ---                                 | ---                  |
  | [Rust](https://rustup.rs/)                                                                                                         | cargo install 装上面多个工具的前提  |                      |
  | [Node.js / npm](https://nodejs.org/)                                                                                               | npm install -g 工具和 prettier 需要 |                      |
  | [Python](https://www.python.org/)                                                                                                  | pyright / ruff 等 Python 工具需要   |                      |
  | [uv](https://docs.astral.sh/uv/)                                                                                                   | Python 包/项目管理器（可装 Python） | 替代 pip/venv/pyenv  |
  | [Go](https://go.dev/)                                                                                                              | gopls 运行时，也是 go install 前提  |                      |
  | [LuaRocks](https://luarocks.org/)                                                                                                  | Lua 相关工具运行环境                |                      |
  | [pwsh](https://github.com/PowerShell/PowerShell)                                                                                   | neo-tree 回收站后端                 |                      |
  | [trash CLI](https://github.com/sindresorhus/trash)                                                                                 | neo-tree 回收站后端                 | Windows 用 pwsh 即可 |
  | [clang / LLVM](https://llvm.org/)                                                                                                  | Treesitter parser 备选编译器        |                      |
  | [Ruby](https://www.ruby-lang.org/) / [PHP](https://www.php.net/) / [Java](https://adoptium.net/) / [Julia](https://julialang.org/) | 装对应语言 LSP / formatter 才需要   |                      |
  | [neovide](https://neovide.dev/)                                                                                                    | Neovim GUI 前端                     | 纯终端用户不用装     |

### Windows

  | 工具                      | 安装                                                               |
  | ---                       | ---                                                                |
  | Rust                      | `winget install --id Rustlang.Rustup -e`                           |
  | Node.js / npm             | `winget install --id OpenJS.NodeJS -e`（LTS 用 OpenJS.NodeJS.LTS） |
  | Python                    | `winget install --id Python.Python.3.13 -e`                        |
  | uv                        | `winget install --id astral-sh.uv -e`                              |
  | Go                        | `winget install --id GoLang.Go -e`                                 |
  | LuaRocks                  | `winget install --id DEVCOM.Lua -e`（自带 Lua 5.4 + LuaRocks）     |
  | pwsh                      | `winget install --id Microsoft.PowerShell -e`                      |
  | clang / LLVM              | `winget install --id LLVM.LLVM -e`                                 |
  | Ruby / PHP / Java / Julia | Java：`winget install --id EclipseAdoptium.Temurin.21.JDK -e`      |
  | neovide                   | `winget install --id Neovide.Neovide -e`                           |

### Arch

  | 工具                      | 安装                                                    |
  | ---                       | ---                                                     |
  | Rust                      | `sudo pacman -S rustup`                                 |
  | Node.js / npm             | `sudo pacman -S nodejs npm`                             |
  | Python                    | `sudo pacman -S python`                                 |
  | uv                        | `sudo pacman -S uv`                                     |
  | Go                        | `sudo pacman -S go`                                     |
  | LuaRocks                  | `sudo pacman -S luarocks`                               |
  | pwsh                      | `paru -S powershell-bin`（AUR）                         |
  | clang / LLVM              | `sudo pacman -S clang`                                  |
  | Ruby / PHP / Java / Julia | `sudo pacman -S ruby php jdk-openjdk julia`             |
  | neovide                   | `sudo pacman -S neovide`（X11 下还需 libxkbcommon-x11） |

### Ubuntu

  | 工具                      | 安装                                               |
  | ---                       | ---                                                |
  | Rust                      | `sudo apt install rustup`                          |
  | Node.js / npm             | `sudo apt install nodejs npm`                      |
  | Python                    | `sudo apt install python3 python3-venv`            |
  | uv                        | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
  | Go                        | `sudo apt install golang-go`                       |
  | LuaRocks                  | `sudo apt install luarocks`                        |
  | clang / LLVM              | `sudo apt install clang`                           |
  | Ruby / PHP / Java / Julia | `sudo apt install ruby php openjdk-21-jdk julia`   |

### Fedora

  | 工具                      | 安装                                                               |
  | ---                       | ---                                                                |
  | Rust                      | `sudo dnf install rustup`                                          |
  | Node.js / npm             | `sudo dnf install nodejs npm`                                      |
  | Python                    | `sudo dnf install python3`                                         |
  | uv                        | `sudo dnf install uv`                                              |
  | Go                        | `sudo dnf install golang`                                          |
  | LuaRocks                  | `sudo dnf install luarocks`                                        |
  | pwsh                      | 加微软官方源后 `sudo dnf install powershell`                       |
  | clang / LLVM              | `sudo dnf install clang`                                           |
  | Ruby / PHP / Java / Julia | `sudo dnf install ruby php java-21-openjdk julia`                  |
  | neovide                   | `sudo dnf copr enable agraven/neovide && sudo dnf install neovide` |

### 通用（cargo / npm / go / snap / Mason）

  | 工具      | 安装                                                                                     |
  | ---       | ---                                                                                      |
  | Rust      | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && sh rustup.sh` |
  | uv        | `curl -LsSf https://astral.sh/uv/install.sh \| sh`（或 `pip install uv`）                |
  | pwsh      | `sudo snap install powershell --classic`（Ubuntu）                                       |
  | trash CLI | `npm install --global trash-cli`（需 Node，见 C2）                                       |
  | neovide   | 官方 Releases 下载二进制                                                                 |

## D 额外：Pi 编码代理

与 Neovim 配置无关，想在终端用 AI 代理写代码时再装。

  | 工具                                                                       | 功能                                             | 安装                                                                                                                                                                                          |
  | ---                                                                        | ---                                              | ---                                                                                                                                                                                           |
  | [pi](https://pi.dev/)                                                      | 终端 AI 编码代理（Node 程序，要求 Node ≥ 22.19） | Windows：`powershell -c "irm https://pi.dev/install.ps1 \| iex"`，Linux：`curl -fsSL https://pi.dev/install.sh \| sh`，npm：`npm install -g --ignore-scripts @earendil-works/pi-coding-agent` |
  | [vibekit](https://github.com/rizukirr/vibekit)                             | vibe coding 闸门（skill 流水线）                 | `pi install git:github.com/rizukirr/vibekit`                                                                                                                                                  |
  | [pi-file-permissions](https://github.com/ross-jill-ws/pi-file-permissions) | 按路径限制内置文件工具                           | `pi install npm:pi-file-permissions`                                                                                                                                                          |

## 补充说明

- Linux 包名以发行版仓库为准，个别版本会微调（如 Fedora 的 7-Zip 包名是 p7zip）
- 装完外部工具重开 Neovim（PATH 只在启动时读取），再用
  :checkhealth、:checkhealth mason、:checkhealth nvim-treesitter 复查
- 用 Neovide 建议装一款 Nerd Font（tabline、winbar、listchars 用了图标字形）
