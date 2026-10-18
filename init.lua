-- Neovim config tuned for someone coming from VS Code.
-- New here? Press <Space>? (or run :Cheatsheet) for the key map.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
