---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then return formatter end
  end
  return select(1, ...)
end

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
          javascript = { "dprint", "prettierd", stop_after_first = true },
          typescript = { "dprint", "prettierd", stop_after_first = true },
          javascriptreact = { "dprint", "prettierd", stop_after_first = true },
          -- typescriptreact = { "dprint", "prettierd", stop_after_first = true },
          typescriptreact = function(bufnr) return { first(bufnr, "dprint", "prettierd"), "eslint_d" } end,
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
          nix = { "nixfmt" },
        },
        formatters = {
          taplo = {
            args = {
              "format",
              "--option",
              "column_width=200",
              "--option",
              "inline_table_expand=false",
              "-",
            },
          },
        },
      })
    end,
  },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = {}, -- don't load until called by lua
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
        max_join_length = 200,
      })
    end,
  },
}

return M
