-- General keymaps. Plugin keymaps live next to each plugin in lua/plugins/.
--
-- About Cmd keys: Ghostty passes Cmd shortcuts it doesn't use itself through to
-- Neovim as <D-...>. Ghostty keeps Cmd+S (your prefix), Cmd+W, Cmd+D, Cmd+K,
-- Cmd+F, Cmd+1-9, Cmd+[ ], Cmd+C/V/Z, so those VS Code actions use other keys here.
local map = vim.keymap.set

-- Save. Cmd+S is Ghostty's prefix, so Ctrl+S saves.
map({ "n", "x" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save file" })
map("i", "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

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

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit (asks to save)" })

-- Cheatsheet
local cheatsheet = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
vim.api.nvim_create_user_command("Cheatsheet", function()
  Snacks.win({
    file = cheatsheet,
    width = 0.75,
    height = 0.85,
    border = "rounded",
    title = " Cheatsheet  (q to close) ",
    title_pos = "center",
    bo = { modifiable = false, filetype = "markdown" },
    wo = { wrap = true, conceallevel = 2, spell = false, number = false, relativenumber = false },
  })
end, { desc = "Open the VS Code to Neovim cheatsheet" })
map("n", "<leader>?", "<cmd>Cheatsheet<cr>", { desc = "Cheatsheet" })
