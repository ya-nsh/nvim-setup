-- File explorer sidebar. Inside it: a add, d delete, r rename, c copy, m move,
-- H show/hide hidden, / filter, ? all keys. Mouse clicks work too.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false, -- neo-tree loads itself lazily; this lets `nvim .` open it
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<D-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer (Cmd+B)" },
    { "<D-S-e>", "<cmd>Neotree reveal<cr>", desc = "Show file in explorer (Cmd+Shift+E)" },
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
  },
  opts = function()
    -- Renaming or moving a file in the explorer updates imports (via the LSP)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
    local events = require("neo-tree.events")
    return {
      close_if_last_window = true,
      popup_border_style = "rounded",
      event_handlers = {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none", -- keep <Space> as the leader key
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false, -- shown dimmed, like VS Code
          hide_by_name = { ".git" },
          never_show = { ".DS_Store" },
        },
      },
    }
  end,
}
