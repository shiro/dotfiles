local M = {
  { "rust-lang/rust.vim", ft = "rust" },
  { "arzg/vim-rust-syntax-ext", ft = "rust" },
  {
    "saecki/crates.nvim",
    ft = "toml",
    tag = "stable",
    config = function() require("crates").setup() end,
  },
}
return M
