-- ============================================================
-- 外部工具自举（替代 mason.nvim）
-- ------------------------------------------------------------
-- mason.nvim 已停用（见 lua/plugins/bak/mason.lua）。它的职责只剩两件事：
--   1. 把工具二进制装到某处；2. 让那个目录在 PATH 上。
-- 本模块按「每个工具用它最权威的分发渠道」重新实现这两件事：
--   uv tool            ruff / basedpyright   （Python 官方生态，用户态，无需提权）
--   官方 release        stylua / panache      （curl + tar，无需编译、无需提权）
--   平台包管理器        lua-language-server    （winget；Arch 上是 AUR，需提权 → 只打印命令）
--
-- 落点统一为 ~/.local/bin：它已在 Windows 用户 PATH 上（uv 装的 basedpyright 就在那里），
-- Arch 上同样在 PATH 里，因此终端与 Neovim 都能直接解析，不需要改 vim.env.PATH。
-- 这也顺带解决了旧文档里「stylua 在终端里不可用」的问题。
--
-- 命令：:ToolsStatus（看状态）· :ToolsInstall（装缺失的）
-- 启动时只做一次「本地探测」，不发任何网络请求（见 DEFAULTS.notify_missing）。
--
-- 踩过的坑（改这里之前先读）：
--   1. 本机 curl 走 Schannel，访问不到证书吊销服务器时会直接拒绝连接：
--      CRYPT_E_NO_REVOCATION_CHECK (0x80092012)。所以所有下载都必须带
--      --ssl-no-revoke。cargo / winget 用自己的 TLS 栈，不受影响——这也是
--      不用第三方 installer 的原因（它们的 curl 不带这个参数，在会这里失败）。
--   2. release 归档的目录层级不统一，二进制可能不在顶层，故在解压目录里递归查找。
--   3. Windows 自带的 tar.exe 是 bsdtar，能直接解 zip；Linux 的 GNU tar 不能，
--      所以 zip 的解压顺序是 tar -> bsdtar -> unzip。
--   4. 从归档复制出来的二进制在 Linux 上必须 chmod 0755，否则不可执行。
--   5. 归档里的 asset 名可能不含版本（版本只在路径里），此时要先解析最新 tag。
--   6. winget 装 portable 包时可能不建 shim（建 symbolic link 要权限），二进制会躺在
--      Packages 目录里却不在 PATH 上；本模块自己往落点补一个 .cmd shim 兜底。
--   7. 安装命令的退出码为 0 不代表工具可用，所以装完必须复查一次 installed()。
-- ============================================================

local M = {}

local DEFAULTS = {
  bin_dir = vim.fn.expand("~/.local/bin"), -- 所有工具的落点（已在用户 PATH 上）
  notify_missing = true, -- 启动时缺工具就给一条本地提示（不做网络请求）
}

local initialized = false

-- ------------------------------------------------------------
-- 平台判断
-- ------------------------------------------------------------

local function is_windows()
  return vim.fn.has("win32") == 1
end

-- 归一化架构名；只提供 x86_64 产物，其它架构会被明确拒绝而不是装错
local function os_arch()
  local machine = (vim.uv.os_uname().machine or ""):lower()
  if machine == "x86_64" or machine == "amd64" then
    return "x86_64"
  end
  if machine == "aarch64" or machine == "arm64" then
    return "aarch64"
  end
  return machine
end

local function null_device()
  return is_windows() and "NUL" or "/dev/null"
end

local function bin_ext()
  return is_windows() and ".exe" or ""
end

-- ------------------------------------------------------------
-- 工具清单
-- ------------------------------------------------------------
-- 每项：name/probe/desc + 平台 provider。
--   both   两个平台同一条命令（uv tool）
--   windows / linux  各自的 provider
-- provider 的 kind：
--   release  官方 GitHub release，curl 下载 + 解压（repo/asset/bin，need_tag 见下）
--   uv       uv tool install（用 UV_TOOL_BIN_DIR 指定落点）
--   winget   winget install（user 范围，免提权）
--   manual   需要交互提权，脚本不代跑，只报命令
--
-- Linux 侧此处按 glibc 产物写死（Arch/Ubuntu/Fedora 都是）。Alpine 等 musl 用户
-- 把 stylua 换成 stylua-linux-x86_64-musl.zip、panache 换成 ...-musl.tar.gz 即可。

