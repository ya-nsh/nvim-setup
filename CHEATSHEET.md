# VS Code → Neovim cheatsheet

`<Space>` is the **leader** key. Press it and wait: a menu shows what comes next.
Can't remember a key? `<Space>sk` searches every keymap. Learn Vim itself with `:Tutor`.

## The three modes you need

| Mode | What it is | Get there |
|---|---|---|
| Normal | Moving around and running commands (default) | `Esc` |
| Insert | Typing text, like VS Code | `i` (before cursor), `a` (after), `o` (new line below) |
| Visual | Selecting | `v` (characters), `V` (lines), `Ctrl+v` (block), or Shift+arrows / mouse drag |

## VS Code shortcuts that work here

| VS Code | Here | Notes |
|---|---|---|
| Cmd+P | Cmd+P | Quick open (also `<Space><Space>`) |
| Cmd+Shift+P | Cmd+Shift+P | Command palette (also `<Space>sc`) |
| Cmd+Shift+F | Cmd+Shift+F | Search in files (also `<Space>/`) |
| Cmd+B | Cmd+B | Toggle explorer (also `<Space>e`) |
| Cmd+Shift+E | Cmd+Shift+E | Show current file in explorer |
| Cmd+/ | Cmd+/ | Toggle comment (also `gcc`, or `gc` on a selection) |
| Cmd+. | Cmd+. | Quick fix / code action (also `<Space>ca`) |
| Cmd+Shift+O | Cmd+Shift+O | Go to symbol in file |
| Cmd+Shift+M | Cmd+Shift+M | Problems list |
| Cmd+Shift+K | Cmd+Shift+K | Delete line (also `dd`) |
| F12 / Shift+F12 | F12 / Shift+F12 | Definition / references (also `gd` / `grr`) |
| F2 | F2 | Rename symbol (also `<Space>cr`) |
| F8 / Shift+F8 | F8 / Shift+F8 | Next / previous problem (also `]d` / `[d`) |
| Alt+↑ / Alt+↓ | Option+↑ / Option+↓ | Move line(s) |
| Shift+Alt+↑ / ↓ | Shift+Option+↑ / ↓ | Duplicate line(s) |
| Ctrl+` | Ctrl+` | Toggle terminal (Esc Esc for Normal mode inside it) |
| Tab / Shift+Tab on selection | same | Indent / outdent |
| Cmd+← / Cmd+→ | same | Line start / end |
| Option+← / → | same | Word left / right |
| Hover | `K` | Docs for the symbol under the cursor |

## Different because Ghostty uses the key

| VS Code | Here | Why |
|---|---|---|
| Cmd+S (save) | **Ctrl+S** | Cmd+S is your Ghostty prefix |
| Cmd+W (close tab) | `<Space>bd` | Cmd+W closes the Ghostty pane |
| Cmd+D (next match) | **Ctrl+N** | Cmd+D splits Ghostty. Esc clears cursors |
| Cmd+Shift+L (all matches) | `<Space>ma` | |
| Option+click (add cursor) | Option+click | |
| Cmd+F (find in file) | `/` then text, `n` / `N` next / prev | Cmd+F is Ghostty search |
| Cmd+H (replace) | `:%s/old/new/g` | Shows a live preview |
| Ctrl+Tab (next tab) | **Shift+L** / **Shift+H** | Same as your Ghostty tab keys |
| Cmd+1…9 (tab N) | `<Space>1` … `<Space>9` | |
| Cmd+G (go to line) | `42G` or `:42` | |
| Cmd+Z / Cmd+Shift+Z | `u` / `Ctrl+r` | |
| Cmd+C / Cmd+V | `y` / `p` | Both use the macOS clipboard. Cmd+V also pastes |
| Shift+Alt+F (format) | `<Space>cf` | Files also format on save |

## Explorer (Cmd+B)

`a` new file (end with `/` for a folder) · `d` delete · `r` rename · `c` copy · `m` move ·
`H` hidden files · `/` filter · `l` / `h` open / close · `?` all keys. Renames update imports.

## In a finder (Cmd+P, Cmd+Shift+F, ...)

Type to filter · `↑` / `↓` or `Ctrl+j` / `Ctrl+k` move · `Enter` open ·
`Ctrl+v` open in split · `Esc` close · `<Space>sr` reopens the last one.

## Leader menus

| Keys | Menu |
|---|---|
| `<Space>f` | find: files, recent, open tabs, config |
| `<Space>s` | search: text, word, symbols, keymaps, help, undo history |
| `<Space>c` | code: action, rename, format, organize imports, rename file |
| `<Space>g` | git: lazygit (`gg`), changed files, log, blame, changes (`gh`) |
| `<Space>b` | tabs: close, close others, pin, move |
| `<Space>m` | multi-cursor |
| `<Space>u` | toggles: wrap, relative numbers, inlay hints, problems, format on save |
| `<Space>q` | quit, restore session |
| `<Space>x` | problems |

## Vim moves worth learning first

`w` / `b` word forward / back · `0` / `$` line start / end · `gg` / `G` top / bottom ·
`Ctrl+d` / `Ctrl+u` half page · `%` matching bracket · `ciw` change word · `ci"` change inside quotes ·
`dap` delete paragraph · `.` repeat last edit · `*` search word under cursor · `]h` / `[h` next / prev git change.

## Housekeeping

`:Lazy` plugins · `:Mason` language servers · `:checkhealth` diagnose problems ·
`<Space>fc` edit this config · `~/.config/nvim/CHEATSHEET.md` is this file.
