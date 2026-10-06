# 外部工具的安装参考

本仓库**不再自带工具安装器**：曾经的 `lua/custom/tools.lua` + `scripts/tools.*`
已移除， `mason.nvim` 也已停用（见 `lua/plugins/bak/mason.lua`）。LSP / 格式化 /
lint 用到的外部
工具改为**手动安装**，本文记录落点、每个工具的权威渠道，以及实测定下来的命令与坑。

整机清单与 A/B/C/D 分档见
`docs/DEPENDENCIES.md`，**本文不复制那份清单**（复制来的副本 一定会过期）。

## 落点：`~/.local/bin`

  | 平台    | 路径                       |
  | ------- | -------------------------- |
  | Windows | `%USERPROFILE%\.local\bin` |
  | Linux   | `~/.local/bin`             |

选它的理由：两个平台的用户 PATH 里**本来就有**这个目录（`uv tool install`
的产物默认也 落这里），所以装完之后**终端与 Neovim 都能直接解析**，不需要改
`vim.env.PATH`、也不需要 任何只在编辑器内生效的补丁。装完用下面的命令确认：

```powershell
Get-Command stylua, panache, ruff, lua-language-server, basedpyright-langserver
```

```sh
command -v stylua panache ruff lua-language-server basedpyright-langserver
```

## 工具与渠道

  | 工具                | 用途                                                                  | 权威渠道                               | 归档 / 包名                                                                      |
  | ---                 | ---                                                                   | ---                                    | ---                                                                              |
  | stylua              | Lua 格式化（conform 保存时调用）                                      | 官方 GitHub release                    | `stylua-windows-x86_64.zip` / `stylua-linux-x86_64.zip`                          |
  | panache             | Markdown formatter + linter + LSP                                     | 官方 GitHub release                    | `panache-x86_64-pc-windows-msvc.zip` / `panache-x86_64-unknown-linux-gnu.tar.gz` |
  | ruff                | Python lint / format（conform + nvim-lint）                           | `uv tool`                              | 包名 `ruff`                                                                      |
  | basedpyright        | Python LSP（`nvim-lspconfig.lua` 实际调用 `basedpyright-langserver`） | `uv tool`                              | 包名 `basedpyright`                                                              |
  | lua-language-server | Lua LSP                                                               | Windows: `winget`；Arch: AUR（`paru`） | `LuaLS.lua-language-server`                                                      |

Linux 侧写的是 glibc 产物（Arch / Ubuntu / Fedora 都是）。Alpine 等 musl
发行版把 stylua 换成 `stylua-linux-x86_64-musl.zip`、panache 换成
`panache-x86_64-unknown-linux-musl.tar.gz`。

## 逐个安装

### ruff / basedpyright（两个平台完全相同）

```sh
uv tool install ruff
uv tool install basedpyright
```

`uv tool install` 默认就把可执行文件放进 `~/.local/bin`，无需额外参数。

### stylua

Windows：

```powershell
$zip = "$env:TEMP\stylua.zip"
curl --ssl-no-revoke -fsSL -o $zip https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-windows-x86_64.zip
tar.exe -xf $zip -C "$env:USERPROFILE\.local\bin"
```

Linux（注意 GNU tar **不能**解 zip，要用 `unzip` 或
`bsdtar`，且必须补可执行位）：

```sh
curl --ssl-no-revoke -fsSL -o /tmp/stylua.zip https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-linux-x86_64.zip
mkdir -p ~/.local/bin
unzip -oq /tmp/stylua.zip -d ~/.local/bin
chmod 755 ~/.local/bin/stylua
```

`stylua` 的 asset 名**不含版本号**，所以可以直接用
`releases/latest/download/<asset>` 这个 免版本端点。

### panache

它的 asset 名也**不含版本号**，但版本号在下载路径里，所以要先从
`releases/latest` 的 302 跳转里把 tag 读出来（不要用 GitHub API，见下文坑 6）：

```sh
tag=$(curl --ssl-no-revoke -sIL -o /dev/null -w '%{url_effective}' \
  https://github.com/jolars/panache/releases/latest | sed 's#.*/tag/##')
# Linux
curl --ssl-no-revoke -fsSL -o /tmp/panache.tar.gz \
  "https://github.com/jolars/panache/releases/download/$tag/panache-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/panache.tar.gz -C ~/.local/bin
chmod 755 ~/.local/bin/panache
```

