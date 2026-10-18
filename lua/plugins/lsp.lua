-- Language servers (IntelliSense), installed automatically by Mason.
-- :Mason shows what's installed; :checkhealth vim.lsp shows what's attached.
local servers = {
  "vtsls", -- TypeScript / JavaScript (the same engine VS Code uses)
  "eslint",
  "tailwindcss",
  "html",
  "cssls",
  "jsonls",
  "yamlls",
  "gopls",
  "basedpyright", -- Python types
  "ruff", -- Python lint + format
  "lua_ls",
}

-- Command-line tools used for formatting (see format.lua)
local tools = { "prettier", "stylua", "goimports" }

return {
  -- Lua completions for editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  -- package.json, tsconfig.json, GitHub Actions... schemas for completion and validation
  { "b0o/SchemaStore.nvim", lazy = true },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = { ui = { border = "rounded" } },
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
        float = { border = "rounded", source = "if_many" },
      })

      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.config("vtsls", {
        settings = {
          vtsls = { autoUseWorkspaceTsdk = true },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
          },
          javascript = { updateImportsOnFileMove = { enabled = "always" } },
        },
      })
      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() },
        },
      })
      vim.lsp.config("basedpyright", {
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { completion = { callSnippet = "Replace" } } },
      })

      -- Installs any missing servers and enables all of them. stylua is only a
      -- formatter here (conform runs it), so don't also start it as a server.
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = { exclude = { "stylua" } },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_keys", { clear = true }),
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          local function definitions()
            Snacks.picker.lsp_definitions()
          end
          local function references()
            Snacks.picker.lsp_references()
          end
          local function organize_imports()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} }, apply = true })
          end

          -- VS Code keys
          map("n", "<F12>", definitions, "Go to definition (F12)")
          map("n", "<S-F12>", references, "Find references (Shift+F12)")
          map("n", "<F24>", references, "Find references (Shift+F12)") -- how Ghostty reports Shift+F12
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol (F2)")
          map({ "n", "x" }, "<D-.>", vim.lsp.buf.code_action, "Quick fix (Cmd+.)")

          -- Vim-style keys (K = hover docs is built in)
          map("n", "gd", definitions, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Go to type definition")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action / quick fix")
          map("n", "<leader>co", organize_imports, "Organize imports")
          map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP status")
        end,
      })
    end,
  },

  -- Completion popup. Tab or Enter accepts, Ctrl+Space opens it, Ctrl+E closes it.
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "accept", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
