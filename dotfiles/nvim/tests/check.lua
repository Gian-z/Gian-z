-- Smoke test for the configuration.
--
-- Run with:
--     nvim --headless "+luafile tests/check.lua" +qa
--
-- Loads each plugin spec and each core module via dofile and reports any
-- that fail to parse or evaluate. Exits with a non-zero status if anything
-- failed (so it can be wired into CI later).

local config = vim.fn.stdpath "config"

local fails = 0
local total = 0

local function check(name, fn)
    total = total + 1
    local ok, err = pcall(fn)
    local status = ok and "OK  " or "FAIL"
    io.write(string.format("  [%s] %s\n", status, name))
    if not ok then
        io.write("         " .. tostring(err) .. "\n")
        fails = fails + 1
    end
end

local function list_lua(dir)
    local files = {}
    local handle = vim.uv.fs_scandir(dir)
    if not handle then
        return files
    end
    while true do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then
            break
        end
        if t == "file" and name:match "%.lua$" then
            files[#files + 1] = name:gsub("%.lua$", "")
        end
    end
    table.sort(files)
    return files
end

io.write "\n== core ==\n"
for _, name in ipairs(list_lua(config .. "/lua/core")) do
    check("core." .. name, function()
        dofile(config .. "/lua/core/" .. name .. ".lua")
    end)
end

-- Files in lua/plugins/ that don't return a lazy.nvim spec but instead
-- populate Ice.* registries as a side effect.
local plugin_bootstrappers = { colorscheme = true, lazy = true }

io.write "\n== plugins ==\n"
for _, name in ipairs(list_lua(config .. "/lua/plugins")) do
    check("plugins." .. name, function()
        local spec = dofile(config .. "/lua/plugins/" .. name .. ".lua")
        if not plugin_bootstrappers[name] then
            assert(type(spec) == "table", "spec did not return a table (got " .. type(spec) .. ")")
        end
    end)
end

io.write "\n== lsp ==\n"
for _, name in ipairs(list_lua(config .. "/lsp")) do
    check("lsp." .. name, function()
        local cfg = dofile(config .. "/lsp/" .. name .. ".lua")
        assert(type(cfg) == "table", "lsp config did not return a table")
    end)
end

io.write(string.format("\n%d / %d failure(s)\n", fails, total))

if fails > 0 then
    vim.cmd "cq"
end