Windows 把最后的 asset 换成 `panache-x86_64-pc-windows-msvc.zip`，用
`tar.exe -xf` 解到 `%USERPROFILE%\.local\bin`即可（Windows 自带的是 bsdtar，能解
zip）。

上游还发布 `panache-installer.sh` / `panache-installer.ps1`，落点默认就是
`~/.local/bin`， 但它们的下载用的是**不带 `--ssl-no-revoke` 的
curl**，在本机会直接失败（见坑 1），所以这里 自己下载更稳。

### lua-language-server

Windows：

```powershell
winget install --id LuaLS.lua-language-server -e --accept-package-agreements --accept-source-agreements
```

它会被装到
`%LOCALAPPDATA%\Microsoft\WinGet\Packages\LuaLS.lua-language-server_*\bin\` 下，
但 **winget 不会建 shim**（见坑 3），所以要自己补一个
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
> 等）， 不能只把 exe 复制出来单独放。

## 实测踩过的坑

1. **本机 curl 必须加 `--ssl-no-revoke`。** 否则报
   `curl: (35) schannel: next InitializeSecurityContext failed: CRYPT_E_NO_REVOCATION_CHECK (0x80092012)` ------
   访问不到证书吊销服务器，一个字节都下不来。`cargo` / `winget` 用各自的 TLS
   栈，不受影响。
2. **`cargo install` 在本机不可用。** `rustc` 的 host 是
   `x86_64-pc-windows-msvc`，但机器上 没有 `link.exe` / `cl.exe` / VS Build
   Tools / gcc，链接阶段必然失败。要装 Rust 程序就用
   `cargo binstall <crate>`（走预编译产物，需要已装
   `cargo-binstall`；`--install-path` 指定 落点，`--disable-strategies compile`
   强制不走编译）。注意 binstall 对这两个工具也不好用： `stylua`
   只能落到第三方镜像 QuickInstall（官方 crate-metadata 策略失败），`panache`
   **完全不行**（官方归档缺它自己声明的 `distill_quarto_schema` 二进制，binstall
   直接拒绝）。 所以这两项直接下官方 release 最干净。
3. **winget 装 portable 包不会建 shim。** 创建 shim
   要符号链接权限，没权限就静默跳过， 结果是二进制躺在 `WinGet\Packages`
   里却不在 PATH 上。必须自己补 `.cmd` shim（或把该目录 加进 PATH）。
4. **Neovim / libuv 认 `.cmd` shim。** `vim.fn.executable()` 与 `vim.system()`
   都会按 PATHEXT 找到 `.cmd` 并成功 spawn（mason 当年就是这么做的），所以第 3
   条的 shim 对 LSP 是可用的。
5. **PowerShell 5.1 用 ANSI 码页解码没有 BOM 的 `.ps1`。**
   中文注释会被误解码，视字节序列
   甚至**吞掉换行符、把多行粘成一行**，直接破坏语法（实测：同类中文注释有的能跑、有的报
   语法错误）。要写 `.ps1` 就只用 ASCII，或存成 **带 BOM** 的 UTF-8。
6. **别用 GitHub API 查版本。** 本机 `api.github.com` 解析异常（web
   工具直接以"非公网 IP" 拒绝）。用 `releases/latest` 的 302 `Location` 头解析
   tag 更稳，也不需要 token。
7. **Linux 解压注意。** GNU tar 不能解 zip（Windows 自带的是 bsdtar 可以）；zip
   用 `unzip -o` 或 `bsdtar -xf`。从归档里解出/复制出来的二进制在 Linux 上**必须
   `chmod 755`**， 否则不可执行。

## 与 `docs/DEPENDENCIES.md` 的分工

- 本文：落点、每个工具的权威渠道、实测可用的命令、踩过的坑（"怎么装才对"）
- `docs/DEPENDENCIES.md`：整机清单与 A/B/C/D
  分档、逐发行版命令（"新机器要装什么"）

两处不要复制同一份清单。
