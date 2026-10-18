-- Installs the language servers and formatters listed in config/tools.lua that
-- are missing. Runs in the background a few seconds after startup, and
-- synchronously from scripts/bootstrap.lua when setting up a new machine.
local M = {}

--- Mason package names for every server and formatter in config/tools.lua
function M.package_names()
  local tools = require("config.tools")
  local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package
  local names = {}
  for _, server in ipairs(tools.servers) do
    names[#names + 1] = to_package[server] or server
  end
  vim.list_extend(names, tools.formatters)
  return names
end

--- Start installing whatever is missing.
---@param on_done? fun(failed: string[]) called once every install has finished
---@return integer count of installs started
function M.install_missing(on_done)
  local registry = require("mason-registry")
  local pending, failed = 0, {}
  local function finish()
    if pending == 0 and on_done then
      on_done(failed)
    end
  end
  for _, name in ipairs(M.package_names()) do
    local ok, pkg = pcall(registry.get_package, name)
    if not ok then
      failed[#failed + 1] = name .. " (not in the Mason registry)"
    elseif not pkg:is_installed() and not pkg:is_installing() then
      pending = pending + 1
      pkg:install({}, function(success, err)
        if not success then
          failed[#failed + 1] = name .. ": " .. tostring(err)
        end
        pending = pending - 1
        vim.schedule(finish)
      end)
    end
  end
  local started = pending
  finish()
  return started
end

--- Check the registry, then install missing packages (async; used at runtime)
function M.background()
  require("mason-registry").refresh(function(ok)
    if ok then
      M.install_missing(function(failed)
        if #failed > 0 then
          vim.notify("Mason couldn't install:\n" .. table.concat(failed, "\n"), vim.log.levels.WARN)
        end
      end)
    end
  end)
end

return M
