return {
  -- Auto-close brackets and quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Multiple cursors. Cmd+D belongs to Ghostty, so Ctrl+N adds the next match.
  -- Esc clears the cursors.
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      local map = vim.keymap.set

      map({ "n", "x" }, "<C-n>", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor at next match (like Cmd+D)" })
      map({ "n", "x" }, "<leader>mn", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor at next match" })
      map({ "n", "x" }, "<leader>ms", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip this match" })
      map({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Cursor on every match (like Cmd+Shift+L)" })
      map({ "n", "x" }, "<leader>mj", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor below" })
      map({ "n", "x" }, "<leader>mk", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor above" })
      map("n", "<M-LeftMouse>", mc.handleMouse, { desc = "Add cursor at click (Option+Click)" })
      map("n", "<M-LeftDrag>", mc.handleMouseDrag)
      map("n", "<M-LeftRelease>", mc.handleMouseRelease)

      -- Keys that only exist while there are multiple cursors
      mc.addKeymapLayer(function(layer)
        layer({ "n", "x" }, "<left>", mc.prevCursor)
        layer({ "n", "x" }, "<right>", mc.nextCursor)
        layer({ "n", "x" }, "<leader>mx", mc.deleteCursor)
        layer("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },

  -- Sessions per folder: reopen the files you had open (start screen: s)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore session for this folder",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't save this session",
      },
    },
  },
}
