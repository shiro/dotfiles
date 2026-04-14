local M = {}

-- Global state for the color inspector
local state = {
  enabled = false,
  winid = nil,
  bufnr = nil,
  autocmd_id = nil,
}

-- Get all highlight groups at cursor position
local function get_highlights()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-based
  local buf = vim.api.nvim_get_current_buf()

  local highlights = {}
  local seen = {} -- Track duplicates

  -- Get treesitter highlights
  if vim.treesitter.get_captures_at_pos then
    local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
    for _, capture in ipairs(captures) do
      local name = "@" .. capture.capture .. "." .. (capture.lang or "unknown")
      local attrs = vim.api.nvim_get_hl(0, { name = name })
      local target = attrs.link or ("@" .. capture.capture)

      if not seen[name] then
        seen[name] = true
        table.insert(highlights, {
          name = name,
          target = target,
        })
      end
    end
  end

  -- Get extmark highlights (LSP semantic tokens, etc.)
  for _, ns_id in pairs(vim.api.nvim_get_namespaces()) do
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns_id, { row, 0 }, { row, -1 }, {
      details = true,
      overlap = true,
    })

    for _, extmark in ipairs(extmarks) do
      local start_col = extmark[3]
      local details = extmark[4] or {}
      local end_col = details.end_col or start_col

      if col >= start_col and col <= end_col and details.hl_group then
        -- Filter out unwanted highlights
        if details.hl_group ~= "IlluminatedWordRead" and not seen[details.hl_group] then
          seen[details.hl_group] = true
          local attrs = vim.api.nvim_get_hl(0, { name = details.hl_group })
          local target = attrs.link or details.hl_group

          table.insert(highlights, {
            name = details.hl_group,
            target = target,
          })
        end
      end
    end
  end

  return highlights
end

-- Format highlight info for display
local function format_highlights(highlights)
  if #highlights == 0 then
    return { "No highlight groups found" }
  end

  local lines = {}
  for _, hl in ipairs(highlights) do
    local line
    if hl.name == hl.target then
      line = hl.name
    else
      line = hl.name .. " links to " .. hl.target
    end
    table.insert(lines, {
      text = line,
      hl_group = hl.target,
      links_pos = hl.name ~= hl.target and (string.len(hl.name) + 1) or nil,
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
  if col + width > screen_width then
    col = cursor_screen_col - width - 1
  end
  if row + height > screen_height then
    row = cursor_screen_row - height - 1
  end

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

-- Update or create the popup window
local function update_popup()
  if not state.enabled then
    return
  end

  local highlights = get_highlights()
  local content = format_highlights(highlights)

  -- Close existing popup
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  end

  -- Create buffer if needed
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[state.bufnr].bufhidden = "wipe"
  end

  -- Set buffer content
  local lines = {}
  for _, item in ipairs(content) do
    table.insert(lines, type(item) == "string" and item or item.text)
  end
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)

  -- Apply highlighting
  for i, item in ipairs(content) do
    if type(item) ~= "string" and item.hl_group then
      local line_idx = i - 1

      if item.links_pos then
        -- Highlight the first part (highlight group name)
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, 0, item.links_pos)

        -- Highlight " links to " in gray
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, "Comment", line_idx, item.links_pos, item.links_pos + 10)

        -- Highlight the target highlight group
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, item.links_pos + 10, -1)
      else
        -- Highlight the entire line
        pcall(vim.api.nvim_buf_add_highlight, state.bufnr, -1, item.hl_group, line_idx, 0, -1)
      end
    end
  end

  -- Create popup window
  local config = get_popup_config(content)
  state.winid = vim.api.nvim_open_win(state.bufnr, false, config)

  -- Set window options
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

-- Enable the color inspector
local function enable()
  state.enabled = true

  -- Set up autocmd to update popup on cursor movement
  state.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      vim.schedule(update_popup)
    end,
  })

  -- Initial popup creation
  update_popup()
end

-- Disable the color inspector
local function disable()
  state.enabled = false
  cleanup()
end

-- Main toggle function
function M.toggle()
  if state.enabled then
    disable()
  else
    enable()
  end
end

-- Function to check if inspector is enabled
function M.is_enabled()
  return state.enabled
end

return M
