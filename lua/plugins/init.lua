local function enable_plugin(path)
  local handle = vim.uv.fs_scandir(path)
  if not handle then
    return
  end

  while true do
    local file_name, _ = vim.uv.fs_scandir_next(handle)
    if not file_name then
      break
    end
    if file_name ~= "init.lua" then
        if file_name:match("%.lua$") then
        local plugin_name = file_name:gsub(".lua$", "")
        require("plugins." .. plugin_name)
        end
    end
  end
end

enable_plugin(vim.fn.stdpath("config") .. "/lua" .. "/plugins")