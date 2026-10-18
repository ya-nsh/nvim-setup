-- Right-click menus, like VS Code's context menus.
--   In code:         Go to Definition, Find All References, Rename Symbol, ...
--   In the explorer: Find in Folder..., New File..., Rename..., Reveal in Finder, ...
-- Neovim shows these as its own popup menu at the mouse.
local M = {}

-- Menu name -> { [item index] = function }, rebuilt every time a menu opens
local actions = {}

-- Escape text for a :menu path (spaces, dots, backslashes, bars, &)
local function escape(text)
  local s = text:gsub("[%s%.\\|]", "\\%0")
  s = s:gsub("&", "&&")
  return s
end

---@class ContextMenuItem
---@field [1] string label
---@field [2] string|function command (a string is a raw key sequence)
---@field key? string shortcut shown on the right
---@field mode? string "a" (all), "n" or "v"
---@field enabled? boolean

--- (Re)define menu `name` from items and "-" separators.
---@param name string
---@param items (ContextMenuItem|"-")[]
local function define(name, items)
  pcall(vim.cmd, "aunmenu " .. name)
  actions[name] = {}
  for i, item in ipairs(items) do
    if item == "-" then
      vim.cmd(("anoremenu %s.-sep%d- <Nop>"):format(name, i))
    else
      local path = name .. "." .. escape(item[1])
      if item.key then
        path = path .. "<Tab>" .. escape(item.key)
      end
      local rhs = item[2]
      if type(rhs) == "function" then
        actions[name][i] = rhs
        rhs = ("<Cmd>lua require('config.context_menu').run(%q, %d)<CR>"):format(name, i)
      end
      vim.cmd(("%snoremenu %s %s"):format(item.mode or "a", path, rhs))
      if item.enabled == false then
        vim.cmd(("%smenu disable %s"):format(item.mode or "a", path))
      end
    end
  end
end

function M.run(name, index)
  local fn = actions[name] and actions[name][index]
  if fn then
    fn()
  end
end

-- Menu for code (and any other normal buffer)
local function code_menu()
  local has_lsp = #vim.lsp.get_clients({ bufnr = 0 }) > 0
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local has_problem = #vim.diagnostic.get(0, { lnum = line }) > 0
  local modifiable = vim.bo.modifiable and vim.bo.buftype == ""

  define("PopUp", {
    {
      "Go to Definition",
      function()
        Snacks.picker.lsp_definitions()
      end,
      key = "F12",
      enabled = has_lsp,
    },
    {
      "Go to Type Definition",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      enabled = has_lsp,
    },
    {
      "Find All References",
      function()
        Snacks.picker.lsp_references()
      end,
      key = "Shift+F12",
      enabled = has_lsp,
    },
    { "Rename Symbol", vim.lsp.buf.rename, key = "F2", enabled = has_lsp and modifiable },
    { "Quick Fix / Code Action", vim.lsp.buf.code_action, key = "Cmd+.", enabled = has_lsp },
    { "Show Problem", vim.diagnostic.open_float, enabled = has_problem },
    "-",
    { "Cut", '"+x', key = "x", mode = "v" },
    { "Copy", '"+y', key = "y", mode = "v" },
    { "Paste", '"+gP', key = "p", mode = "n", enabled = modifiable },
    { "Paste", '"+P', key = "p", mode = "v" },
    { "Select All", "ggVG", mode = "n" },
    "-",
    {
      "Format Document",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      enabled = modifiable,
    },
    {
      "Blame This Line",
      function()
        require("gitsigns").blame_line({ full = true })
      end,
    },
  })
  vim.cmd.popup("PopUp")
end

local function copy(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. text)
end

