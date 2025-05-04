local M = {
  -- better quickfix window {{{
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function() require("bqf").setup({ preview = { winblend = 0 } }) end,
  },
  -- }}}
}
return M
