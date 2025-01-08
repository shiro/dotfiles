local ls = require("luasnip")
local s = ls.snippet

local M = {}

local function contains(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

local all_supported_contexts = {
  go = { "source_file", "block", "for_statement", "expression_statement" },
  javascript = { "program", "statement_block", "for_statement", "jsx_element" },
}

function M.context_snippet(opts)
  if opts.ft == nil then
    error("option 'ft' is required but was not provided")
  end
  if all_supported_contexts[opts.ft] == nil then
    error("filetype '" .. opts.ft .. "' is not supported, consider opening a pull request")
  end

  local get_node_type = function()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local node = ts_utils.get_node_at_cursor()

    while node ~= nil do
      for _, value in ipairs(all_supported_contexts[opts.ft]) do
        if value == node:type() then
          return value
        end
      end
      node = node:parent()
    end
  end

  return function(trig, contexts, snippet, extra)
    return s({
      trig = trig,
      -- desc = desc,
      show_condition = function(line_to_cursor)
        return contains(contexts, get_node_type())
      end,
    }, snippet, extra)
  end
end

function M.setup(config)
  --
end

return M
