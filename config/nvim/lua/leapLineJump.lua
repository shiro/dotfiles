vim.keymap.set("n", "U", function()
  require("leap").leap({ target_windows = { vim.fn.win_getid() } })
  vim.fn.feedkeys("^")
end)
