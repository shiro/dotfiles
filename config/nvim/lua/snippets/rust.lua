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
    -- info - print info
    -- {{{
    s(
      "info",
      fmta(
        [[
info!("<text> {:?}", <value>);<finish>
]],
        {
          text = i(1),
          value = i(2, "()"),
          finish = i(0),
        }
      )
    ),
    -- }}}
    -- cl - console log
    s(
      "cl",
      fmta(
        [[
println!("<message>{:?}", (<value>));<finish>
]],
        {
          value = i(1),
          message = i(2),
          finish = i(0),
        }
      )
    ),
    -- }}}
  })
end

return M
