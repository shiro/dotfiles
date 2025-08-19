local M = {
  -- additional motion targets
  { "https://github.com/wellle/targets.vim" },
  -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function() require("nvim-surround").setup({}) end,
  },
  -- enables repeating other supported plugins with the . command
  -- "tpope/vim-repeat",
}

-- change outer function
vim.keymap.set({ "n" }, "caf", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "va(obs", "m", true)
end)

-- change innre function
vim.keymap.set({ "n" }, "cif", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "ci(", "m", true)
end)

-- delete inner function
vim.keymap.set({ "n" }, "dif", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "ds(db", "m", true)
end)

-- delete outer function
vim.keymap.set({ "n" }, "daf", function()
  local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys("/(" .. cr .. esc .. "da(db", "m", true)
end)

return M
