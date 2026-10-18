return {
  -- Theme: Gruvbox Material, same palette as your Ghostty colors.
  -- Transparent background so Ghostty's background and shader show through.
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Draws the tables and headings in the ? help window (only there)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "cheatsheet",
    opts = {
      file_types = { "cheatsheet" },
      render_modes = true, -- stay drawn while moving around
      anti_conceal = { enabled = false },
      completions = { blink = { enabled = false } },
      heading = { sign = false, width = "block", left_pad = 1, right_pad = 2 },
      code = { sign = false },
      pipe_table = { preset = "round" },
      latex = { enabled = false }, -- no math in the help; skips the LaTeX tools check
    },
  },

  -- Status bar at the bottom
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "gruvbox-material",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "lsp_status", "filetype" },
      },
    },
  },

  -- Editor tabs at the top
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function()
      local keys = {
        { "H", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous tab" },
        { "L", "<cmd>BufferLineCycleNext<cr>", desc = "Next tab" },
        { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin tab" },
        { "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move tab left" },
        { "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move tab right" },
        { "<leader>bc", "<cmd>BufferLinePick<cr>", desc = "Pick tab" },
      }
      for i = 1, 9 do
        keys[#keys + 1] = { "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Go to tab " .. i }
      end
      return keys
    end,
    opts = {
      options = {
        close_command = function(n)
          Snacks.bufdelete(n)
        end,
        middle_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        hover = { enabled = true, delay = 150, reveal = { "close" } },
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left", separator = true },
        },
      },
    },
  },

  -- Press <Space> and wait: a menu shows every shortcut that follows
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = function()
      local spec = {
        { "<leader>b", group = "tabs" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "change (hunk)" },
        { "<leader>m", group = "multi-cursor" },
        { "<leader>q", group = "quit / session" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "toggle" },
        { "<leader>x", group = "problems" },
        { "g", group = "go to" },
        { "gr", group = "LSP" },
        { "[", group = "previous" },
        { "]", group = "next" },
      }
      for i = 1, 9 do
        spec[#spec + 1] = { "<leader>" .. i, hidden = true }
      end
      return { preset = "helix", delay = 300, spec = spec }
    end,
  },
}
