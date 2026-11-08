# Model selection

Use the Claude Agent provider (Claude 5.5 family) and match the model to the task:

- `claude-agent/opus` (Opus 5.5): heavy logic, architecture, and high-level orchestration/planning.
- `claude-agent/sonnet` (Sonnet 5.5): debugging and lower-complexity logic tasks.
- `claude-agent/haiku` (Haiku 5.5): trivial tasks such as lookups, simple edits, and formatting.

Use subagents when necessary, such as for parallel or independent work, broad codebase exploration, or isolating large outputs. Pick each subagent's model by the same rules.

# Git commits

- Only commit when the user explicitly asks you to. Never commit proactively, automatically, or as part of finishing a task.
- Commit as the current default git user (from the existing git config). Never set or override the author or committer (no `--author`, `-c user.name`/`user.email`, or `GIT_AUTHOR_*`/`GIT_COMMITTER_*` environment variables).
- Never add attribution of any kind: no `Co-authored-by:`, `Signed-off-by:`, `Generated-by:` or similar trailers, no "Generated with ..." lines, no AI/tool/model mentions, and no emoji signatures.
- Every commit must have a subject line and a body (separated by a blank line) describing what changed and why. Omit the body only when the user explicitly asks for no body.
