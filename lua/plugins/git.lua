-- Git changes in the gutter, hunk actions and inline blame (GitLens-style).
-- Full git UI: <leader>gg opens lazygit.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame_opts = { delay = 300 },
    on_attach = function(buf)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
      end
      map("n", "]h", function() gs.nav_hunk("next") end, "Next change")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Previous change")
      map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage change")
      map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Discard change")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview change")
      map("n", "<leader>ghd", gs.diffthis, "Diff file against index")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
    end,
  },
}