-- Menu for a file or folder in the explorer
local function explorer_menu(winid)
  local state = require("neo-tree.sources.manager").get_state_for_window(winid)
  local node = state and state.tree and state.tree:get_node()
  if not node or not node.path then
    return
  end
  local cmds = require("neo-tree.sources." .. state.name .. ".commands")
  local path = node.path
  local is_dir = node.type == "directory"
  local folder = is_dir and path or vim.fn.fnamemodify(path, ":h")
  local function cmd(name)
    return function()
      if cmds[name] then
        cmds[name](state)
      end
    end
  end

  local items = {}
  local function add(item)
    items[#items + 1] = item
  end
  if not is_dir then
    add({ "Open", cmd("open"), key = "Enter" })
    add({ "Open to the Side", cmd("open_vsplit") })
    add("-")
  end
  add({
    "Find in Folder...",
    function()
      M.find_in_folder(folder)
    end,
    key = "F",
  })
  add({
    "Find File in Folder...",
    function()
      M.find_file_in_folder(folder)
    end,
  })
  add("-")
  add({ "New File...", cmd("add"), key = "a" })
  add({ "New Folder...", cmd("add_directory"), key = "A" })
  add({ "Rename...", cmd("rename"), key = "r" })
  add({ "Delete", cmd("delete"), key = "d" })
  add("-")
  add({
    "Copy Path",
    function()
      copy(path)
    end,
  })
  add({
    "Copy Relative Path",
    function()
      copy(vim.fn.fnamemodify(path, ":."))
    end,
  })
  add({
    "Reveal in Finder",
    function()
      vim.system({ "open", "-R", path })
    end,
  })
  add({
    "Open in Terminal",
    function()
      Snacks.terminal(nil, { cwd = folder })
    end,
  })
  if is_dir then
    add({
      "Show Folder History",
      function()
        vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(path))
      end,
    })
  else
    add({
      "Show File History",
      function()
        vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(path))
      end,
    })
  end

  define("]Explorer", items)
  vim.cmd.popup("]Explorer")
end

local function short(dir)
  return vim.fn.fnamemodify(dir, ":~:.")
end

--- Search text inside one folder (VS Code: right-click folder > Find in Folder)
function M.find_in_folder(dir)
  Snacks.picker.grep({ dirs = { dir }, title = "Find in " .. short(dir) })
end

function M.find_file_in_folder(dir)
  Snacks.picker.files({ dirs = { dir }, title = "Files in " .. short(dir) })
end

--- Folder of the explorer item under the cursor (the item itself if it's a folder)
function M.folder_of_node(state)
  local node = state.tree:get_node()
  if not node or not node.path then
    return nil
  end
  return node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
end

-- Called on right-click. Moves the cursor to the click, then shows the menu
-- for whatever was clicked. Floating windows and bars keep Neovim's default.
function M.open()
  local pos = vim.fn.getmousepos()
  local win = pos.winid
  if win == 0 or pos.line == 0 or vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  vim.api.nvim_set_current_win(win)
  pcall(vim.api.nvim_win_set_cursor, win, { pos.line, math.max(pos.column - 1, 0) })
  if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
    explorer_menu(win)
  else
    code_menu()
  end
end

-- Right-click mapping: our menus for code and the explorer, Neovim's default
-- (selection-aware popup, tab bar clicks) everywhere else.
function M.setup()
  vim.keymap.set("n", "<RightMouse>", function()
    local pos = vim.fn.getmousepos()
    if pos.winid == 0 or pos.line == 0 or vim.api.nvim_win_get_config(pos.winid).relative ~= "" then
      return "<RightMouse>"
    end
    return "<Cmd>lua require('config.context_menu').open()<CR>"
  end, { expr = true, desc = "Context menu" })

  -- Right-click with a selection (visual mode): same code menu, keeping the selection
  vim.keymap.set("x", "<RightMouse>", function()
    local pos = vim.fn.getmousepos()
    if pos.winid ~= vim.api.nvim_get_current_win() then
      return "<RightMouse>"
    end
    return "<Cmd>lua require('config.context_menu').code_menu()<CR>"
  end, { expr = true, desc = "Context menu" })
end

M.code_menu = code_menu

return M
