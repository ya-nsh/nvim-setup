-- Git, like VS Code / Cursor's Source Control panel plus GitLens:
--   Ctrl+Shift+G or <leader>gs   Source Control: "Staged Changes" and "Changes".
--                                Click a file to see its diff, VS Code style (old left,
--                                new right, changed words highlighted).
--                                In the panel: - stage/unstage, S stage all, U unstage all,
--                                X discard, c commit, P push, ? all keys.
--   <leader>gc                   Commit history: click a commit to see its files, click a
--                                file to see what that commit changed
--   <leader>gf                   History of this file (select lines first: history of those lines)
--   <leader>gd                   Diff this file against the last commit
--   <leader>go                   Open the commit that last changed this line
--   Inline blame                 who last changed the current line, when, and why (end of line)
--   <leader>gb / <leader>gB      blame popup for this line / blame the whole file
-- Full git UI: <leader>gg opens lazygit. In any diff or history view, q closes it.

--- Root of the git repo for the current directory, or nil
local function repo_root()
  local out = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  return out.code == 0 and vim.trim(out.stdout) or nil
end

--- Run git asynchronously and report the outcome
local function git(args, root, ok_msg)
  vim.system(vim.list_extend({ "git" }, args), { cwd = root, text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify(ok_msg, vim.log.levels.INFO, { title = "Git" })
      else
        local err = vim.trim((out.stderr ~= "" and out.stderr) or out.stdout)
        vim.notify(err, vim.log.levels.ERROR, { title = "git " .. args[1] .. " failed" })
      end
    end)
  end)
end

--- Commit, like the message box at the top of VS Code's Source Control panel.
--- Commits what's staged; with nothing staged, offers to stage everything first.
local function commit()
  local root = repo_root()
  if not root then
    return vim.notify("Not inside a git repository", vim.log.levels.WARN)
  end
  local has_staged = vim.system({ "git", "diff", "--cached", "--quiet" }, { cwd = root }):wait().code == 1
  local function ask(stage_all)
    Snacks.input({
      prompt = stage_all and "Commit message (stages all changes)" or "Commit message",
      icon = " ",
    }, function(message)
      if not message or vim.trim(message) == "" then
        return
      end
      if stage_all then
        local add = vim.system({ "git", "add", "-A" }, { cwd = root, text = true }):wait()
        if add.code ~= 0 then
          return vim.notify(add.stderr, vim.log.levels.ERROR, { title = "git add failed" })
        end
      end
      git({ "commit", "-m", message }, root, "Committed: " .. message)
    end)
  end
  if has_staged then
    ask(false)
  else
    vim.ui.select({ "Stage all changes and commit", "Cancel" }, {
      prompt = "Nothing is staged",
    }, function(choice)
      if choice == "Stage all changes and commit" then
        ask(true)
      end
    end)
  end
end

local function push()
  local root = repo_root()
  if root then
    vim.notify("Pushing...", vim.log.levels.INFO, { title = "Git" })
    git({ "push" }, root, "Pushed")
  end
end

-- Open the commit that last changed the current line
local function open_line_commit()
  local blame = vim.b.gitsigns_blame_line_dict
  local sha = blame and blame.sha
  if not sha then
    vim.notify("No blame for this line yet (is the file in git?)", vim.log.levels.WARN)
  elseif sha:match("^0+$") then
    vim.notify("This line isn't committed yet", vim.log.levels.INFO)
  else
    local has_parent = vim.system({ "git", "rev-parse", "--verify", "--quiet", sha .. "^" }):wait().code == 0
    -- The first commit has no parent: compare it with the empty tree instead
    local base = has_parent and sha .. "^" or "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
    require("config.git_ui").open(base .. " " .. sha)()
  end
end

--- Deferred call into config.git_ui (it requires codediff, which loads on first use)
local function ui(fn)
  return function(...)
    local args = { ... }
    return function()
      require("config.git_ui")[fn](unpack(args))()
    end
  end
end

local function file_history(range)
  return function()
    if range then
      vim.cmd("normal! \27") -- leave visual mode so '< and '> are set
      require("config.git_ui").pick_layout()
      vim.cmd("'<,'>CodeDiff history")
    else
      require("config.git_ui").open("history %")()
    end
  end
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 200, virt_text_pos = "eol" },
      current_line_blame_formatter = "   <author>, <author_time:%R> • <summary>",
      preview_config = { border = "rounded" },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next change")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous change")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage change")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Discard change")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview change")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame line (full commit)")
        map("n", "<leader>gB", gs.blame, "Blame whole file")
        map("n", "<leader>go", open_line_commit, "Open commit of this line")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },

  -- Source Control panel, VS Code-style diffs and commit history
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    build = function()
      require("codediff.core.installer.libvscode_diff").install({ silent = true })
    end,
    keys = {
      { "<C-S-g>", ui("open")(), desc = "Source Control (Ctrl+Shift+G)" },
      { "<leader>gs", ui("open")(), desc = "Source Control (changed files)" },
      { "<leader>gc", ui("open")("history"), desc = "Commit history" },
      { "<leader>gf", file_history(false), desc = "File history" },
      { "<leader>gf", file_history(true), mode = "x", desc = "History of selected lines" },
      { "<leader>gd", ui("open")("file HEAD"), desc = "Diff file against last commit" },
    },
    opts = {
      -- VS Code's dark diff colours: green = added, red = removed, brighter = the exact words
      highlights = {
        line_insert = "#2c3a22",
        char_insert = "#4a6330",
        line_delete = "#432424",
        char_delete = "#713030",
      },
      diff = {
        layout = "side-by-side",
        jump_to_first_change = true,
        highlight_added_deleted_files = true, -- new and deleted files show fully green / red
        gutter_signs = true, -- + / - beside changed lines, like VS Code
      },
      explorer = {
        position = "left",
        width = 42,
        view_mode = "tree", -- folders, like VS Code's tree view (i switches to a flat list)
        line_stats = { enabled = true }, -- +12 -3 beside each file
      },
      history = {
        position = "left",
        width = 50,
        view_mode = "tree",
      },
      keymaps = {
        -- Cmd+B shows / hides the panel, like VS Code's sidebar (frees <leader>b for tabs)
        view = { toggle_explorer = "<D-b>" },
      },
    },
    config = function(_, opts)
      require("codediff").setup(opts)
      require("config.git_ui").setup() -- titles, GitLens-style rows, single click, layout
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_codediff", { clear = true }),
        pattern = { "codediff-explorer", "codediff-history" },
        callback = function(ev)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          if vim.bo[ev.buf].filetype == "codediff-explorer" then
            map("c", commit, "Commit")
            map("P", push, "Push")
          end
          -- ? shows this panel's keys (codediff's own help)
          map("?", function()
            vim.api.nvim_feedkeys("g?", "m", false)
          end, "Keys for this panel")
        end,
      })
    end,
  },
}
