# 外部工具的安装参考

```powershell
Get-Command stylua, panache, ruff, lua-language-server, basedpyright-langserver
```

```sh
command -v stylua panache ruff lua-language-server basedpyright-langserver
```

## 逐个安装

### ruff / basedpyright（两个平台完全相同）

```sh
uv tool install ruff
uv tool install basedpyright
```

`uv tool install` 默认就把可执行文件放进 `~/.local/bin`，无需额外参数。

### stylua

- https://github.com/JohnnyMorganz/StyLua


```shell
winget install --id JohnnyMorganz.StyLua -e

cargo install stylua

pip install git+https://github.com/johnnymorganz/stylua
uv tool install git+https://github.com/johnnymorganz/stylua
```

### panache

- https://github.com/jolars/panache

- For Windows PowerShell:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://panache.bz/install.ps1 | iex"
```

- For macOS and Linux:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://panache.bz/install | sh
```

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
