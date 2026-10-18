-- snacks.nvim: fuzzy finder (Quick Open, search, command palette), terminal,
-- lazygit, start screen, notifications, indent guides and more in one plugin.
local function picker(name, opts)
  return function()
    Snacks.picker[name](opts)
  end
end

local function toggle_terminal()
  Snacks.terminal()
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true }, -- highlight other uses of the word under the cursor
    lazygit = { enabled = true },
    terminal = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true }, -- show dotfiles; .gitignore'd files stay hidden, like VS Code
        grep = { hidden = true },
      },
    },
  },
  keys = {
    -- VS Code shortcuts
    { "<D-p>", picker("files"), desc = "Quick open (Cmd+P)" },
    { "<D-S-p>", picker("commands"), desc = "Command palette (Cmd+Shift+P)" },
    { "<D-S-f>", picker("grep"), desc = "Search in files (Cmd+Shift+F)" },
    { "<D-S-o>", picker("lsp_symbols"), desc = "Go to symbol (Cmd+Shift+O)" },
    { "<D-S-m>", picker("diagnostics"), desc = "Problems (Cmd+Shift+M)" },
    { "<C-`>", toggle_terminal, mode = { "n", "t" }, desc = "Toggle terminal (Ctrl+`)" },
    { "<C-/>", toggle_terminal, mode = { "n", "t" }, desc = "Toggle terminal" },

    -- Find
    { "<leader><space>", picker("files"), desc = "Find files" },
    { "<leader>ff", picker("files"), desc = "Find files" },
    { "<leader>fr", picker("recent"), desc = "Recent files" },
    { "<leader>fb", picker("buffers"), desc = "Open tabs" },
    { "<leader>fc", picker("files", { cwd = vim.fn.stdpath("config") }), desc = "Find config file" },

    -- Search
    { "<leader>/", picker("grep"), desc = "Search in files" },
    { "<leader>sg", picker("grep"), desc = "Search in files" },
    { "<leader>sw", picker("grep_word"), mode = { "n", "x" }, desc = "Search word / selection" },
    { "<leader>sb", picker("lines"), desc = "Search in this file" },
    { "<leader>sc", picker("commands"), desc = "Commands" },
    { "<leader>sk", picker("keymaps"), desc = "Keymaps" },
    { "<leader>sh", picker("help"), desc = "Help pages" },
    { "<leader>ss", picker("lsp_symbols"), desc = "Symbols in file" },
    { "<leader>sS", picker("lsp_workspace_symbols"), desc = "Symbols in project" },
    { "<leader>sd", picker("diagnostics"), desc = "Problems" },
    { "<leader>sr", picker("resume"), desc = "Resume last search" },
    { "<leader>su", picker("undo"), desc = "Undo history" },
    { "<leader>xx", picker("diagnostics"), desc = "Problems" },

    -- Git
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gs", picker("git_status"), desc = "Changed files" },
    { "<leader>gl", picker("git_log"), desc = "Git log" },
    { "<leader>gf", picker("git_log_file"), desc = "Git log for this file" },

    -- Tabs (buffers)
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close tab" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Close other tabs" },

    -- Misc
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file (updates imports)" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous reference" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle.option("wrap", { name = "Word wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative line numbers" }):map("<leader>ul")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle
          .new({
            name = "Format on save",
            get = function()
              return vim.g.autoformat ~= false
            end,
            set = function(state)
              vim.g.autoformat = state
            end,
          })
          :map("<leader>uf")
      end,
    })
  end,
}
