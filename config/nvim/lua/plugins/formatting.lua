local M = {
  {
    "stevearc/conform.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    event = "VeryLazy",
    cmd = { "ConformInfo" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          svelte = { "prettierd" },
          javascript = { "prettierd", "dprint" },
          typescript = { "prettierd", "dprint" },
          javascriptreact = { "prettierd", "dprint" },
          typescriptreact = { "prettierd", "dprint" },
          json = { "prettierd" },
          graphql = { "prettierd" },
          java = { "google-java-format" },
          kotlin = { "ktlint" },
          ruby = { "standardrb" },
          markdown = { "prettierd" },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          proto = { "buf" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          css = { "prettierd" },
          scss = { "prettierd" },
        },
      })
    end,
  },
}

return M
