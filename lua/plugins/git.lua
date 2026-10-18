-- Git, GitLens-style:
--   Inline blame        who last changed the current line, when, and why (end of line)
--   <leader>gc          Commit history: every commit; expand one to see its files,
--                       open a file to see exactly what changed
--   <leader>gf          History of this file (select lines first: history of those lines)
--   <leader>gd          All your uncommitted changes, side by side
--   <leader>go          Open the commit that last changed this line
--   <leader>gB          Blame the whole file
-- Full git UI: <leader>gg opens lazygit. In any history/diff view, q closes it.
local function history(range)
  return function()
    if range then
      -- Visual mode: history of the selected lines
      vim.cmd("normal! \27")
      vim.cmd("'<,'>DiffviewFileHistory")
    else
      vim.cmd("DiffviewFileHistory %")
    end
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
    vim.cmd("DiffviewOpen " .. sha .. "^!")
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
        map("n", "<leader>ghd", gs.diffthis, "Diff file against index")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame line (full commit)")
        map("n", "<leader>gB", gs.blame, "Blame whole file")
        map("n", "<leader>go", open_line_commit, "Open commit of this line")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },

  -- Side-by-side diffs and commit history (the GitLens "Commits" view)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gc", "<cmd>DiffviewFileHistory<cr>", desc = "Commit history" },
      { "<leader>gf", history(false), desc = "File history" },
      { "<leader>gf", history(true), mode = "x", desc = "History of selected lines" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff uncommitted changes" },
    },
    opts = function()
      local close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } }
      return {
        enhanced_diff_hl = true,
        file_panel = { win_config = { width = 36 } },
        file_history_panel = { win_config = { height = 14 } },
        keymaps = {
          view = { close },
          file_panel = { close },
          file_history_panel = { close },
        },
      }
    end,
  },
}
