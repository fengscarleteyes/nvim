#!/usr/bin/env sh
# 外部工具自举的终端入口（Linux / macOS）——薄 wrapper，不含任何逻辑。
# 真正的实现只有一份：lua/custom/tools.lua。这里只把动作转交给它。
#
#   ./scripts/tools.sh            安装缺失的工具（默认）
#   ./scripts/tools.sh status     只看状态
#
# 用 -u NONE 而不是加载配置：自举脚本不该依赖 vim.pack 装插件，也不该被配置里的
# 报错连累。只把仓库根目录追加到 runtimepath，让 require("custom.tools") 能找到。

action=${1:-install}

case "$action" in
  install | status) ;;
  *)
    echo "用法: $0 [install|status]" >&2
    exit 2
    ;;
esac

# 仓库根目录 = 本脚本所在目录的上一级；定位不到就报错，不要带着空路径往下跑
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -z "$repo" ] || [ ! -f "$repo/lua/custom/tools.lua" ]; then
  echo "定位仓库根目录失败：本脚本应位于 <repo>/scripts/ 下，请在仓库内执行。" >&2
  exit 2
fi

# 通过环境变量传路径，避免路径含空格时的引号转义问题。
# lua 侧先判空：vim.opt.runtimepath:append(nil) 会让整个 --cmd 报 E5108。
TOOLS_REPO="$repo" nvim --headless -u NONE \
  --cmd "lua local p = vim.env.TOOLS_REPO; if p and p ~= '' then vim.opt.runtimepath:append(p) end" \
  "+lua require('custom.tools').$action()" +qa
status=$?

exit $status
