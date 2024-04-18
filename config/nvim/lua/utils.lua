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

return M
