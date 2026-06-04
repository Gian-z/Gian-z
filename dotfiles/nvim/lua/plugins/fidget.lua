return {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
        -- All LSP messages route to fidget; non-LSP vim.notify is delegated to nvim-notify.
        notification = {
            override_vim_notify = false,
            window = {
                x_padding = 2,
                align = "bottom",
            },
        },
    },
    config = function(_, opts)
        local fidget = require "fidget"
        fidget.setup(opts)

        -- Surface only user-facing LSP messages (Error / Warning) as
        -- notifications. Info / Log messages — which verbose servers like
        -- roslyn emit in bulk on startup — are dropped to keep the screen
        -- quiet. (LSP MessageType: 1 = Error, 2 = Warning, 3 = Info, 4 = Log.)
        local type_to_level = {
            [1] = vim.log.levels.ERROR,
            [2] = vim.log.levels.WARN,
        }
        vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
            local level = result and type_to_level[result.type]
            if not level then
                return
            end
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            fidget.notify(result.message, level, {
                annote = client and client.name or "LSP",
                group = client and client.name or "LSP",
            })
        end

        -- window/logMessage is the server's log channel; leave it to Neovim's
        -- default handler (writes to :LspLog) instead of notifying on screen.
    end,
}
