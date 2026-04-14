local M = {}

local state = {
  enabled = false,
  winid = nil,
  bufnr = nil,
  autocmd_id = nil,
}

-- Get highlight groups at cursor position
local function get_highlights()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local buf = vim.api.nvim_get_current_buf()

  local highlights = {}
  local seen = {}

  if vim.inspect_pos then
    local inspect_data = vim.inspect_pos(buf, row, col)

    -- Process extmarks
    if inspect_data.extmarks then
      for _, extmark in ipairs(inspect_data.extmarks) do
        local hl_group = extmark.opts and extmark.opts.hl_group
        if hl_group and not seen[hl_group] and hl_group ~= "IlluminatedWordRead" then
          seen[hl_group] = true
          local target = extmark.opts.hl_group_link or hl_group

          print(vim.inspect(extmark.opts))

          table.insert(highlights, {
            name = hl_group,
            target = target,
            priority = extmark.opts.priority,
          })
        end
      end
    end

    -- Process treesitter
    if inspect_data.treesitter then
      for _, ts in ipairs(inspect_data.treesitter) do
        local hl_group = ts.hl_group
        if hl_group and not seen[hl_group] then
          seen[hl_group] = true
          local target = ts.hl_group_link or hl_group

          table.insert(highlights, {
            name = hl_group,
            target = target,
            priority = 100,
          })
        end
      end
    end
  end

  table.sort(highlights, function(a, b)
    local a_priority = a.priority or 0
    local b_priority = b.priority or 0
    if a_priority ~= b_priority then return a_priority > b_priority end
    return a.name < b.name
  end)

  return highlights
end

-- Format highlight info for display
local function format_highlights(highlights)
  if #highlights == 0 then return { "No highlight groups found" } end

  local lines = {}
  for _, hl in ipairs(highlights) do
    local line = hl.name == hl.target and hl.name or hl.name .. " links to " .. hl.target
    if hl.priority then line = line .. " (priority: " .. hl.priority .. ")" end

    table.insert(lines, {
      text = line,
      hl_group = hl.target,
      links_pos = hl.name ~= hl.target and string.len(hl.name) or nil,
    })
  end
  return lines
end

-- Calculate popup dimensions and position
local function get_popup_config(content)
  local cursor_screen_row = vim.fn.winline()
  local cursor_screen_col = vim.fn.wincol()
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines - vim.o.cmdheight - 1

  -- Calculate required width
  local max_width = 0
  for _, item in ipairs(content) do
    local text = type(item) == "string" and item or item.text
    max_width = math.max(max_width, vim.fn.strdisplaywidth(text))
  end

  local title_width = vim.fn.strdisplaywidth(" Color Inspector ")
  local width = math.max(max_width + 2, title_width + 2, 20)
  width = math.min(width, screen_width - 4)

  local height = math.min(#content, screen_height - 4)

  -- Position popup near cursor
  local row = cursor_screen_row + 1
  local col = cursor_screen_col + 2

  -- Adjust if popup would go off screen
  if col + width > screen_width then col = cursor_screen_col - width - 1 end
  if row + height > screen_height then row = cursor_screen_row - height - 1 end

  -- Ensure popup stays on screen
  row = math.max(0, math.min(row, screen_height - height))
  col = math.max(0, math.min(col, screen_width - width))

  return {
    relative = "editor",
    row = row - 1,
    col = col - 1,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Color Inspector ",
    title_pos = "center",
  }
end

local function update_popup()
  if not state.enabled then return end

  local highlights = get_highlights()
  local content = format_highlights(highlights)

  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  end

  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[state.bufnr].bufhidden = "wipe"
  end

  local lines = {}
  for _, item in ipairs(content) do
    table.insert(lines, type(item) == "string" and item or item.text)
  end
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)

  for i, item in ipairs(content) do
    if type(item) ~= "string" and item.hl_group then
      local line_idx = i - 1

      if item.links_pos then
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, 0, item.links_pos)
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, "Comment", line_idx, item.links_pos, item.links_pos + 10)
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, item.links_pos + 10, -1)
      else
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, 0, -1)
      end
    end
  end

  local config = get_popup_config(content)
  state.winid = vim.api.nvim_open_win(state.bufnr, false, config)
  vim.wo[state.winid].winhl = "Normal:NormalFloat,Border:FloatBorder"
  vim.wo[state.winid].wrap = false
end

-- Clean up popup and autocmds
local function cleanup()
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
    state.winid = nil
  end

  if state.autocmd_id then
    vim.api.nvim_del_autocmd(state.autocmd_id)
    state.autocmd_id = nil
  end
end

local function enable()
  state.enabled = true

  state.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function() vim.schedule(update_popup) end,
  })

  update_popup()
end

local function disable()
  state.enabled = false
  cleanup()
end

function M.toggle()
  if state.enabled then
    disable()
  else
    enable()
  end
end

function M.is_enabled() return state.enabled end

return M
