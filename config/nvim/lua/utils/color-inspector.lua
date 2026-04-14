local M = {}

local LINKS_TO_LEN = 10 -- length of " links to "

local state = {
  enabled = false,
  winid = nil,
  bufnr = nil,
  autocmd_id = nil,
  ns_id = nil,
  should_show = false, -- tracks if popup should be visible
  original_bufnr = nil, -- tracks the buffer where inspector was enabled
  original_winid = nil, -- tracks the window where inspector was enabled
}

-- Process extmarks and add to highlights
local function process_extmarks(extmarks, highlights, seen)
  if not extmarks then return end

  for _, extmark in ipairs(extmarks) do
    local hl_group = extmark.opts and extmark.opts.hl_group
    if not hl_group or seen[hl_group] or hl_group:match("^Illuminate") then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = extmark.opts.hl_group_link or hl_group,
      priority = extmark.opts.priority,
      index = #highlights + 1,
    })

    ::continue::
  end
end

-- Process treesitter highlights and add to highlights
local function process_treesitter(treesitter, highlights, seen)
  if not treesitter then return end

  for _, ts in ipairs(treesitter) do
    local hl_group = ts.hl_group
    if not hl_group or seen[hl_group] then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = ts.hl_group_link or hl_group,
      priority = 100,
      index = #highlights + 1,
    })

    ::continue::
  end
end

-- Process semantic tokens and add to highlights
local function process_semantic_tokens(semantic_tokens, highlights, seen)
  if not semantic_tokens then return end

  for _, token in ipairs(semantic_tokens) do
    local hl_group = token.opts and token.opts.hl_group
    if not hl_group or seen[hl_group] then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = token.opts.hl_group_link or hl_group,
      priority = token.opts.priority or 125,
      index = #highlights + 1,
    })

    ::continue::
  end
end

-- Check if a highlight group has any colors defined
local function has_colors(hl_group)
  if not hl_group then return false end

  local hl_def = vim.api.nvim_get_hl(0, { name = hl_group })
  if not hl_def then return false end

  -- Check for any color-related properties
  return hl_def.fg ~= nil
    or hl_def.bg ~= nil
    or hl_def.sp ~= nil
    or hl_def.ctermfg ~= nil
    or hl_def.ctermbg ~= nil
    or hl_def.bold
    or hl_def.italic
    or hl_def.underline
    or hl_def.undercurl
    or hl_def.underdouble
    or hl_def.underdotted
    or hl_def.underdashed
    or hl_def.strikethrough
    or hl_def.reverse
    or hl_def.standout
end

-- Get highlight groups at cursor position
local function get_highlights()
  if not vim.inspect_pos then return {} end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  local inspect_data = vim.inspect_pos(buf, row - 1, col)

  local highlights = {}
  local seen = {}

  process_extmarks(inspect_data.extmarks, highlights, seen)
  process_treesitter(inspect_data.treesitter, highlights, seen)
  process_semantic_tokens(inspect_data.semantic_tokens, highlights, seen)

  table.sort(highlights, function(a, b)
    local a_priority = a.priority or 0
    local b_priority = b.priority or 0
    if a_priority ~= b_priority then return a_priority > b_priority end
    return a.index > b.index -- reverse order when priorities are equal
  end)

  return highlights
end

-- Format highlight info for display
local function format_highlights(highlights)
  if #highlights == 0 then return { "No highlight groups found" } end

  local lines = {}
  for _, hl in ipairs(highlights) do
    local is_linked = hl.name ~= hl.target
    local text
    local unused_pos = nil

    if is_linked then
      text = hl.name .. " links to " .. hl.target
      if not has_colors(hl.target) then
        unused_pos = string.len(text)
        text = text .. " (unused)"
      end
    else
      text = hl.name
    end

    table.insert(lines, {
      text = text,
      hl_group = hl.target,
      links_pos = is_linked and string.len(hl.name) or nil,
      unused_pos = unused_pos,
    })
  end
  return lines
end

-- Calculate popup dimensions and position
local function get_popup_config(content)
  local cursor_screen_row = vim.fn.screenrow()
  local cursor_screen_col = vim.fn.screencol()
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

-- Create or get buffer for popup
local function get_or_create_buffer()
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[state.bufnr].bufhidden = "wipe"
    vim.bo[state.bufnr].buftype = "nofile"
    vim.bo[state.bufnr].swapfile = false

    -- Set up buffer keybindings for when focused
    local function close_popup()
      if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        vim.api.nvim_win_close(state.winid, true)
        state.winid = nil
      end
      state.should_show = false
    end

    -- Set buffer-local keymaps
    vim.keymap.set("n", "<Esc>", close_popup, { buffer = state.bufnr, silent = true })
    vim.keymap.set("n", "<C-c>", close_popup, { buffer = state.bufnr, silent = true })

    -- Add autocmd to clean up state when window is closed externally
    vim.api.nvim_create_autocmd("WinClosed", {
      buffer = state.bufnr,
      callback = function() state.winid = nil end,
    })
  end
  return state.bufnr
end

-- Set buffer content
local function set_buffer_content(bufnr, content)
  local lines = {}
  for _, item in ipairs(content) do
    table.insert(lines, type(item) == "string" and item or item.text)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

