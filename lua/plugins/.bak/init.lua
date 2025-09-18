function require_plugins(path)
    local handle = vim.loop.fs_scandir(path)
    if not handle then return end
    
    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if name:match "%.lua$" and name ~= "init.lua" then
            local module_name = "plugins." .. name:gsub(".lua$", "")
            require(module_name)
        end
    end
end

-- require_plugins(vim.fn.stdpath("config") .. "/lua/plugins")
return {}