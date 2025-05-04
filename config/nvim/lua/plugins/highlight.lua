local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "typescript",
          "tsx",
          "javascript",
          "css",
          "scss",
          "styled",
          "rust",
          "json",
          "lua",
          "sql",
          "go",
        },
        auto_install = true,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
        context_commentstring = { enable = true },
      })
      -- vim.o.foldmethod = "expr"
      -- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },
  -- highlight symbol under cursor {{{
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        providers = {
          "lsp",
          "treesitter",
        },
        delay = 200,
      })
    end,
  },
}

return M
