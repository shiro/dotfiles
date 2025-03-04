---@diagnostic disable: missing-parameter, empty-block

local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local get_cursor_pos = function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- cursor_pos[1] = cursor_pos[1] - 1
  return cursor_pos
end

local function get_node_at_cursor()
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  vim.treesitter.get_parser(0):parse({ r - 1, c, r - 1, c })
  return vim.treesitter.get_node({ ignore_injections = false })
end

-- returns -1 (less than) | 0 (equal) | 1 (more than)
local pos_cmp = function(pos1, pos2)
  if pos1[1] == pos2[1] and pos1[2] == pos2[2] then
    return 0
  elseif (pos1[1] < pos2[1]) or ((pos1[1] == pos2[1]) and (pos1[2] < pos2[2])) then
    return -1
  else
    return 1
  end
end

local get_node_before_cursor = function()
  local node = get_node_at_cursor()
  if node == nil then return nil end
  local cursor_pos = get_cursor_pos()

  local done = false
  while not done do
    done = true
    local n = node
    local child_count = node:child_count()

    local i = 1
    while i <= child_count do
      local child = node:child(i - 1)

      local end_x, end_y = child:end_()
      if pos_cmp({ end_x, end_y }, cursor_pos) < 0 then
        n = child
        done = false
      end

      i = i + 1
    end
    node = n
  end

  return node
end

local get_node_after_cursor = function()
  local node = get_node_at_cursor()
  if node == nil then return nil end
  local cursor_pos = get_cursor_pos()
  cursor_pos[1] = cursor_pos[1] - 1

  if pos_cmp({ node:start() }, cursor_pos) == 0 then return node end

  local done = false
  while not done do
    done = true
    local n = node
    local i = node:child_count()
    while i > 0 do
      local child = node:child(i - 1)

      local end_x, end_y = child:start()
      if pos_cmp({ end_x, end_y }, cursor_pos) > 0 then
        n = child
        done = false
      end

      i = i - 1
    end
    node = n
  end

  return node
end

-- get the row,col position before the input position
local function get_prev_pos(pos)
  if pos[1] ~= 0 then return { pos[1], pos[2] - 1 } end
  if pos[1] ~= 0 then
    local prev_line = vim.api.nvim_buf_get_lines(0, pos[1], pos[2] + 1, true)[1]
    return { pos[1] - 1, string.len(prev_line) }
  end
  return { 0, 0 }
end

function M.update_selection(buf, node, selection_mode)
  selection_mode = selection_mode or "charwise"
  local start_row, start_col, end_row, end_col = ts_utils.get_vim_range({ vim.treesitter.get_node_range(node) }, buf)

  vim.fn.setpos(".", { buf, start_row, start_col, 0 })

  local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
  local mode_string = vim.api.nvim_replace_termcodes(v_table[selection_mode] or selection_mode, true, true, true)
  vim.cmd("normal! " .. mode_string)
  vim.fn.setpos(".", { buf, end_row, end_col, 0 })
end

M.select = function() --{{{
  local node = get_master_node()
  local bufnr = vim.api.nvim_get_current_buf()

  M.update_selection(bufnr, node)
end --}}}

M.move = function(mode, up)
  local node = get_master_node(true)
  local bufnr = vim.api.nvim_get_current_buf()

  local target
  if up == true then
    target = node:prev_named_sibling()
  else
    target = node:next_named_sibling()
  end

  if target == nil then return end

  while target:type() == "comment" do
    if up == true then
      target = target:prev_named_sibling()
    else
      target = target:next_named_sibling()
    end
  end

  if target ~= nil then
    ts_utils.swap_nodes(node, target, bufnr, true)

    if mode == "v" then
      target = get_node_at_cursor()
      M.update_selection(bufnr, target)
      M.update_selection(bufnr, target)
    end
  end
end

M.opts = {
  disable_no_instance_found_report = false,
  highlight_group = "STS_highlight",
}

-- Possible keymaps for jumping
M.opts.left_hand_side = "fdsawervcxqtzb"
M.opts.left_hand_side = vim.split(M.opts.left_hand_side, "")
M.opts.right_hand_side = "jkl;oiu.,mpy/n"
M.opts.right_hand_side = vim.split(M.opts.right_hand_side, "") --}}}

-- Methods to return {{{
M.filtered_jump = go_to_next_instance
M.targeted_jump = print_types --}}}

local nodes_start_at_same_pos = function(node1, node2)
  if node1 == nil or node2 == nil then return false end
  local x1, y1 = node1:start()
  local x2, y2 = node2:start()
  return x1 == x2 and y1 == y2
end

local get_mode = function() return vim.api.nvim_get_mode().mode end

local get_closest_supported_parent_node = function()
  --
end

