-- Makes codediff.nvim read like VS Code's Source Control and GitLens:
--   * each diff pane has a title saying what it shows ("Before: last commit",
--     "After: your changes"), since that's otherwise easy to mix up
--   * commit rows read "message · author, 4d", like GitLens
--   * single click opens a file or commit (codediff only does double-click)
--   * narrow windows get the one-column (inline) diff, like VS Code does
--   * real line numbers, no lint messages over the diff, diff buffers kept out
--     of the tab bar
local M = {}

local EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

local function truncate(text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  return vim.fn.strcharpart(text, 0, math.max(width - 1, 1)) .. "…"
end

-- Commit descriptions for pane titles, cached per sha
local commit_info = {}
local function describe_commit(sha, root)
  if commit_info[sha] == nil then
    local out = vim.system({ "git", "log", "-1", "--format=%h\t%s\t%an, %ar", sha }, { cwd = root, text = true }):wait()
    local short, subject, who = (out.stdout or ""):match("^(.-)\t(.-)\t(.-)\n?$")
    commit_info[sha] = short and { short = short, subject = subject, who = who } or false
  end
  return commit_info[sha] or nil
end

local head_cache = {}
local function head_sha(root)
  if not head_cache[root] then
    local out = vim.system({ "git", "rev-parse", "HEAD" }, { cwd = root, text = true }):wait()
    head_cache[root] = out.code == 0 and vim.trim(out.stdout) or ""
  end
  return head_cache[root]
end

--- What one side of a diff shows: a full description and a short one
---@param rev string|nil codediff revision: nil = file on disk, ":0" = staged, else a commit
---@return { long: string, short: string }
local function describe_side(rev, root, head)
  if rev == nil or rev == "WORKING" then
    return { long = "your changes (file on disk)", short = "your changes" }
  elseif rev == ":0" or rev == ":" then
    return { long = "staged version", short = "staged" }
  elseif rev == EMPTY_TREE then
    return { long = "nothing", short = "nothing" }
  end
  local info = describe_commit(rev, root)
  if not info then
    return { long = rev:sub(1, 8), short = rev:sub(1, 8) }
  end
  if rev == head then
    return { long = ("last commit · %s %s"):format(info.short, info.subject), short = "last commit" }
  end
  return { long = ("%s %s · %s"):format(info.short, info.subject, info.who), short = info.short .. " " .. info.subject }
end

local function set_title(win, text, hl)
  if win and vim.api.nvim_win_is_valid(win) then
    local escaped = truncate(text, vim.api.nvim_win_get_width(win) - 2):gsub("%%", "%%%%")
    vim.wo[win].winbar = "%#" .. hl .. "# " .. escaped .. " %*"
  end
end

--- Title the diff panes of a codediff tab and tidy them up
function M.update_titles(tab)
  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  if not ok or not vim.api.nvim_tabpage_is_valid(tab) then
    return
  end
  local sess = lifecycle.get_session(tab)
  if not sess or sess.result_win then -- the conflict view titles its own panes
    return
  end
  local ctx = lifecycle.get_git_context(tab) or {}
  local root = ctx.git_root or vim.fn.getcwd()
  local head = head_sha(root)
  local orig_win, mod_win = lifecycle.get_windows(tab)
  local orig_buf, mod_buf = lifecycle.get_buffers(tab)
  local function valid_win(w)
    return w and vim.api.nvim_win_is_valid(w)
  end
  local function valid_buf(b)
    return b and vim.api.nvim_buf_is_valid(b)
  end

  local before = describe_side(ctx.original_revision, root, head)
  local after = describe_side(ctx.modified_revision, root, head)
  local is_new = not valid_buf(orig_buf) or ctx.original_revision == EMPTY_TREE
  local is_deleted = not valid_buf(mod_buf)

  if valid_win(orig_win) and valid_win(mod_win) and orig_win ~= mod_win then
    -- Side by side
    set_title(orig_win, is_new and "Before: nothing (new file)" or ("Before: " .. before.long), "CodeDiffTitleBefore")
    set_title(
      mod_win,
      is_deleted and "After: nothing (file deleted)" or ("After: " .. after.long),
      "CodeDiffTitleAfter"
    )
  else
    -- One pane (inline layout, or a file that only exists on one side)
    local title
    if is_new then
      title = "New file · " .. after.long
    elseif is_deleted then
      title = "Deleted file · was in " .. before.long
    elseif lifecycle.get_panel_name(tab) == "history" then
      title = "Changes in " .. after.long -- red = before this commit, green = after
    else
      title = ("Red = %s  →  Green = %s"):format(before.short, after.short)
    end
    set_title(valid_win(mod_win) and mod_win or orig_win, title, "CodeDiffTitleAfter")
  end

  for _, win in ipairs({ orig_win, mod_win }) do
    if valid_win(win) then
      vim.wo[win].relativenumber = false -- real line numbers, like VS Code
    end
  end
  -- Keep the read-only "before" copies out of the tab bar
  for _, buf in ipairs({ orig_buf, mod_buf }) do
    if valid_buf(buf) and vim.api.nvim_buf_get_name(buf):match("^codediff://") then
      vim.bo[buf].buflisted = false
    end
  end
end

-- "4 days ago" -> "4d", "2 weeks ago" -> "2w", "3 months ago" -> "3mo"
local function short_age(relative)
  if not relative or relative == "" then
    return ""
  end
  local n, unit = relative:match("^(%d+) (%a+)")
  if not n then
    return relative
  end
  local units = {
    second = "s",
    minute = "m",
    hour = "h",
    day = "d",
    week = "w",
    month = "mo",
    year = "y",
  }
  local suffix = units[unit:gsub("s$", "")]
  if unit:match("^second") then
    return "now"
  end
  return suffix and (n .. suffix) or relative
end

-- GitLens-style commit row: "▸ (main) message · author, 4d  +4 −1"
-- (the +/− counts are dropped when they'd cut the message short)
local function patch_history_rows()
  local ok, nodes = pcall(require, "codediff.ui.history.nodes")
  local ok_line, Line = pcall(require, "codediff.ui.lib.line")
  if not ok or not ok_line or nodes._user_patched then
    return
  end
  local original = nodes.prepare_node
  local function commit_row(node, max_width, selected_commit, selected_file, single_file)
    local data = node.data
    local selected = data.hash == selected_commit and (single_file or not selected_file)
    local sel_bg = selected and vim.api.nvim_get_hl(0, { name = "CodeDiffExplorerSelected", link = false }).bg
    local function hl(name)
      if not selected then
        return name
      end
      local combined = "CodeDiffHistorySel_" .. name
      vim.api.nvim_set_hl(0, combined, { fg = vim.api.nvim_get_hl(0, { name = name, link = false }).fg, bg = sel_bg })
      return combined
    end

    local icon = node:is_expanded() and " " or " "
    local refs = (data.ref_names and data.ref_names ~= "") and (data.ref_names:gsub("HEAD %-> ", "")) or nil
    local ref_text = refs and ("(" .. refs .. ") ") or ""
    local who = " · " .. (data.author or "?") .. ", " .. short_age(data.date_relative)
    local stats = ("  +%d −%d"):format(data.insertions or 0, data.deletions or 0)
    local subject = data.subject ~= "" and data.subject or "[no message]"
    local width = max_width or 60
    local base = vim.fn.strdisplaywidth(icon .. ref_text .. who)
    local show_stats = base + vim.fn.strdisplaywidth(subject .. stats) <= width
    subject = truncate(subject, math.max(width - base, 16))

    local line = Line()
    line:append(icon, hl("NonText"))
    if refs then
      line:append(ref_text, hl("CodeDiffHistoryRef"))
    end
    line:append(subject, hl("Normal"))
    line:append(who, hl("Comment"))
    if show_stats then
      line:append("  +" .. (data.insertions or 0), hl("Added"))
      line:append(" −" .. (data.deletions or 0), hl("Removed"))
    end
    if selected and max_width then
      local used = vim.fn.strdisplaywidth(line:content())
      if used < max_width then
        line:append(string.rep(" ", max_width - used), hl("Normal"))
      end
    end
    return line
  end
  nodes.prepare_node = function(node, max_width, selected_commit, selected_file, single_file)
    if node.data and node.data.type == "commit" then
      local ok_row, line = pcall(commit_row, node, max_width, selected_commit, selected_file, single_file)
      if ok_row then
        return line
      end
    end
    return original(node, max_width, selected_commit, selected_file, single_file)
  end
  nodes._user_patched = true
end

-- VS Code-style title colours on Ghostty's background
local function set_colors()
  local set = vim.api.nvim_set_hl
  set(0, "CodeDiffTitleBefore", { fg = "#ea6962", bg = "#2a2223", bold = true })
  set(0, "CodeDiffTitleAfter", { fg = "#a9b665", bg = "#232a1f", bold = true })
  set(0, "CodeDiffHistoryRef", { fg = "#d8a657", bold = true })
  set(0, "Added", { fg = "#a9b665", default = true })
  set(0, "Removed", { fg = "#ea6962", default = true })
end

--- Side by side when there's room for two ~55-column panes, otherwise one
--- column, like VS Code's "use inline view when space is limited"
function M.pick_layout()
  local config = require("codediff.config")
  local sidebar = config.options.explorer.width or 40
  config.options.diff.layout = (vim.o.columns - sidebar) >= 110 and "side-by-side" or "inline"
end

--- Run a :CodeDiff command with the layout that fits the window
function M.open(args)
  return function()
    M.pick_layout()
    vim.cmd("CodeDiff" .. (args and (" " .. args) or ""))
  end
end

-- Lint messages written over a diff make it hard to read: hide them while a
-- diff tab is in front (underlines stay), bring them back when you leave it
local saved_virtual_text = nil
local function in_diff_tab()
  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  return ok and lifecycle.get_session(vim.api.nvim_get_current_tabpage()) ~= nil
end
local function sync_diagnostics()
  if in_diff_tab() then
    if saved_virtual_text == nil then
      saved_virtual_text = vim.diagnostic.config().virtual_text or false
      vim.diagnostic.config({ virtual_text = false })
    end
  elseif saved_virtual_text ~= nil then
    vim.diagnostic.config({ virtual_text = saved_virtual_text })
    saved_virtual_text = nil
  end
end

function M.setup()
  patch_history_rows()
  set_colors()
  local group = vim.api.nvim_create_augroup("user_codediff_ui", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_colors })

  -- Scheduled: codediff clears winbars in its own handlers for the same events
  local function refresh()
    local tab = vim.api.nvim_get_current_tabpage()
    vim.schedule(function()
      M.update_titles(tab)
      sync_diagnostics()
    end)
  end
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "CodeDiffOpen", "CodeDiffFileSelect", "CodeDiffVirtualFileLoaded", "CodeDiffClose" },
    callback = refresh,
  })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "WinResized", "TabEnter" }, {
    group = group,
    callback = function(ev)
      if ev.event == "TabEnter" or in_diff_tab() then
        refresh()
      end
    end,
  })

  -- Single click opens, like VS Code (Enter and double-click still work)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "codediff-explorer", "codediff-history" },
    callback = function(ev)
      vim.wo.relativenumber = false
      vim.keymap.set("n", "<LeftRelease>", function()
        vim.api.nvim_feedkeys(vim.keycode("<CR>"), "m", false)
      end, { buffer = ev.buf, desc = "Open (single click)" })
    end,
  })
end

return M