-- Create a highlight group for unused targets (same color as Comment with strikethrough)
local function create_unused_highlight()
  local unused_hl_name = "ColorInspectorUnused"
  -- Get the Comment highlight group's color
  local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
  vim.api.nvim_set_hl(0, unused_hl_name, {
    fg = comment_hl.fg,
    ctermfg = comment_hl.ctermfg,
    strikethrough = true,
  })
  return unused_hl_name
end

-- Apply highlights to buffer
local function apply_highlights(bufnr, content)
  local unused_hl = create_unused_highlight()

  -- Create or reuse namespace
  if not state.ns_id then state.ns_id = vim.api.nvim_create_namespace("color_inspector") end

  -- Helper function to add highlight extmark
  local function add_highlight(line_idx, start_col, end_col, hl_group)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, state.ns_id, line_idx, start_col, {
      end_col = end_col,
      hl_group = hl_group,
    })
  end

  for i, item in ipairs(content) do
    if type(item) == "string" or not item.hl_group then goto continue end

    local line_idx = i - 1
    local line_len = #vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)[1]

    if item.links_pos then
      if item.unused_pos then
        -- If target is unused, highlight everything with appropriate colors
        add_highlight(line_idx, 0, item.links_pos, unused_hl)
        add_highlight(line_idx, item.links_pos, item.links_pos + LINKS_TO_LEN, "Comment")
        add_highlight(line_idx, item.links_pos + LINKS_TO_LEN, item.unused_pos, unused_hl)
        add_highlight(line_idx, item.unused_pos, line_len, "Comment")
      else
        -- Normal linked highlight group
        add_highlight(line_idx, 0, item.links_pos, item.hl_group)
        add_highlight(line_idx, item.links_pos, item.links_pos + LINKS_TO_LEN, "Comment")
        add_highlight(line_idx, item.links_pos + LINKS_TO_LEN, line_len, item.hl_group)
      end
    else
      -- Simple highlight group (not linked)
      add_highlight(line_idx, 0, line_len, item.hl_group)
    end

    ::continue::
  end
end

local function update_popup()
  if not state.enabled or not state.should_show then return end

  -- Don't update if popup is currently focused
  local current_win = vim.api.nvim_get_current_win()
  if state.winid and current_win == state.winid then return end

  local highlights = get_highlights()
  local content = format_highlights(highlights)

  -- Close existing window
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then vim.api.nvim_win_close(state.winid, true) end

  -- Prepare buffer
  local bufnr = get_or_create_buffer()
  set_buffer_content(bufnr, content)
  apply_highlights(bufnr, content)

  -- Create new window
  local config = get_popup_config(content)
  state.winid = vim.api.nvim_open_win(bufnr, false, config)
  vim.wo[state.winid].winhl = "Normal:NormalFloat,Border:FloatBorder"
  vim.wo[state.winid].wrap = false
end

-- Hide popup without disabling the inspector
local function hide_popup()
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
    state.winid = nil
  end
  state.should_show = false
end

-- Show popup if inspector is enabled
local function show_popup()
  state.should_show = true
  update_popup()
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
  state.should_show = true
  state.original_bufnr = vim.api.nvim_get_current_buf()
  state.original_winid = vim.api.nvim_get_current_win()

  state.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      -- Don't update popup if it's currently focused
      local current_win = vim.api.nvim_get_current_win()
      if state.winid and current_win == state.winid then return end

      -- Only update popup if we're in the original window
      if current_win ~= state.original_winid then return end

      vim.schedule(update_popup)
    end,
  })

  -- Handle window focus changes
  vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
      local current_buf = vim.api.nvim_get_current_buf()
      local current_win = vim.api.nvim_get_current_win()

      -- Only show popup if we're in the exact original buffer AND window
      if current_buf == state.original_bufnr and current_win == state.original_winid then
        show_popup()
      else
        -- Don't hide popup if we're entering the popup window itself
        if state.winid and current_win == state.winid then
          return
        end
        -- Hide popup if we're in a different window (even with same buffer)
        hide_popup()
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
      local current_win = vim.api.nvim_get_current_win()

      -- Hide popup when leaving the original window
      if current_win == state.original_winid then
        -- Don't hide immediately - schedule it to check after window switch
        vim.schedule(function()
          local new_win = vim.api.nvim_get_current_win()
          -- Only hide if we didn't switch to the popup window
          if state.winid and new_win ~= state.winid then
            hide_popup()
          end
        end)
      end
    end,
  })

  -- Handle window closure
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(event)
      local closed_winid = tonumber(event.match)
      -- If the original window was closed, hide the popup
      if closed_winid == state.original_winid then
        hide_popup()
        -- Reset original window tracking since it no longer exists
        state.original_winid = nil
      end
    end,
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

-- Focus the popup window if it exists and is valid
function M.focus()
  if not state.enabled then return false end

  -- If popup doesn't exist but should be shown, create it first
  if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
    if state.should_show then
      update_popup()
    else
      show_popup()
    end
  end

  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_set_current_win(state.winid)
    return true
  end
  return false
end

function M.is_enabled() return state.enabled end

return M