M.select_current_node = function()
  -- local language_tree = vim.treesitter.get_parser(0)
  -- language_tree:for_each_tree(function(st, lt)
  --   local root = st:root()
  --   local matches = {}
  --   for _, match in ts_query:iter_matches(root, 0, root:start(), root:end_(), { all = true }) do
  --     local n = match[1][1]
  --     table.insert(matches, match[1][1])
  --     if pos_cmp({ n:start() }, cursor_pos) >= 0 then
  --       break
  --     end
  --   end
  -- end)

  -- M.go("parent")
  -- local node = get_node_at_cursor()
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- if node ~= nil then
  --   M.update_selection(bufnr, node, "v")
  -- end
end

local supported_nodes = {
  tsx = {
    "if_statement",
    "for_statement",
    "for_in_statement",
    "lexical_declaration",
    "type_alias_declaration",
    "call_expression",
    "return_statement",
    "continue_statement",
    "break_statement",
    "import_statement",
    "assignment_expression",
    "new_expression",
    -- "call_expression (member_expression ((property_identifier) @target))",
    "export_statement",
    "jsx_element",
  },
  styled = {
    "property_name",
    "js_expression",
  },
  lua = {
    "for_statement",
    "while_statement",
    "break_statement",
    "return_statement",
    "if_statement",
    "else_statement",
    "elseif_statement",
    "variable_declaration",
    "function_declaration",
    "block ((assignment_statement) @target)",
    "chunk ((assignment_statement) @target)",
    "function_call",
  },
  go = {
    "package_clause",
    "import_declaration",
    "type_declaration",
    "for_statement",
    "if_statement",
    "call_expression",
    "defer_statement",
    "function_declaration",
    "block ((short_var_declaration) @target)",
  },
}

local supported_queries = {}
for ft, node_types in pairs(supported_nodes) do
  query = "([\n"
  for _, node_type in pairs(node_types) do
    if string.find(node_type, "@target") then
      query = query .. "(" .. node_type .. ")\n"
    else
      query = query .. "((" .. node_type .. ") @target)\n"
    end
  end
  query = query .. "])"
  supported_queries[ft] = query
end

M.go = function(direction)
  local move = false
  local mode = get_mode()
  local target = nil
  local target_pos = nil

  local language_tree = vim.treesitter.get_parser(0)
  language_tree:for_each_tree(function(st, lt)
    local root = st:root()
    local ft = lt:lang()

    local cursor_pos = get_cursor_pos()
    cursor_pos[1] = cursor_pos[1] - 1

    local query = supported_queries[ft]
    if query == nil then return end
    local ts_query = vim.treesitter.query.parse(ft, query)

    if direction == "parent" then
      local matches = {}
      for _, match in ts_query:iter_matches(root, 0, root:start(), root:end_(), { all = true }) do
        local n = match[1][1]
        table.insert(matches, match[1][1])
        if pos_cmp({ n:start() }, cursor_pos) >= 0 then break end
      end
      local matches_len = #matches
      for k, _ in ipairs(matches) do
        local n = matches[matches_len + 1 - k]
        local n_pos = { n:start() }
        if pos_cmp(cursor_pos, n_pos) > 0 and pos_cmp(cursor_pos, { n:end_() }) <= 0 then
          if target_pos == nil or pos_cmp(n_pos, target_pos) > 0 then
            target = n
            target_pos = n_pos
            break
          end
        end
      end
    elseif direction == "next" then
      local matches = {}
      for _, match in ts_query:iter_matches(root, 0, root:start(), root:end_(), { all = true }) do
        table.insert(matches, match[1][1])
      end
      local matches_len = #matches
      for k, _ in ipairs(matches) do
        local n = matches[matches_len + 1 - k]
        local n_pos = { n:start() }
        if pos_cmp(n_pos, cursor_pos) <= 0 then break end
        if target_pos == nil or pos_cmp(n_pos, target_pos) < 0 then
          target = n
          target_pos = n_pos
        end
      end
    elseif direction == "prev" then
      for _, match in ts_query:iter_matches(root, 0, root:start(), root:end_(), { all = true }) do
        local n = match[1][1]
        local n_pos = { n:start() }
        if pos_cmp(n_pos, cursor_pos) >= 0 then break end
        if target_pos == nil or pos_cmp(n_pos, target_pos) > 0 then
          target = n
          target_pos = n_pos
        end
      end
    end
  end)

  if target ~= nil then
    if move == true then
      -- local bufnr = vim.api.nvim_get_current_buf()
      -- ts_utils.swap_nodes(node, target, bufnr, true)
      --
      -- if mode == "visual" then
      --   target = get_node_at_cursor()
      --   M.update_selection(bufnr, target)
      --   M.update_selection(bufnr, target)
      -- end
    else
      -- M.update_selection(bufnr, target)
      ts_utils.goto_node(target)
      -- if mode == "v" or mode == "V" then
      --   M.select_current_node()
      -- end
    end
  end
end

M.setup = function(opts)
  if opts then
    for key, value in pairs(opts) do
      if key == "default_desired_types" then
        -- current_desired_types = value
      else
        M.opts[key] = value

        if key == "left_hand_side" then
          M.opts.left_hand_side = vim.split(value, "")
        elseif key == "right_hand_side" then
          M.opts.right_hand_side = vim.split(value, "")
        end
      end
    end
  end
end

return M
