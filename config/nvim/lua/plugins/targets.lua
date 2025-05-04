local M = {
  -- additional motion targets
  { "https://github.com/wellle/targets.vim" },
  -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function() require("nvim-surround").setup({}) end,
  },
}
return M
