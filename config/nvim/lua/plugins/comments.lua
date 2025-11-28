local M = {
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    -- lazy = true,
    init = function()
      -- avoid comment plugin warning
      vim.g.skip_ts_context_commentstring_module = true
    end,
    -- keys = {
    --   { "<C-_>", "", mode = "n" },
    --   { "<C-_>", "", mode = "x" },
    -- },
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
        languages = {
          styled = "/* %s */",
        },
      })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })

      vim.api.nvim_command("xmap <C-_> gc")
      vim.api.nvim_command("nmap <C-_> gccj")
    end,
  },
}

return M
