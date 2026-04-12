local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install({
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
          "python",
        })
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype

          if ft ~= "" and vim.treesitter.language.get_lang(ft) and not pcall(vim.treesitter.get_parser, bufnr) then
            pcall(require("nvim-treesitter").install, ft)
          end
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function() pcall(vim.treesitter.start) end,
      })
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
