local M = {
  -- better quickfix window {{{
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function() require("bqf").setup({ preview = { winblend = 0 } }) end,
  },
}

-- persist the quickfix list per launch directory
local qf_dir = vim.fn.stdpath("state") .. "/quickfix"
local function qf_file() return qf_dir .. "/" .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 32) .. ".json" end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = "default",
  callback = function()
    local list = vim.fn.getqflist({ items = 1, title = 1 })
    local items = {}
    for _, e in ipairs(list.items) do
      local name = e.bufnr > 0 and vim.api.nvim_buf_get_name(e.bufnr) or ""
      if e.valid == 1 and name ~= "" then
        table.insert(items, { filename = name, lnum = e.lnum, col = e.col, text = e.text, type = e.type })
      end
    end
    vim.fn.mkdir(qf_dir, "p")
    if #items == 0 then
      vim.fn.delete(qf_file())
      return
    end
    vim.fn.writefile({ vim.json.encode({ title = list.title, items = items }) }, qf_file())
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = "default",
  nested = true,
  callback = function()
    if #vim.fn.getqflist() > 0 or vim.fn.filereadable(qf_file()) == 0 then return end
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(qf_file()), "\n"))
    if ok and type(data) == "table" and data.items then
      vim.fn.setqflist({}, " ", { title = data.title or "", items = data.items })
    end
  end,
})

-- quickfix
vim.api.nvim_create_autocmd("FileType", {
  group = "default",
  pattern = "qf",
  callback = function()
    -- remove quickfix entries in the line range [first, last]
    local function remove_entries(first, last)
      if first > last then first, last = last, first end
      local entries = vim.fn.getqflist()
      if entries == nil or #entries == 0 then return end
      last = math.min(last, #entries)
      for i = last, first, -1 do
        table.remove(entries, i)
      end
      vim.fn.setqflist(entries, "r")
      -- reopen quickfix window to refresh the list
      vim.cmd("copen")
      local new_idx = math.max(math.min(first, #entries), 1)
      local winid = vim.fn.win_getid()
      if winid == nil then return end
      vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
    end

    vim.keymap.set("n", "dd", function()
      local cur = vim.fn.line(".")
      remove_entries(cur, cur)
    end, { silent = true, noremap = true, buffer = 0 })
    vim.keymap.set("x", "d", function()
      local first, last = vim.fn.line("v"), vim.fn.line(".")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      remove_entries(first, last)
    end, { silent = true, noremap = true, buffer = 0 })
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { silent = true, noremap = true, buffer = 0 })
  end,
})

return M
