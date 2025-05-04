local M = {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("typescript-tools").setup({
        capabilities = capabilities,
        settings = {
          -- LSP snipets crash cmp, try out if it's fixed after a while
          complete_function_calls = true,
          publish_diagnostic_on = "change",
          tsserver_file_preferences = { importModuleSpecifierPreference = "non-relative" },
          tsserver_plugins = {
            "@styled/typescript-styled-plugin",
          },
        },
      })
    end,
  },
  -- autoamtically rename JSX tags {{{
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = { enable_close = false },
    ft = { "typescriptreact", "javascriptreact" },
  },
  -- }}}
  -- hide tailwind strings when not in focus
  -- {
  --   dir = "~/.dotfiles/config/nvim/lua/tw-conceal",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {},
  --   ft = { "html", "typescriptreact" },
  -- },
}

return M
