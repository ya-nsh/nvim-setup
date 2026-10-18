-- Everything this setup installs: language servers and formatters (via Mason)
-- and syntax parsers (via treesitter). lsp.lua, treesitter.lua and the
-- installer (scripts/bootstrap.lua) all read this list.
return {
  -- Language servers, by their nvim-lspconfig names
  servers = {
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
  },

  -- Command-line formatters, by their Mason package names (see format.lua)
  formatters = { "prettier", "stylua", "goimports" },

  -- stylua: ignore
  parsers = {
    "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "git_rebase", "gitignore",
    "go", "gomod", "gosum", "graphql", "html", "javascript", "jsdoc", "json",
    "lua", "luadoc", "markdown", "markdown_inline", "prisma", "python", "query",
    "regex", "scss", "sql", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
  },
}
