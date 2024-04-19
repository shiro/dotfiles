local ls = require("luasnip")
local s = ls.snippet
local sc = require("luasnip-more").context_snippet({ ft = "javascript" })
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
      -- fna - anonymous function with arguments
      -- {{{
      s(
        "fna",
        fmta(
          [[
(<args>) =>> {<finish>}
]],
          {
            args = i(1),
            finish = i(0),
          }
        )
      ),
      -- }}}
      -- fori - for-i loop
      -- {{{
      sc(
        "fori",
        { "statement_block" },
        fmta(
          [[
for(let <iterable> = <initial>; <val> << <limit>; <change_expr>){
  <finish>
}
]],
          {
            iterable = i(1, "i"),
            initial = i(2, "0"),
            val = rep(1),
            limit = i(3),
            change_expr = d(4, function(args)
              return sn(nil, {
                i(1, args[1][1] .. "++"),
              })
            end, { 1 }),
            finish = i(0),
          }
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
      sc(
        "cv",
        { "statement_block" },
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
    sc(
      "comp",
      { "program" },
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
    sc(
      "Show",
      { "jsx_element" },
      fmta(
        [[
<<Show when={<cond>}>>
  <finish>
<</Show>>
]],
        {
          cond = i(1, "true"),
          finish = i(0),
        }
      )
    ),
    -- }}}
    -- For - Solid.JS For component
    -- {{{
    sc(
      "For",
      { "jsx_element" },
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
