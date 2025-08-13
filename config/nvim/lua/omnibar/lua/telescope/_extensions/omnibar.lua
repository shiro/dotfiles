local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local command_picker
local RegisteredCommands = require("omnibar").registered_commands

local function setup(registered_commands)
  registered_commands = registered_commands or {}
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

command_picker = function(opts)
  opts = opts or {}
  opts.sorter = require("top-results-sorter").sorter({ name = "omnibar" })

  local selection_start, selection_end = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")

  pickers
    .new(opts, {
      prompt_title = "commands",
      finder = finders.new_table({
        results = list_commands(),
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local entry = RegisteredCommands[selection[1]]
          require("top-results-sorter").PushRecent("omnibar", selection[1])
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
