local ls = require("luasnip")
local s = ls.snippet
local sc = require("luasnip-more").context_snippet({ ft = "javascript" })
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local l = require("luasnip.extras").lambda
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local M = {}

M.register = function()
  for _, ft in ipairs({ "lua" }) do
    ls.add_snippets(ft, {
      -- cl - console log
      -- {{{
      s(
        "cl",
        fmta(
          [[
print(vim.inspect(<finish>))
]],
          { finish = i(0) }
        )
      ),
      -- }}}
    })
  end
end

return M
