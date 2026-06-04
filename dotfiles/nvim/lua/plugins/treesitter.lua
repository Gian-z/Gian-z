return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
        "hiphish/rainbow-delimiters.nvim",
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
        local nts = require "nvim-treesitter"
        nts.setup {}

        local parsers = {
            "bash",
            "c",
            "c_sharp",
            "cpp",
            "css",
            "go",
            "html",
            "javascript",
            "json",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "rust",
            "typescript",
            "typst",
            "tsx",
            "vim",
            "vimdoc",
            "sql",
            "yaml",
        }
        nts.install(parsers)

        local filetypes = {
            "bash",
            "c",
            "cs",
            "cpp",
            "css",
            "go",
            "html",
            "javascript",
            "json",
            "lua",
            "markdown",
            "python",
            "query",
            "rust",
            "typescript",
            "typescriptreact",
            "typst",
            "vim",
            "help",
            "sql",
            "yaml",
        }
        vim.api.nvim_create_autocmd("FileType", {
            pattern = filetypes,
            callback = function(ev)
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                if ok and stats and stats.size > 100 * 1024 then
                    return
                end
                pcall(vim.treesitter.start, ev.buf)
                -- nvim-treesitter (main) ships no indents.scm for these langs, so its
                -- indentexpr() yields no indentation — breaking newline/brace indent.
                -- Skip them so the built-in indent files win (cs → GetCSIndent, cindent-based).
                local no_ts_indent = { dart = true, cs = true }
                if not no_ts_indent[vim.bo[ev.buf].filetype] then
                    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldenable = false

        -- In markdown files, the rendered output would only display the correct highlight if the code is set to scheme
        -- However, this would result in incorrect highlight in neovim
        -- Therefore, the scheme language should be linked to query
        vim.treesitter.language.register("query", "scheme")

        local rainbow_delimiters = require "rainbow-delimiters"
        vim.g.rainbow_delimiters = {
            strategy = {
                [""] = rainbow_delimiters.strategy["global"],
                vim = rainbow_delimiters.strategy["local"],
            },
            query = {
                [""] = "rainbow-delimiters",
                lua = "rainbow-blocks",
            },
            highlight = {
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
            blacklist = { "aerial", "aerial-nav" },
            condition = function(bufnr)
                local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
                return ok and parser ~= nil
            end,
        }

        require("nvim-treesitter-textobjects").setup {
            select = { lookahead = true },
            move = { set_jumps = true },
        }
        local sel = require("nvim-treesitter-textobjects.select").select_textobject
        local mv = require "nvim-treesitter-textobjects.move"

        local selects = {
            af = "@function.outer",
            ["if"] = "@function.inner",
            ac = "@class.outer",
            ic = "@class.inner",
            aa = "@parameter.outer",
            ia = "@parameter.inner",
        }
        for lhs, query in pairs(selects) do
            vim.keymap.set({ "x", "o" }, lhs, function()
                sel(query, "textobjects")
            end)
        end

        vim.keymap.set("n", "]m", function()
            mv.goto_next_start("@function.outer", "textobjects")
        end)
        vim.keymap.set("n", "]]", function()
            mv.goto_next_start("@class.outer", "textobjects")
        end)
        vim.keymap.set("n", "]M", function()
            mv.goto_next_end("@function.outer", "textobjects")
        end)
        vim.keymap.set("n", "][", function()
            mv.goto_next_end("@class.outer", "textobjects")
        end)
        vim.keymap.set("n", "[m", function()
            mv.goto_previous_start("@function.outer", "textobjects")
        end)
        vim.keymap.set("n", "[[", function()
            mv.goto_previous_start("@class.outer", "textobjects")
        end)
        vim.keymap.set("n", "[M", function()
            mv.goto_previous_end("@function.outer", "textobjects")
        end)
        vim.keymap.set("n", "[]", function()
            mv.goto_previous_end("@class.outer", "textobjects")
        end)

        -- Incremental selection replacement (the master-branch module was deleted in main).
        -- <CR> initiates / grows by node, <BS> shrinks, <TAB> jumps to enclosing scope.
        local incr_scope_types = {
            "function_declaration",
            "function_definition",
            "function",
            "method_declaration",
            "method_definition",
            "class_declaration",
            "block",
            "local_function",
        }
        local stack
        local function visual_select(node)
            local r1, c1, r2, c2 = node:range()
            vim.api.nvim_win_set_cursor(0, { r1 + 1, c1 })
            vim.cmd "normal! v"
            vim.api.nvim_win_set_cursor(0, { r2 + 1, math.max(c2 - 1, 0) })
        end
        local function incr_init()
            local n = vim.treesitter.get_node()
            if not n then
                return
            end
            stack = { n }
            visual_select(n)
        end
        local function incr_grow()
            if not stack then
                return incr_init()
            end
            local p = stack[#stack]:parent()
            if not p then
                return
            end
            table.insert(stack, p)
            visual_select(p)
        end
        local function incr_shrink()
            if not stack or #stack < 2 then
                return
            end
            table.remove(stack)
            visual_select(stack[#stack])
        end
        local function incr_scope()
            local n = stack and stack[#stack] or vim.treesitter.get_node()
            if not n then
                return
            end
            local p = n:parent()
            while p and not vim.tbl_contains(incr_scope_types, p:type()) do
                p = p:parent()
            end
            if p then
                stack = stack or {}
                table.insert(stack, p)
                visual_select(p)
            end
        end
        local function exit_visual()
            vim.cmd "normal! \27"
        end
        -- In quickfix, the command-line window and other special buffers, <CR>
        -- must keep its native behaviour (jump to entry, run command, …), so
        -- only start incremental selection in normal file buffers.
        vim.keymap.set("n", "<CR>", function()
            if vim.bo.buftype ~= "" or vim.fn.getcmdwintype() ~= "" then
                return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
            end
            incr_init()
        end)
        vim.keymap.set("x", "<CR>", function()
            exit_visual()
            incr_grow()
        end)
        vim.keymap.set("x", "<BS>", function()
            exit_visual()
            incr_shrink()
        end)
        vim.keymap.set("x", "<TAB>", function()
            exit_visual()
            incr_scope()
        end)
    end,
}
