# VS Code → Neovim cheatsheet

Press **`?`** anywhere to open this window. In it: `Tab` / `Shift+Tab` jump between sections,
`/` searches, and `q`, `Esc` or `?` close it.

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
| Cmd+Shift+F | Cmd+Shift+F | Search in files (also `<Space>/`). With a selection: search for it |
| Cmd+F | Cmd+F | Find in file: type, Enter, then `n` / `N` next / previous. Esc clears highlights |
| Cmd+Z / Cmd+Shift+Z | Cmd+Z / Cmd+Shift+Z | Undo / redo (also `u` / `Ctrl+r`) |
| Cmd+click | **Ctrl+click** | Go to definition. Terminals can't send Cmd with a click |
| Ctrl+- / Ctrl+Shift+- | Ctrl+- / Ctrl+Shift+- | Go back / forward (also `Ctrl+o` / `Ctrl+i`, mouse side buttons) |
| Right-click | Right-click | Menu: definition, references, rename, copy / paste, format |
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

Ghostty's own search, undo and command palette moved to **Cmd+S then F / U / P**.

| VS Code | Here | Why |
|---|---|---|
| Cmd+S (save) | **Ctrl+S** | Cmd+S is your Ghostty prefix |
| Cmd+W (close tab) | `<Space>bd` | Cmd+W closes the Ghostty pane |
| Cmd+D (next match) | **Ctrl+N** | Cmd+D splits Ghostty. Esc clears cursors |
| Cmd+Shift+L (all matches) | `<Space>ma` | |
| Option+click (add cursor) | Option+click | |
| Cmd+H (replace) | `:%s/old/new/g` | Shows a live preview |
| Ctrl+Tab (next tab) | **Shift+L** / **Shift+H** | Same as your Ghostty tab keys |
| Cmd+1…9 (tab N) | `<Space>1` … `<Space>9` | |
| Cmd+G (go to line) | `42G` or `:42` | |
| Cmd+C / Cmd+V | `y` / `p` | Both use the macOS clipboard. Cmd+V also pastes |
| Shift+Alt+F (format) | `<Space>cf` | Files also format on save |

## Explorer (Cmd+B)

`a` new file (end with `/` for a folder) · `d` delete · `r` rename · `c` copy · `m` move ·
`F` find in folder · `H` hidden files · `/` filter · `l` / `h` open / close · `?` explorer keys.
**Right-click** a file or folder: Find in Folder, New File, Rename, Delete, Copy Path,
Reveal in Finder, Open in Terminal, File History. Renames update imports.

## Git, GitLens-style

The end of the current line shows who last changed it, when, and the commit message.

| Keys | What |
|---|---|
| `<Space>gc` | **Commit history.** Every commit, newest first, with the files it changed. `j` / `k` move, `Enter` (or double-click) opens a file's diff, `za` expands / collapses a commit, `L` shows full commit details |
| `<Space>gf` | History of this file. Select lines first to see only commits that touched them |
| `<Space>gd` | All uncommitted changes, side by side |
| `<Space>go` | Open the commit that last changed this line |
| `<Space>gb` | Popup: full commit message for this line |
| `<Space>gB` | Blame the whole file in a sidebar |
| `]h` / `[h` | Next / previous changed block in this file |
| `<Space>gg` | lazygit: stage, commit, push, branches |

In any history or diff view: `Tab` next file, `g?` all keys, `q` closes it.

## In a finder (Cmd+P, Cmd+Shift+F, ...)

Type to filter · `↑` / `↓` or `Ctrl+j` / `Ctrl+k` move · `Enter` open ·
`Ctrl+v` open in split · `Esc` close · `<Space>sr` reopens the last one.

## Leader menus

| Keys | Menu |
|---|---|
| `<Space>f` | find: files, recent, open tabs, config |
| `<Space>s` | search: text, word, symbols, keymaps, help, undo history |
| `<Space>c` | code: action, rename, format, organize imports, rename file |
| `<Space>g` | git: commits (`gc`), file history (`gf`), diff (`gd`), blame (`gb` / `gB`), lazygit (`gg`) |
| `<Space>b` | tabs: close, close others, pin, move |
| `<Space>m` | multi-cursor |
| `<Space>u` | toggles: wrap, relative numbers, inlay hints, problems, format on save, inline blame (`ub`) |
| `<Space>q` | quit, restore session |
| `<Space>x` | problems |

## Vim moves worth learning first

`w` / `b` word forward / back · `0` / `$` line start / end · `gg` / `G` top / bottom ·
`Ctrl+d` / `Ctrl+u` half page · `%` matching bracket · `ciw` change word · `ci"` change inside quotes ·
`dap` delete paragraph · `.` repeat last edit · `*` search word under cursor.
`?` is this help, not Vim's backward search: search with `/`, then `N` goes backward.

## Housekeeping

`:Lazy` plugins · `:Mason` language servers · `:checkhealth` diagnose problems ·
`<Space>fc` edit this config · `~/.config/nvim/CHEATSHEET.md` is this file.
