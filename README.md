# nvim-setup

Neovim for people coming from VS Code, on macOS with [Ghostty](https://ghostty.org).
The shortcuts you already know (Cmd+P, Cmd+Shift+F, Cmd+Z, F12, right-click menus) work,
and Vim's own keys are there when you're ready to learn them.

## Install

On a Mac (fresh or not), paste this into a terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ya-nsh/nvim-setup/main/install.sh)"
```

It installs, as needed:

- **Homebrew**, plus `neovim`, `git`, `ripgrep`, `fd`, `lazygit`, `tree-sitter-cli`, and `node` / `go` / `python` if you don't have them
- **JetBrains Mono Nerd Font** and **Ghostty**
- this config into `~/.config/nvim` (an existing one is moved to `~/.config/nvim.bak-<date>`)
- every plugin at the version pinned in `lazy-lock.json`, 32 syntax parsers, and the language servers and formatters below

If you already have a Ghostty config, it's backed up and gets one `config-file` line added for the
Neovim keys. Otherwise Ghostty uses [`ghostty/config`](ghostty/config).
Running the installer again updates everything.

Options: `--skip-brew` (manage packages yourself), `--no-ghostty`.

## What you get

| | |
|---|---|
| Quick open, command palette, search in files | Cmd+P, Cmd+Shift+P, Cmd+Shift+F ([snacks.nvim](https://github.com/folke/snacks.nvim) picker) |
| Copy / cut / paste, find in file, undo / redo | Cmd+C / Cmd+X / Cmd+V, Cmd+F, Cmd+Z / Cmd+Shift+Z |
| Go to definition / references / rename | Ctrl+click or F12, Shift+F12, F2, and in the right-click menu |
| Back / forward | Ctrl+- / Ctrl+Shift+-, or the mouse side buttons |
| File explorer | Cmd+B. Right-click a folder for **Find in Folder**, New File, Rename, Reveal in Finder... ([neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim)) |
| IntelliSense | TypeScript/JavaScript (vtsls), ESLint, Tailwind, HTML, CSS, JSON, YAML, Go, Python (basedpyright + ruff), Lua, via [Mason](https://github.com/mason-org/mason.nvim). Completion by [blink.cmp](https://github.com/saghen/blink.cmp) |
| Format on save | prettier, ruff, goimports, stylua ([conform.nvim](https://github.com/stevearc/conform.nvim)) |
| Git, GitLens-style | inline blame, commit history you can expand to see each file's diff, file and line history ([gitsigns](https://github.com/lewis6991/gitsigns.nvim), [diffview](https://github.com/sindrets/diffview.nvim)), lazygit |
| Multiple cursors | Ctrl+N (like Cmd+D), Option+click ([multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim)) |
| Tabs, status bar, key hints | bufferline, lualine, which-key: press Space and wait |

The full key map is in [CHEATSHEET.md](CHEATSHEET.md). Inside Neovim, press **`?`** anywhere: a window explains every shortcut.

### Keys that differ from VS Code

Ghostty keeps a few Cmd shortcuts for itself, so: **Ctrl+S** saves (Cmd+S is Ghostty's prefix key),
**Ctrl+N** adds a cursor (Cmd+D splits), `Space b d` closes a tab (Cmd+W closes the pane),
**Shift+H / Shift+L** switch tabs. Cmd+click can't go to a definition because terminals
can't send Cmd with a mouse click, so it's Ctrl+click.

## Speed

The start screen opens in about 45 ms. Plugins load when they're first needed, built-in Vim
plugins this setup replaces are switched off, Mason checks for missing tools in the background
after startup, and TypeScript filters completions in the server.

## Layout

```
init.lua                 entry point
lua/config/              options, keymaps, autocmds, right-click menus, tool list
lua/plugins/             one file per area (lsp, git, explorer, ...)
ghostty/                 Ghostty look and the keys it hands to Neovim
scripts/bootstrap.lua    headless install of plugins, parsers and servers
install.sh               the installer above
```

To add a language: put its server in [`lua/config/tools.lua`](lua/config/tools.lua), then restart Neovim.

## License

[MIT](LICENSE)
