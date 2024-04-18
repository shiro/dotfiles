local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local M = {}

M.register = function()
  for _, ft in ipairs({ "typescript", "typescriptreact" }) do
    ls.add_snippets(ft, {
      -- cl - console log
      -- {{{
      s(
        "cl",
        fmta(
          [[
console.log(<finish>)
]],
          { finish = i(0) }
        )
      ),
      -- }}}
      -- fn - anonymous function
      -- {{{
      s(
        "fn",
        fmta(
          [[
() =>> {<finish>}
]],
          { finish = i(0) }
        )
      ),
      -- }}}
      -- forof - for-of loop
      -- {{{
      s(
        "forof",
        fmta(
          [[
for(const <val> of <iterable>){
<finish>
}
]],
          {
            iterable = i(1),
            val = i(2),
            finish = i(0),
          }
        )
      ),
      -- }}}
      -- if - if block statement
      -- {{{
      s(
        "if",
        fmta(
          [[
if(<cond>) {
<finish>
}
]],
          {
            cond = i(1),
            finish = i(0),
          }
        )
      ),
      --}}}
      -- map - array map function
      -- {{{
      s(
        ".map",
        fmta(
          [[
.map((<item>) =>> {
  <finish>
  return <item_rep>;
})
]],
          {
            item = i(1),
            item_rep = rep(1),
            finish = i(0),
          }
        )
      ),
      --}}}
      -- cv - constant variable
      -- {{{
      s(
        "cv",
        fmta(
          [[
const <name> = <finish>;
]],
          {
            name = i(1),
            finish = i(0),
          }
        )
      ),
      --}}}
    })
  end

  ls.add_snippets("typescriptreact", {
    -- comp - component
    -- {{{
    s(
      "comp",
      fmta(
        [[
const <name>: Component<<any>> = (props: any) =>> {
  const {children} = $destructure(props);
  return <<div>>{children}<finish><</div>>;
};
]],
        {
          name = i(1, "Component"),
          finish = i(0),
        }
      )
    ),
    -- }}}
    -- Show - Solid.JS Show component
    -- {{{
    s(
      "Show",
      fmt(
        [[
  <Show when={{{}}}>
   {}
  </Show>
  ]],
        {
          i(1, "true"),
          i(0),
        }
      )
    ),
    -- }}}
    -- For - Solid.JS For component
    -- {{{
    s(
      "For",
      fmta(
        [[
        <<For each={<items>}>>
  {(<item>) =>> <<>>
   <finish>
  <</>>}
  <</For>>
  ]],
        {
          items = i(1, "[]"),
          item = i(2, "x"),
          finish = i(0),
        }
      )
    ),
    -- }}}
  })
end

return M
