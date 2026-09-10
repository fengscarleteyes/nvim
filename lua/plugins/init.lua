local disable_plugins = {}

local function enable_plugin(path)
  local handle = vim.uv.fs_scandir(path)
  if not handle then return end

  while true do
    local name = vim.uv.fs_scandir_next(handle)
    if not name then break end

    if name:match("%.lua$")
      and name ~= "init.lua"
      and not vim.tbl_contains(disable_plugins, name)
    then
      require("plugins." .. name:gsub("%.lua$", ""))
    end
  end
end

enable_plugin(vim.fn.stdpath("config") .. "/lua/plugins")