local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

local M = {}

M.register = function()
  ls.add_snippets("rust", {
    s(
      "cl",
      fmta(
        [[
println!("<ident>: {:?}", <ident_rep>);<finish>
]],
        {
          ident = i(1),
          ident_rep = rep(1),
          finish = i(0),
        }
      )
    ),
  })
end

return M
