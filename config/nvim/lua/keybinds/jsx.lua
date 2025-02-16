local ts_utils = require("nvim-treesitter.ts_utils")

local function get_node_at_cursor()
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  vim.treesitter.get_parser(0):parse({ r - 1, c, r - 1, c })
  return vim.treesitter.get_node({ ignore_injections = false })
end

function set_selection_to_node(buf, node, selection_mode)
  local start_row, start_col, end_row, end_col = ts_utils.get_vim_range({ vim.treesitter.get_node_range(node) }, buf)
  set_sel(buf, { start_row, start_col }, { end_row, end_col }, selection_mode)
end

function set_sel(buf, from, to, selection_mode)
  selection_mode = selection_mode or "charwise"
  vim.fn.setpos(".", { buf, from[1], from[2], 0 })

  local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
  local mode_string = vim.api.nvim_replace_termcodes(v_table[selection_mode] or selection_mode, true, true, true)
  vim.cmd("normal! " .. mode_string)
  vim.fn.setpos(".", { buf, to[1], to[2], 0 })
end

function get_jsx_node_at_cursor()
  local node = get_node_at_cursor()

  while node ~= nil do
    if node:type() == "jsx_self_closing_element" or node:type() == "jsx_element" then return node end
    if node:type() == "jsx_opening_element" or node:type() == "jsx_closing_element" then return node:parent() end
    node = node:parent()
  end

  return nil
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  pattern = { "*.tsx", "*.jsx" },
  callback = function(ev)
    local buf = ev.buf

    vim.keymap.set("n", "vit", function()
      local node = get_jsx_node_at_cursor()
      if node == nil or node:child_count() == 0 then return end

      if node:type() == "jsx_self_closing_element" then
        vim.fn.feedkeys("vat")
        return
      end

      local first_child_node = node:child(1)
      local last_child_node = node:child(node:child_count() - 2)

      local from_row, from_col, _, _ = ts_utils.get_vim_range({ vim.treesitter.get_node_range(first_child_node) }, 0)
      local _, _, to_row, to_col = ts_utils.get_vim_range({ vim.treesitter.get_node_range(last_child_node) }, 0)

      local text = vim.split(vim.treesitter.get_node_text(first_child_node, buf), "\n")
      if text[1]:len() == 0 then
        from_row = from_row + 1
        from_col = 0
      end

      local text = vim.split(vim.treesitter.get_node_text(last_child_node, buf), "\n")
      if last_child_node:type() == "jsx_text" then
        if text[#text]:match("^ *$") then
          to_row = to_row - 1
          to_col = text[#text - 1]:len()
        end
      end

      set_sel(buf, { from_row, from_col }, { to_row, to_col })
    end, {})

    vim.keymap.set("n", "vat", function()
      local node = get_node_at_cursor()
      if node == nil then return nil end

      while node ~= nil do
        if node:type() == "jsx_self_closing_element" or node:type() == "jsx_element" then
          set_selection_to_node(buf, node)
          return
        end
        if node:type() == "jsx_opening_element" or node:type() == "jsx_closing_element" then
          set_selection_to_node(buf, node:parent())
          return
        end
        node = node:parent()
      end
    end, {})
  end,
})
