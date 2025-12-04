; css`<css>`, keyframes`<css>`
(call_expression
  function: (identifier) @_name
  (#any-of? @_name "css" "style")
  arguments: (template_string) @injection.content
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "styled"))

; styled(Component)`<css>`
(call_expression
  function: (call_expression
    function: (identifier) @_name
    (#eq? @_name "styled"))
  arguments: ((template_string) @injection.content
    (#offset! @injection.content 0 1 0 -1)
    (#set! injection.include-children)
    (#set! injection.language "styled")))

; styled.div.attrs({ prop: "foo" })`<css>`
(call_expression
  function: (call_expression
    function: (member_expression
      object: (member_expression
        object: (identifier) @_name
        (#eq? @_name "styled"))))
  arguments: ((template_string) @injection.content
    (#offset! @injection.content 0 1 0 -1)
    (#set! injection.include-children)
    (#set! injection.language "styled")))

; styled(Component).attrs({ prop: "foo" })`<css>`
(call_expression
  function: (call_expression
    function: (member_expression
      object: (call_expression
        function: (identifier) @_name
        (#eq? @_name "styled"))))
  arguments: ((template_string) @injection.content
    (#offset! @injection.content 0 1 0 -1)
    (#set! injection.include-children)
    (#set! injection.language "styled")))
