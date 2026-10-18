-- Headless first-time setup, run by install.sh:
--   nvim --headless -c "luafile scripts/bootstrap.lua"
-- Installs plugins, syntax parsers, language servers and formatters, waiting for
-- each step, then exits with a non-zero code if anything failed.
local failed = {}
local function step(msg)
  io.stdout:write("==> " .. msg .. "\n")
end

local function finish()
  if #failed > 0 then
    io.stderr:write("\nSome parts failed to install:\n  " .. table.concat(failed, "\n  ") .. "\n")
    io.stderr:write("Open nvim and run :Lazy, :TSUpdate or :Mason to retry.\n")
    vim.cmd("cquit 1")
  end
  vim.cmd("qall!")
end

step("Installing plugins")
require("lazy").restore({ wait = true, show = false }) -- the exact versions in lazy-lock.json
for _, plugin in ipairs(require("lazy").plugins()) do
  if not plugin._.installed then
    failed[#failed + 1] = "plugin " .. plugin.name
  end
end

step("Installing syntax parsers")
require("lazy").load({ plugins = { "nvim-treesitter" } })
local parsers = require("config.tools").parsers
require("nvim-treesitter").install(parsers, { summary = true }):wait(30 * 60 * 1000)
local installed = {}
for _, lang in ipairs(require("nvim-treesitter").get_installed()) do
  installed[lang] = true
end
for _, lang in ipairs(parsers) do
  if not installed[lang] then
    failed[#failed + 1] = "parser " .. lang
  end
end

step("Installing language servers and formatters (this is the slow part)")
require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim" } })
local ok = require("mason-registry").refresh()
if not ok then
  failed[#failed + 1] = "Mason registry (no network?)"
  return finish()
end
local done = false
local started = require("config.install").install_missing(function(errors)
  vim.list_extend(failed, errors)
  done = true
end)
io.stdout:write(("    %d to install\n"):format(started))
if not vim.wait(30 * 60 * 1000, function()
  return done
end, 500) then
  failed[#failed + 1] = "Mason installs timed out"
end
finish()
