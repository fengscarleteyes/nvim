# Thin wrapper for the external-tool bootstrapper (Windows).
# All logic lives in lua/custom/tools.lua; this file only forwards an action to it.
#
#   .\scripts\tools.ps1             install missing tools (default)
#   .\scripts\tools.ps1 status      show status only
#
# If the execution policy blocks .ps1 (AuthorizationManager check failure), use:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\tools.ps1
#
# NOTE: ASCII-only on purpose. PowerShell 5.1 decodes a BOM-less file with the
# ANSI codepage, so non-ASCII comments are mis-decoded -- and depending on the
# byte sequence a mis-decoded tail can swallow the newline and merge lines,
# which breaks parsing (verified here: E5108-class parse failures). Do not add
# non-ASCII text to this file; keep prose in the Lua module or the docs.
#
# -u NONE instead of loading the config: a bootstrap script must not depend on
# vim.pack installing plugins, nor be taken down by an error in the config.

$ErrorActionPreference = "Stop"

$repo = ""
if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
  $repo = Split-Path -Parent $PSScriptRoot
}
if ([string]::IsNullOrEmpty($repo)) {
  Write-Error "cannot locate repo root: this script belongs in <repo>\scripts\"
  exit 2
}
if (-not (Test-Path (Join-Path $repo "lua\custom\tools.lua"))) {
  Write-Error "repo root does not contain lua\custom\tools.lua: $repo"
  exit 2
}

$action = "install"
if ($args.Count -gt 0) {
  $action = $args[0]
}
if (($action -ne "install") -and ($action -ne "status")) {
  Write-Error "usage: tools.ps1 [install|status]"
  exit 2
}

# Pass the repo path through the environment to avoid quoting problems when the
# path contains spaces.
$env:TOOLS_REPO = $repo

# The Lua side tests for nil first: vim.opt.runtimepath:append(nil) raises E5108.
nvim --headless -u NONE --cmd "lua local p = vim.env.TOOLS_REPO; if p then vim.opt.runtimepath:append(p) end" "+lua require('custom.tools').$action()" +qa
exit $LASTEXITCODE
