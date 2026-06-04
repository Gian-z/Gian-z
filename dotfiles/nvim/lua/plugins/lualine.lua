-- Section colors are pulled from the current colorscheme via `theme = "auto"`
-- (lualine reacts to ColorScheme events). Only layout, separator glyphs and
-- bold accents are fixed here.

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand "%:t") ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
}

-- Config
local config = {
    options = {
        theme = "auto",
        component_separators = "",
        section_separators = { left = "", right = "" },
    },
    sections = {
        lualine_a = {
            { "mode", separator = { left = "" }, right_padding = 2 },
        },
        lualine_b = {
            { "location" },
            {
                "filename",
                cond = conditions.buffer_not_empty,
                color = { gui = "bold" },
            },
            {
                "progress",
                cond = conditions.buffer_not_empty,
            },
        },
        lualine_c = {
            {
                -- Lsp server name.
                function()
                    local msg = "No Active Lsp"
                    local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                    local clients = vim.lsp.get_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                icon = " ",
                color = { gui = "bold" },
            },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " " },
                separator = {},
            },
        },
        lualine_x = {
            { "diff" },
        },
        lualine_y = {
            {
                "o:encoding",
                fmt = string.upper,
                cond = conditions.hide_in_width,
                color = { gui = "bold" },
            },
            {
                "fileformat",
                fmt = string.upper,
                icons_enabled = false,
                color = { gui = "bold" },
            },
            {
                "branch",
                icon = "",
                color = { gui = "bold" },
            },
        },
        lualine_z = {
            {
                function()
                    return os.date "%X"
                end,
                separator = { right = "" },
                left_padding = 2,
            },
        },
    },
    inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "location" },
    },
}

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    event = "User IceLoad",
    main = "lualine",
    opts = config,
}
