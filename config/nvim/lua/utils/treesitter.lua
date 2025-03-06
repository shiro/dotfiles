local M = {}

--- @param node TSNode
function M.children(node)
  local res = {}
  if node == nil then return res end
  for n in node:iter_children() do
    table.insert(res, n)
  end
  return res
end

return M
