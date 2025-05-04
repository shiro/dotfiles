local M = {
  -- pretty folds {{{
  {
    "bbjornstad/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup({
        fill_char = " ",
        sections = {
          left = { "content" },
          right = {
            " ",
            "number_of_folded_lines",
            function(config) return config.fill_char:rep(3) end,
          },
        },
        process_comment_signs = false,
      })
    end,
  },
}
return M
