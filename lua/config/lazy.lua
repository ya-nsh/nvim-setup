-- lazy.nvim plugin manager. :Lazy opens its UI (update, clean, profile).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "gruvbox-material", "habamax" } },
  checker = { enabled = true, notify = false, frequency = 86400 }, -- check for updates daily, quietly; :Lazy shows them
  change_detection = { notify = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- Built-in plugins this setup replaces or never uses; skipping them speeds up startup
      disabled_plugins = { "gzip", "netrwPlugin", "rplugin", "tarPlugin", "tohtml", "zipPlugin" },
    },
  },
})