local TOOLS = {
  {
    name = "stylua",
    desc = "Lua 格式化（conform 保存时调用）",
    probe = "stylua",
    repo = "JohnnyMorganz/StyLua",
    windows = { kind = "release", asset = "stylua-windows-x86_64.zip", bin = "stylua.exe" },
    linux = { kind = "release", asset = "stylua-linux-x86_64.zip", bin = "stylua" },
  },
  {
    name = "panache",
    desc = "Markdown formatter + linter + LSP",
    probe = "panache",
    repo = "jolars/panache",
    -- panache 的 asset 名不含版本号（版本只在下载路径里），所以要先把最新 tag 解析出来
    need_tag = true,
    windows = { kind = "release", asset = "panache-x86_64-pc-windows-msvc.zip", bin = "panache.exe" },
    linux = { kind = "release", asset = "panache-x86_64-unknown-linux-gnu.tar.gz", bin = "panache" },
  },
  {
    name = "ruff",
    desc = "Python lint / format（conform + nvim-lint）",
    probe = "ruff",
    both = { kind = "uv", package = "ruff" },
  },
  {
    name = "basedpyright",
    desc = "Python LSP（nvim-lspconfig 实际调用 basedpyright-langserver）",
    probe = "basedpyright-langserver",
    both = { kind = "uv", package = "basedpyright" },
  },
  {
    name = "lua-language-server",
    desc = "Lua LSP",
    probe = "lua-language-server",
    windows = { kind = "winget", id = "LuaLS.lua-language-server" },
    -- Arch 上 lua-language-server 只在 AUR，paru 要交互输密码，脚本代跑不了
    linux = { kind = "manual", command = "paru -S lua-language-server" },
  },
}

-- ------------------------------------------------------------
-- 进程与文件
-- ------------------------------------------------------------

-- 跑一条外部命令；返回 (是否成功, 合并后的输出)
local function capture(argv, env)
  local ok, res = pcall(function()
    return vim.system(argv, { text = true, env = env }):wait()
  end)
  if not ok then
    return false, tostring(res)
  end
  local out = vim.trim((res.stdout or "") .. (res.stderr or ""))
  return res.code == 0, out
end

local function provider_for(spec)
  if spec.both then
    return spec.both
  end
  return is_windows() and spec.windows or spec.linux
end

local function resolve(opts)
  return vim.tbl_deep_extend("force", vim.deepcopy(DEFAULTS), opts or {})
end

local function bin_path(spec, cfg)
  return cfg.bin_dir .. "/" .. spec.probe .. bin_ext()
end

-- 已装判定：先看 PATH，再看目标目录（万一 ~/.local/bin 不在 PATH 上）
local function installed(spec, cfg)
  if vim.fn.executable(spec.probe) == 1 then
    return true
  end
  return vim.uv.fs_stat(bin_path(spec, cfg)) ~= nil
end

-- ------------------------------------------------------------
-- 安装：官方 release
-- ------------------------------------------------------------

-- 读 releases/latest 的 302 最终 URL 拿到最新 tag。
-- 不用 GitHub API：本机 api.github.com 解析异常（web 工具直接拒绝），而这条重定向稳定。
local function latest_tag(repo)
  local ok, out = capture({
    "curl",
    "--ssl-no-revoke",
    "-sIL",
    "-o",
    null_device(),
    "-w",
    "%{url_effective}",
    ("https://github.com/%s/releases/latest"):format(repo),
  })
  if not ok then
    return nil
  end
  return out:match("/tag/([^%s/]+)%s*$")
end

local function download(url, dest)
  -- --ssl-no-revoke 是必需的，原因见文件头注释第 1 条
  local ok, out = capture({ "curl", "--ssl-no-revoke", "-fsSL", "-o", dest, url })
  if not ok then
    return false, "下载失败：" .. out
  end
  if not vim.uv.fs_stat(dest) then
    return false, "下载后目标文件不存在"
  end
  return true
end

