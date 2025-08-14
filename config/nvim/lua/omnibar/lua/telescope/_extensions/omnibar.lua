local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local command_picker
local RegisteredCommands = require("omnibar").registered_commands
local init_done = false

local function setup(registered_commands)
  if init_done then return end
  init_done = true

  registered_commands = registered_commands or {}

  -- set keymaps
  for _, entry in pairs(registered_commands) do
    if entry.keymaps then
      for _, keymap in pairs(entry.keymaps) do
        local mode, keys = unpack(keymap)
        vim.keymap.set(mode, keys, entry.command, { silent = true })
      end
    end
  end

  require("omnibar").RegisteredCommands = registered_commands
  RegisteredCommands = require("omnibar").RegisteredCommands
end

local function list_commands()
  local results = {}

  for name, v in pairs(RegisteredCommands) do
    if v.ft ~= nil then
      local matched = false
      for _, ft in pairs(v.ft) do
        if ft == vim.bo.filetype then matched = true end
      end
      if not matched then goto continue end
    end
    if v.condition ~= nil and not v.condition() then goto continue end
    table.insert(results, name)
    ::continue::
  end
  return results
end

local function make_entry_display()
  return entry_display.create({
    separator = " ",
    items = {
      { width = nil },
      { width = nil },
    },
  })
end

local function make_display(entry)
  local displayer = make_entry_display()
  local keymaps = ""
  for _, keymap in ipairs(entry.keymaps or {}) do
    keymaps = keymaps .. keymap[2] .. " "
  end
  keymaps = vim.trim(keymaps)
  return displayer({
    entry.name,
    { keymaps, "TelescopeResultsComment" },
  })
end

command_picker = function(opts)
  opts = opts or {}
  opts.sorter = require("top-results-sorter").sorter({ name = "omnibar" })

  local selection_start, selection_end = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")

  pickers
    .new(opts, {
      prompt_title = "commands",
      finder = finders.new_table({
        results = list_commands(),
        entry_maker = function(entry)
          return {
            value = entry,
            ordinal = entry,
            display = make_display,
            name = entry,
            keymaps = RegisteredCommands[entry] and RegisteredCommands[entry].keymaps,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local entry = RegisteredCommands[selection.value]
          require("top-results-sorter").PushRecent("omnibar", selection.value)
          require("top-results-sorter").save_history("omnibar")

          -- vim.cmd("normal! gv")

          vim.schedule(function()
            -- vim.api.nvim_buf_set_mark(0, "<", selection_start[1], selection_start[2], {})
            -- vim.api.nvim_buf_set_mark(0, ">", selection_end[1], selection_end[2], {})
            -- vim.cmd("normal! gv")
            -- print(vim.inspect(selection_start))
            -- print(vim.inspect(selection_end))

            entry.command()
          end)
        end)
        return true
      end,
    })
    :find()
end

return require("telescope").register_extension({
  setup = setup,
  exports = { omnibar = command_picker },
})
