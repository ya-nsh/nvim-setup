-- Neovim config tuned for someone coming from VS Code.
-- New here? Press ? (or run :Cheatsheet) for every shortcut, explained.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