local function extract(archive, dir)
  local attempts
  if archive:match("%.zip$") then
    attempts = {
      { "tar", "-xf", archive, "-C", dir },
      { "bsdtar", "-xf", archive, "-C", dir },
      { "unzip", "-oq", archive, "-d", dir },
    }
  else
    attempts = {
      { "tar", "-xf", archive, "-C", dir },
      { "bsdtar", "-xf", archive, "-C", dir },
    }
  end

  local errs = {}
  for _, argv in ipairs(attempts) do
    if vim.fn.executable(argv[1]) == 1 then
      local ok, out = capture(argv)
      if ok then
        return true
      end
      table.insert(errs, ("%s: %s"):format(argv[1], out))
    end
  end
  return false, "解压失败（" .. table.concat(errs, " | ") .. "）"
end

local function install_release(spec, prov, cfg)
  if os_arch() ~= "x86_64" then
    return false, ("只提供 x86_64 产物，当前架构是 %s"):format(os_arch())
  end

  local url
  if spec.need_tag then
    local tag = latest_tag(spec.repo)
    if not tag then
      return false, "解析最新 tag 失败（网络或 curl 的吊销检查问题）"
    end
    url = ("https://github.com/%s/releases/download/%s/%s"):format(spec.repo, tag, prov.asset)
  else
    url = ("https://github.com/%s/releases/latest/download/%s"):format(spec.repo, prov.asset)
  end

  local stamp = vim.fn.tempname()
  local archive = ("%s-%s"):format(stamp, prov.asset)
  local dir = stamp .. "-x"
  vim.fn.mkdir(dir, "p")

  local ok, err = download(url, archive)
  if not ok then
    vim.fn.delete(dir, "rf")
    return false, err
  end
  ok, err = extract(archive, dir)
  if not ok then
    vim.uv.fs_unlink(archive)
    vim.fn.delete(dir, "rf")
    return false, err
  end

  -- 归档层级不统一，先看顶层再递归找
  local candidates = { dir .. "/" .. prov.bin }
  vim.list_extend(candidates, vim.fn.glob(dir .. "/**/" .. prov.bin, false, true))
  local src
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      src = path
      break
    end
  end
  if not src then
    vim.uv.fs_unlink(archive)
    vim.fn.delete(dir, "rf")
    return false, ("归档里没找到 %s"):format(prov.bin)
  end

  vim.fn.mkdir(cfg.bin_dir, "p")
  local dest = bin_path(spec, cfg)
  vim.uv.fs_copyfile(src, dest)
  if not is_windows() then
    vim.uv.fs_chmod(dest, 493) -- 0755，否则 Linux 上不可执行
  end

  vim.uv.fs_unlink(archive)
  vim.fn.delete(dir, "rf")
  return true
end

-- ------------------------------------------------------------
-- 安装：其它 provider
-- ------------------------------------------------------------

local function install_uv(prov, cfg)
  local ok, out = capture({ "uv", "tool", "install", prov.package }, { UV_TOOL_BIN_DIR = cfg.bin_dir })
  if not ok then
    return false, "uv tool install 失败：" .. out
  end
  return true
end

-- 在 winget 的 Packages 目录里找已装的 exe（顶层和嵌套都找）
local function winget_exe(spec, prov)
  local local_appdata = vim.env.LOCALAPPDATA or ""
  if local_appdata == "" then
    return nil
  end
  local root = local_appdata .. "\\Microsoft\\WinGet\\Packages"
  local name = spec.probe .. ".exe"
  local candidates = vim.fn.glob(("%s/%s_*/%s"):format(root, prov.id, name), false, true)
  vim.list_extend(candidates, vim.fn.glob(("%s/%s_*/**/%s"):format(root, prov.id, name), false, true))
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      return path
    end
  end
  return nil
end

-- 往落点写一个 .cmd shim（libuv 会按 PATHEXT 找到它，mason 当年也是这么干的）
local function write_shim(spec, cfg, target)
  vim.fn.mkdir(cfg.bin_dir, "p")
  local shim = bin_path(spec, cfg)
  shim = shim:gsub("%.exe$", "") .. ".cmd"
  local fd, open_err = vim.uv.fs_open(shim, "w", 420) -- 0644
  if not fd then
    return false, ("写 shim 失败 %s：%s"):format(shim, tostring(open_err))
  end
  vim.uv.fs_write(fd, ('@echo off\r\n"%s" %%*\r\n'):format(target))
  vim.uv.fs_close(fd)
  return true
