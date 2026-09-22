; extends

(
  (line_comment) @injection.language
  .
  (_
    (raw_string_literal
      (string_content) @injection.content) @_raw)

  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#match? @_raw "^r#")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

(
  (line_comment) @injection.language
  .
  (_
    (macro_invocation
      (token_tree
        (string_literal
          (string_content) @injection.content))))

  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)
