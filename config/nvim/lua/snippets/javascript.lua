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
      -- asyncdelayfn - async delay function
      -- {{{
      sc(
        "asyncdelayfn",
        { "program" },
        fmta(
          [[
          const delay = (ms: number) =>> new Promise((resolve) =>> setTimeout(resolve, ms));
]],
          {}
        )
      ),
      -- }}}
      -- forof - for-of loop
      -- {{{
      sc(
        "forof",
        { "program", "statement_block" },
        fmta(
          [[
          for (const <item> of <items>) {
              <finish>
          }
          ]],
          {
            item = i(2, "item"),
            items = i(1, "items"),
            finish = i(0),
          }
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
            change_expr = d(
              4,
              function(args)
                return sn(nil, {
                  i(1, args[1][1] .. "++"),
                })
              end,
              { 1 }
            ),
            finish = i(0),
          }
        )
      ),
      -- }}}
      -- forof - for-of loop
      -- {{{
      sc(
        "forof",
        { "statement_block" },
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
      sc(
        "if",
        { "statement_block" },
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
    -- uses - react use state
    -- {{{
    sc(
      "uses",
      { "statement_block" },
      fmta([[const [<getter>, set<setter>] = useState(<initial>);<finish>]], {
        getter = i(1),
        initial = i(2),
        setter = l(l._1:sub(1, 1):upper() .. l._1:sub(2, -1), 1),
        finish = i(0),
      }),
      {
        callbacks = {
          [-1] = {
            [events.enter] = function()
              require("ts-manual-import").import({
                { modules = { "useState" }, source = "react" },
              })
            end,
            [events.leave] = function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "s", false)
            end,
          },
        },
      }
    ),
    -- }}}
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