end

-- winget 装 portable 包时可能不建 shim（建 symbolic link 需要权限），于是二进制躺在
-- Packages 目录里却不在 PATH 上。所以这里不依赖 winget 的 shim，自己补一个到落点。
-- 另外 lua-language-server 是目录型工具（要 main.lua / meta/），不能只复制 exe。
local function install_winget(spec, prov, cfg)
  local target = winget_exe(spec, prov)
  if not target then
    local ok, out = capture({
      "winget",
      "install",
      "--id",
      prov.id,
      "-e",
      "--accept-package-agreements",
      "--accept-source-agreements",
    })
    if not ok then
      return false, "winget 失败（可能要提权，手跑一次即可）：" .. out
    end
    target = winget_exe(spec, prov)
  end
  if not target then
    return false, ("winget 装完了，但在 Packages 目录里找不到 %s.exe"):format(spec.probe)
  end
  return write_shim(spec, cfg, target)
end

-- ------------------------------------------------------------
-- 对外接口
-- ------------------------------------------------------------

local function missing_tools(cfg)
  local missing = {}
  for _, spec in ipairs(TOOLS) do
    if not installed(spec, cfg) then
      table.insert(missing, spec)
    end
  end
  return missing
end

function M.status(opts)
  local cfg = resolve(opts)
  local lines = { "tools（落点 " .. cfg.bin_dir .. "）" }
  for _, spec in ipairs(TOOLS) do
    local mark = installed(spec, cfg) and "✓" or "✗"
    table.insert(lines, ("  %s %-20s %s"):format(mark, spec.name, spec.desc))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  return M
end

function M.install(opts)
  local cfg = resolve(opts)
  local todo = missing_tools(cfg)
  if #todo == 0 then
    vim.notify("tools: 全部已就绪", vim.log.levels.INFO)
    return true
  end

  local failed = {}
  for _, spec in ipairs(todo) do
    local prov = provider_for(spec)
    local ok, err
    if prov == nil then
      ok, err = false, "当前平台没有配置安装方式"
    elseif prov.kind == "release" then
      ok, err = install_release(spec, prov, cfg)
    elseif prov.kind == "uv" then
      ok, err = install_uv(prov, cfg)
    elseif prov.kind == "winget" then
      ok, err = install_winget(spec, prov, cfg)
    elseif prov.kind == "manual" then
      ok, err = false, "需要手动执行：" .. prov.command
    else
      ok, err = false, "未知的安装方式：" .. tostring(prov.kind)
    end

    -- provider 退出码为 0 不等于工具真的可用（winget 就装到过 PATH 之外），复查一次再下结论
    if ok and not installed(spec, cfg) then
      ok, err = false, ("安装命令成功了，但 %s 仍不在 PATH / 落点上"):format(spec.probe)
    end

    if ok then
      vim.notify(("tools: %s 装好了"):format(spec.name), vim.log.levels.INFO)
    else
      vim.notify(("tools: %s 没装上 —— %s"):format(spec.name, err or "未知原因"), vim.log.levels.ERROR)
      table.insert(failed, spec.name)
    end
  end
  return #failed == 0
end

function M.setup(opts)
  local cfg = resolve(opts)
  if initialized then
    return M
  end
  initialized = true

  vim.api.nvim_create_user_command("ToolsStatus", function()
    M.status(cfg)
  end, { desc = "查看外部工具状态（替代 :Mason）" })

  vim.api.nvim_create_user_command("ToolsInstall", function()
    M.install(cfg)
  end, { desc = "安装缺失的外部工具" })

  -- 只做本地探测，不发网络请求；不需要就 setup({ notify_missing = false })
  if cfg.notify_missing then
    local missing = missing_tools(cfg)
    if #missing > 0 then
      local names = {}
      for _, spec in ipairs(missing) do
        table.insert(names, spec.name)
      end
      vim.notify(
        ("tools: 缺 %s（:ToolsInstall 安装，:ToolsStatus 查看）"):format(table.concat(names, "、")),
        vim.log.levels.WARN
      )
    end
  end

  return M
end

return M
