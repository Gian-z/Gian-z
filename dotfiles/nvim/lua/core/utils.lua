local v = vim.version()
local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)

local argv = vim.api.nvim_get_vvar "argv"
local noplugin = false
for i = 3, #argv, 1 do
    if argv[i] == "--noplugin" then
        noplugin = true
        break
    end
end

local utils = {
    noplugin = noplugin,
    version = version,
}

local ft_group = vim.api.nvim_create_augroup("IceFt", { clear = true })

-- Checks if a file exists
---@param file string
---@return boolean
utils.file_exists = function(file)
    local fid = io.open(file, "r")
    if fid ~= nil then
        io.close(fid)
        return true
    else
        return false
    end
end

-- Add callback to filetype
---@param filetype string
---@param config function
utils.ft = function(filetype, config)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        group = ft_group,
        callback = config,
    })
end

-- Get the parent directory of target. If target is nil, the parent directory of the current file will be looked for,
-- suffixed with a "/" (which is because this function is intended to be used together with fs_scandir, where errors
-- would occur sometimes should a path without an ending "/" be passed to it, such as "C:" instead of "C:/").
--
-- If the target has no parent directory, such as "/" on Linux or "C:" on Windows, nil will be returned.
---@param target string?
---@return string?
utils.get_parent = function(target)
    if target == nil then
        local parent = vim.fn.expand("%:p:h", true)

        if utils.is_windows() then
            parent = string.gsub(parent, "\\", "/")
        end

        return parent
    end

    if utils.is_windows() then
        target = string.gsub(target, "\\", "/")
    end

    -- removes trailing slash
    if string.sub(target, #target, #target) == "/" then
        target = string.sub(target, 1, #target - 1)
    end

    if string.find(target, "/") == nil then
        return nil
    end

    return string.sub(target, 1, string.findlast(target, "/"))
end

utils.get_root = function()
    local uv = vim.uv
    local default_pattern = {
        ".git",
        ".csproj",
        "README.md",
    }

    local pattern = Ice.chdir_root_pattern
    if pattern == nil or type(pattern) ~= "table" then
        pattern = default_pattern
    end

    local parent = utils.get_parent()
    local root = parent
    local has_found_root = false

    while not (has_found_root or parent == nil) do
        local dir = uv.fs_scandir(parent)

        if dir == nil then
            break
        end

        local file = ""

        while file ~= nil do
            file = uv.fs_scandir_next(dir)
            if table.find(pattern, file) then
                root = parent
                has_found_root = true
                break
            end
        end

        parent = utils.get_parent(parent)
    end

    return root
end

utils.is_windows = function()
    return vim.uv.os_uname().sysname == "Windows_NT"
end

utils.is_linux = function()
    return vim.uv.os_uname().sysname == "Linux"
end

utils.is_wsl = function()
    return string.find(vim.uv.os_uname().release, "WSL") ~= nil
end

utils.is_mac = function()
    return vim.uv.os_uname().sysname == "Darwin"
end

-- Maps a group of keymaps with the same opt; if no opt is provided, the default opt is used.
-- The keymaps should be in the format like below:
--     desc = { mode, lhs, rhs, [opt] }
-- For example:
--     black_hole_register = { { "n", "v" }, "\\", '"_' },
-- The desc part will automatically merged into the keymap's opt, unless one is already provided there, with the slight
-- modification of replacing "_" with a blank space.
---@param group table list of keymaps
---@param opt table | nil default opt
utils.group_map = function(group, opt)
    if not opt then
        opt = {}
    end

    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")
        local default_option = vim.tbl_extend("force", {
            desc = desc,
            noremap = true,
            nowait = true,
            silent = true,
        }, opt)
        local map = vim.tbl_deep_extend("force", { nil, nil, nil, default_option }, keymap)
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end

-- Allow ordered iteration through a table
---@param t table
---@return function
utils.ordered_pair = function(t)
    local a = {}

    for n in pairs(t) do
        a[#a + 1] = n
    end

    table.sort(a)

    local i = 0

    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

-- Pull the latest commits for the configuration repo. Requires a configured
-- upstream remote; otherwise notifies and exits.
utils.update = function()
    local cwd = vim.fn.stdpath "config"

    vim.system({ "git", "remote" }, { cwd = cwd, text = true }, function(check)
        if check.code ~= 0 or check.stdout == nil or vim.trim(check.stdout) == "" then
            vim.schedule(function()
                vim.notify("No git remote configured for " .. cwd, vim.log.levels.WARN)
            end)
            return
        end

        vim.system({ "git", "pull", "--ff-only" }, { cwd = cwd, text = true }, function(out)
            vim.schedule(function()
                if out.code == 0 then
                    vim.notify "Configuration up to date"
                else
                    vim.notify("Configuration update failed: " .. (out.stderr or ""), vim.log.levels.WARN)
                end
            end)
        end)
    end)
end

utils.lsp_attach_keymap = function(bufnr)
    require("core.utils").group_map(Ice.keymap.lsp.mapLsp, { noremap = true, silent = true, buffer = bufnr })
end

-- Set up colorscheme and Ice.colorscheme, but does not take care of lualine
-- The colorscheme is a table with:
--   - name: to be called with the `colorscheme` command
--   - setup: optional; can either be:
--     - a function called alongside `colorscheme`
--     - a table for plugin setup
--   - background: "light" / "dark"
--   - lualine_theme: optional
---@param colorscheme_name string
utils.colorscheme = function(colorscheme_name)
    Ice.colorscheme = colorscheme_name

    local colorscheme = Ice.colorschemes[colorscheme_name]
    if not colorscheme then
        vim.notify(colorscheme_name .. " is not a valid color scheme!", vim.log.levels.ERROR)
        return
    end

    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

return utils
