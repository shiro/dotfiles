; extends

; Top-level: // language: X above a raw string literal
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

; Top-level: // language: X above a macro_invocation with string_literal (e.g. indoc! {"..."})
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

; Top-level: // language: X above a macro_invocation with raw_string_literal (e.g. indoc! {r#"..."#})
(
  (line_comment) @injection.language
  .
  (_
    (macro_invocation
      (token_tree
        (raw_string_literal
          (string_content) @injection.content))))

  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside arguments: // language: X then bare raw string literal
(
  (arguments
    (line_comment) @injection.language
    .
    (raw_string_literal
      (string_content) @injection.content))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside arguments: // language: X then bare string literal
(
  (arguments
    (line_comment) @injection.language
    .
    (string_literal
      (string_content) @injection.content))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside arguments: // language: X then macro_invocation with raw_string_literal
(
  (arguments
    (line_comment) @injection.language
    .
    (macro_invocation
      (token_tree
        (raw_string_literal
          (string_content) @injection.content))))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside arguments: // language: X then macro_invocation with string_literal
(
  (arguments
    (line_comment) @injection.language
    .
    (macro_invocation
      (token_tree
        (string_literal
          (string_content) @injection.content))))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside macro token_tree: indoc! { // language: X \n r#"..."# }
(
  (token_tree
    (line_comment) @injection.language
    .
    (raw_string_literal
      (string_content) @injection.content))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)

; Inside macro token_tree: indoc! { // language: X \n "..." }
(
  (token_tree
    (line_comment) @injection.language
    .
    (string_literal
      (string_content) @injection.content))
  (#match? @injection.language "^//[[:space:]]*language:[[:space:]]*")
  (#gsub! @injection.language "^//%s*language:%s*" "")
)
