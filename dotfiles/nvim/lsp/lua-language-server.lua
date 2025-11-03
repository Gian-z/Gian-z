return {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = (function()
                    local runtime_path = vim.split(package.path, ";")
                    table.insert(runtime_path, "lua/?.lua")
                    table.insert(runtime_path, "lua/?/init.lua")
                    return runtime_path
                end)(),
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
