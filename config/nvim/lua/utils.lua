local M = {}
function M.spread(template)
  local result = {}
  for key, value in pairs(template) do
    result[key] = value
  end

  return function(table)
    for key, value in pairs(table) do
      result[key] = value
    end
    return result
  end
end

function M.notify(message)
  if type(message) == "string" then
    require("notify")(message)
  else
    require("notify")(vim.inspect(message))
  end
end

function M.hot_reload_listen(name)
  if _G.loaded_plugins == nil then _G.loaded_plugins = {} end
  if _G.plugins_to_reload == nil then _G.plugins_to_reload = {} end

  -- if alredy loaded, it means we already came here before
  if _G.loaded_plugins[name] then
    vim.schedule(function()
      if not _G.plugins_to_reload then return end

      local original_notify = vim.notify
      vim.notify = function() end

      -- vim.cmd("mkview")
      require("lazy").reload({ plugins = vim.tbl_keys(_G.plugins_to_reload) })
      -- vim.cmd("loadview")

      vim.notify = original_notify
      _G.plugins_to_reload = {}
    end)
  end

  _G.loaded_plugins[name] = true
  _G.plugins_to_reload[name] = true
end

return M
