# Configuration

Personal Neovim configuration. Originally derived from
[Shaobin Jiang's IceNvim](https://github.com/Shaobin-Jiang/IceNvim.git); now
maintained independently. The `Ice` namespace and the `:Ice*` commands are
inherited from upstream and kept for muscle memory — they no longer track the
upstream repo.

## Layout

```
init.lua            -- entrypoint
lua/core/           -- options, keymaps, autocmds, LSP wiring, plugin registry
lua/plugins/        -- one file per plugin
lsp/                -- per-server LSP configs (loaded by mason.lua)
```

The `Ice` global is the central namespace. `Ice.lsp` lists servers + formatters,
`Ice.plugins` lists plugin specs, `Ice.keymap` holds keymap groups.

## Leader keys

- `<leader>` = `;`
- `<localleader>` = `,`

## Leader prefixes

| Prefix       | Group          |
|--------------|----------------|
| `<leader>a`  | AI / Claude    |
| `<leader>b`  | Buffer         |
| `<leader>c`  | Comment        |
| `<leader>d`  | Debug (DAP)    |
| `<leader>g`  | Git            |
| `<leader>l`  | LSP            |
| `<leader>n`  | Test (Neotest) |
| `<leader>q`  | Session        |
| `<leader>u`  | Utils          |
| `<leader>w`  | Window         |

## Key bindings (selection)

### Files / search

- `<leader><leader>` — find files (Telescope)
- `<leader>t` — live grep
- `<leader>e` — environment variables
- `-` — open parent dir (oil)
- `<leader>o` — open oil

### Buffers

- `<Tab>` / `<S-Tab>` — cycle most-recently-used buffers (Alt-Tab style); tap again to step further back, pause to commit
- `<leader>bb` — pick recent buffer (Telescope, MRU order)
- `<leader>bh` / `<leader>bl` — prev / next buffer in tab order (bufferline)
- `<leader>bp` / `<leader>bc` — pick / pick-close buffer
- `<leader>bd` / `<leader>bo` — close current / close others

### LSP

- `K` — hover
- `gd` / `gy` — definition / type definition
- `grr` / `gri` — references / implementation
- `grn` — rename
- `gra` — code action
- `gO` — document symbols
- `<leader>lS` — workspace symbols
- `<leader>lf` — format (conform)
- `<leader>lc` — line diagnostic float
- `<leader>lj` / `<leader>lk` — next / prev diagnostic
- `<leader>lt` — Trouble diagnostics

### Completion (blink.cmp)

- `<Tab>` — accept
- `<C-j>` / `<C-k>` — next / prev
- `<A-c>` — toggle menu
- `<Up>` / `<Down>` — scroll docs

### Jumping (flash)

- `s` — flash jump (n/x/o)
- `S` — treesitter jump
- `<leader>j` — flash jump

### Harpoon (via the mark keys)

- `ma` — add current file
- `me` — quick menu (edit list)
- `m1`..`m4` — jump to slot
- `m{other}` — still sets a native mark (only `a` / `e` / `1`-`4` are taken)

### Git

- `<leader>gn` / `<leader>gp` — next / prev hunk
- `<leader>gP` — preview hunk
- `<leader>gs` / `<leader>gu` / `<leader>gr` — stage / undo / reset hunk
- `<leader>gB` — stage buffer
- `<leader>gb` / `<leader>gl` / `<leader>gt` — blame / blame line / toggle blame
- `<leader>gd` / `<leader>gD` — diffview open / close
- `<leader>gh` / `<leader>gH` — branch / current-file history (diffview)

### Debug

- `<leader>db` — breakpoint
- `<leader>dc` — continue
- `<leader>di` / `<leader>do` / `<leader>dO` — step in / over / out
- `<leader>du` — toggle DAP UI
- `<leader>de` — eval

### Test

- `<leader>nr` — run nearest
- `<leader>nf` — run file
- `<leader>nd` — debug nearest
- `<leader>ns` — toggle summary
- `<leader>no` — open output

### Session

- `<leader>qs` — restore session
- `<leader>ql` — restore last session
- `<leader>qd` — stop saving

### AI (Claude Code)

- `<leader>ac` — toggle
- `<leader>af` — focus
- `<leader>ar` — resume
- `<leader>aC` — continue
- `<leader>ab` — add current buffer
- `<leader>as` — send selection (visual)
- `<leader>aa` / `<leader>ad` — accept / deny diff

### Code navigation

- `<leader>uo` / `<leader>uO` — aerial outline toggle / nav
- Inside aerial: `{` / `}` — prev / next symbol
- `]m` / `[m` — next / prev function (treesitter)
- `]]` / `[[` — next / prev class (treesitter)
- `<leader>uC` — toggle treesitter context bar

### Utils

- `<leader>ui` — check nerd-font icons
- `<leader>ul` — Lazy profile
- `<leader>uc` — view configuration files
- `<leader>u/` — undo history (Telescope)

### Misc

- `<C-s>` — save
- `<C-z>` — undo
- `<C-p>` — toggle terminal (bottom split)
- `<leader>wf` (normal) / `<C-f>` (in terminal) — toggle terminal fullscreen
- `<C-h/j/k/l>` — window navigation
- `<A-o>` / `<A-O>` — new line below / above without moving
- `<A-h/j/k/l>` — move line/selection (mini.move)
- `af`/`if`, `ac`/`ic`, `aa`/`ia` — function / class / parameter textobjects

## Adding a plugin

1. Create `lua/plugins/<name>.lua` returning a lazy.nvim spec.
2. Register it in `lua/core/plugins.lua` under the appropriate section.

## Adding an LSP

1. Create `lsp/<server>.lua` with the server config.
2. Add `config.<server> = { active = true, formatter = "<formatter>" }` to
   `lua/core/lsps.lua`. Mason installs both on next launch.

## Notable plugins

| Area              | Plugin                                |
|-------------------|---------------------------------------|
| Plugin manager    | lazy.nvim                             |
| Completion        | blink.cmp (+ LuaSnip, friendly-snip.) |
| Formatting        | conform.nvim                          |
| Linting           | nvim-lint                             |
| LSP install       | mason.nvim + mason-lspconfig          |
| Fuzzy finder      | telescope.nvim (+ ui-select, undo)    |
| File explorer     | oil.nvim, neo-tree.nvim               |
| Quick nav         | harpoon                               |
| Jumping           | flash.nvim                            |
| Git               | gitsigns, neogit, diffview.nvim       |
| Symbol outline    | aerial.nvim                           |
| Context bar       | nvim-treesitter-context               |
| Debugging         | nvim-dap (+ dap-ui, virtual-text)     |
| Testing           | neotest (dotnet / rust / go)          |
| AI                | claudecode.nvim                       |
| Sessions          | persistence.nvim                      |
| Textobjects       | nvim-treesitter-textobjects, mini.ai  |
| Move              | mini.move                             |
| Notifications     | fidget.nvim                           |
| Markdown          | render-markdown.nvim, markdown-preview |
| Clipboard / yank  | yanky.nvim                            |
| C# LSP            | roslyn.nvim                           |

## Performance

- `vim.loader.enable()` is called at the top of `init.lua` (Lua bytecode cache).
- Most plugins are lazy-loaded on the synthetic `User IceLoad` event or on
  specific filetypes / commands / keys.
- Persistent undo lives under `stdpath("state")/undo`.

## Commands

- `:IceUpdate` — `git pull` the config repo.
- `:IceHealth` — run the health checks under `lua/core/health.lua`.
- `:Lazy` — plugin manager UI.
- `:Mason` — LSP / formatter / DAP tool installer UI.
- `:ConformInfo` — show active formatters for current buffer.
- `:DiffviewOpen`, `:DiffviewFileHistory` — git diff / history.
- `:AerialToggle` — symbol outline.
- `:TSContextToggle` — sticky context bar.
- `:ClaudeCode` — open Claude Code split.

## Starting without plugins

```
nvim --noplugin
```

## Testing

A smoke test loads every core module, plugin spec and LSP config and reports any
that fail to evaluate:

```
nvim --headless "+luafile tests/check.lua" +qa
```

It exits non-zero if anything fails. CI (`.github/workflows/check.yml`) runs this
on every push together with a `stylua --check` formatting gate. Format locally
with `stylua .` (config in `.stylua.toml`).
