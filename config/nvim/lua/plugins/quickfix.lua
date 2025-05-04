local M = {
  -- better quickfix window {{{
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function() require("bqf").setup({ preview = { winblend = 0 } }) end,
  },
}

-- quickfix
vim.api.nvim_create_autocmd("FileType", {
  group = "default",
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "dd", function()
      local curqfidx = vim.fn.line(".")
      local entries = vim.fn.getqflist()
      if entries == nil then return end
      if #entries == 0 then return end
      -- remove the item from the quickfix list
      table.remove(entries, curqfidx)
      vim.fn.setqflist(entries, "r")
      -- reopen quickfix window to refresh the list
      vim.cmd("copen")
      local new_idx = curqfidx < #entries and curqfidx or math.max(curqfidx - 1, 1)
      local winid = vim.fn.win_getid()
      if winid == nil then return end
      vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
    end, { silent = true, noremap = true, buffer = 0 })
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { silent = true, noremap = true, buffer = 0 })
  end,
})

return M
