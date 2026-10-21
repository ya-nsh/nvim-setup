-- General keymaps. Plugin keymaps live next to each plugin in lua/plugins/.
--
-- About Cmd keys: Ghostty passes Cmd shortcuts it doesn't use itself through to
-- Neovim as <D-...>. ghostty/nvim.conf hands Cmd+Z, Cmd+Shift+Z, Cmd+F,
-- Cmd+Shift+F and Cmd+Shift+P to Neovim, and Cmd+C when Ghostty has no selection
-- of its own. Ghostty keeps Cmd+S (your prefix), Cmd+W, Cmd+D, Cmd+K, Cmd+1-9,
-- Cmd+[ ], so those use other keys here.
local map = vim.keymap.set

-- Save. Cmd+S is Ghostty's prefix, so Ctrl+S saves.
map({ "n", "x" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save file" })
map("i", "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

-- Copy / cut: Cmd+C / Cmd+X, like VS Code. With a selection they copy / cut it
-- (the selection stays after copying); with none they copy / cut the whole line.
-- Cmd+V needs no mapping: Ghostty pastes the clipboard straight into Neovim.
-- (y / d / p use the same macOS clipboard.)
map("x", "<D-c>", '"+ygv', { desc = "Copy (Cmd+C)" })
map("n", "<D-c>", '"+yy', { desc = "Copy line (Cmd+C)" })
map("i", "<D-c>", '<C-o>"+yy', { desc = "Copy line (Cmd+C)" })
map("x", "<D-x>", '"+d', { desc = "Cut (Cmd+X)" })
map("n", "<D-x>", '"+dd', { desc = "Cut line (Cmd+X)" })
map("i", "<D-x>", '<C-o>"+dd', { desc = "Cut line (Cmd+X)" })

-- Undo / redo: Cmd+Z / Cmd+Shift+Z (u / Ctrl+R also work)
map("n", "<D-z>", "u", { desc = "Undo (Cmd+Z)" })
map("x", "<D-z>", "<esc>u", { desc = "Undo (Cmd+Z)" })
map("i", "<D-z>", "<C-o>u", { desc = "Undo (Cmd+Z)" })
for _, lhs in ipairs({ "<D-S-z>", "<D-Z>" }) do -- Ghostty may report Cmd+Shift+Z either way
  map("n", lhs, "<C-r>", { desc = "Redo (Cmd+Shift+Z)" })
  map("x", lhs, "<esc><C-r>", { desc = "Redo (Cmd+Shift+Z)" })
  map("i", lhs, "<C-o><C-r>", { desc = "Redo (Cmd+Shift+Z)" })
end

-- Undo in smaller steps while typing (VS Code undoes about a phrase at a time,
-- Vim would undo the whole insert)
for _, char in ipairs({ ",", ".", ";", "!", "?" }) do
  map("i", char, char .. "<C-g>u")
end

-- Find in file: Cmd+F starts a search (type, Enter, then n / N for next / previous).
-- With a selection, Cmd+F searches for the selected text.
map("n", "<D-f>", "/", { desc = "Find in file (Cmd+F)" })
map("i", "<D-f>", "<esc>/", { desc = "Find in file (Cmd+F)" })
map("x", "<D-f>", "*", { remap = true, desc = "Find selection in file (Cmd+F)" })

-- Back / forward through places you've been: files you opened, definitions you
-- jumped to, searches. VS Code: Ctrl+- / Ctrl+Shift+-. Vim: Ctrl+O / Ctrl+I.
-- Mouse back / forward buttons work too.
map("n", "<C-->", "<C-o>", { desc = "Go back (Ctrl+-)" })
map("n", "<C-S-->", "<C-i>", { desc = "Go forward (Ctrl+Shift+-)" })
map("n", "<C-S-_>", "<C-i>", { desc = "Go forward (Ctrl+Shift+-)" }) -- some keyboard layouts
map("n", "<X1Mouse>", "<C-o>", { desc = "Go back (mouse)" })
map("n", "<X2Mouse>", "<C-i>", { desc = "Go forward (mouse)" })

-- Clear search highlight with Esc
map({ "n", "i" }, "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Clear search highlight" })

-- Cmd+/ toggles comments (built on Neovim's gc / gcc)
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("x", "<D-/>", "gc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("i", "<D-/>", "<cmd>normal gcc<cr>", { desc = "Toggle comment (Cmd+/)" })

-- Alt+Up/Down moves lines
map("n", "<M-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
map("n", "<M-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
map("i", "<M-Down>", "<esc><cmd>move .+1<cr>==gi", { desc = "Move line down" })
map("i", "<M-Up>", "<esc><cmd>move .-2<cr>==gi", { desc = "Move line up" })
map("x", "<M-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move lines down" })
map("x", "<M-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move lines up" })

-- Shift+Alt+Up/Down duplicates lines
map({ "n", "i" }, "<M-S-Down>", "<cmd>copy .<cr>", { desc = "Duplicate line down" })
map({ "n", "i" }, "<M-S-Up>", "<cmd>copy .-1<cr>", { desc = "Duplicate line up" })
map("x", "<M-S-Down>", ":<C-u>'<,'>copy '><cr>'[V']", { desc = "Duplicate lines down" })
map("x", "<M-S-Up>", ":<C-u>'<,'>copy '<-1<cr>'[V']", { desc = "Duplicate lines up" })

-- Cmd+Shift+K deletes the line (without overwriting the clipboard)
map("n", "<D-S-k>", '"_dd', { desc = "Delete line (Cmd+Shift+K)" })
map("i", "<D-S-k>", '<cmd>normal! "_dd<cr>', { desc = "Delete line (Cmd+Shift+K)" })

-- Tab / Shift+Tab indent a selection and keep it selected
map("x", "<Tab>", ">gv", { desc = "Indent" })
map("x", "<S-Tab>", "<gv", { desc = "Outdent" })
map("x", ">", ">gv", { desc = "Indent" })
map("x", "<", "<gv", { desc = "Outdent" })

-- Ghostty turns Cmd+Left/Right into Ctrl+A/Ctrl+E (shell line start/end).
-- Make them do the same in Neovim instead of incrementing numbers or scrolling.
map({ "n", "x" }, "<C-a>", "^", { desc = "Line start (Cmd+Left)" })
map({ "n", "x" }, "<C-e>", "$", { desc = "Line end (Cmd+Right)" })
map("i", "<C-a>", "<C-o>^", { desc = "Line start (Cmd+Left)" })
map("i", "<C-e>", "<End>", { desc = "Line end (Cmd+Right)" })

-- Ghostty turns Option+Left/Right into Alt+B/Alt+F (word back/forward)
map({ "n", "x" }, "<M-b>", "b", { desc = "Word back (Option+Left)" })
map({ "n", "x" }, "<M-f>", "w", { desc = "Word forward (Option+Right)" })
map("i", "<M-b>", "<C-Left>", { desc = "Word back (Option+Left)" })
map("i", "<M-f>", "<C-Right>", { desc = "Word forward (Option+Right)" })
map("c", "<M-b>", "<S-Left>", { desc = "Word back (Option+Left)" })
map("c", "<M-f>", "<S-Right>", { desc = "Word forward (Option+Right)" })
map("i", "<M-BS>", "<C-w>", { desc = "Delete word (Option+Backspace)" })

-- Move between splits (and the explorer) with Ctrl+h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split down" })

-- F8 / Shift+F8 jump between problems
map("n", "<F8>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next problem (F8)" })
local function prev_problem()
  vim.diagnostic.jump({ count = -1, float = true })
end
map("n", "<S-F8>", prev_problem, { desc = "Previous problem (Shift+F8)" })
map("n", "<F20>", prev_problem, { desc = "Previous problem (Shift+F8)" }) -- how Ghostty reports Shift+F8
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Show problem under cursor" })

-- Right-click menus (see config/context_menu.lua)
require("config.context_menu").setup()

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit (asks to save)" })

-- Help: ? opens a window explaining every shortcut (CHEATSHEET.md).
-- This replaces Vim's backward search; search forward with / and use N instead.
-- In the explorer, Lazy and Mason, ? still shows that window's own keys.
local function help()
  require("config.help").toggle()
end
vim.api.nvim_create_user_command("Cheatsheet", help, { desc = "Every shortcut, explained" })
map("n", "?", help, { desc = "Help: every shortcut explained" })
map("n", "<leader>?", help, { desc = "Help: every shortcut explained" })
