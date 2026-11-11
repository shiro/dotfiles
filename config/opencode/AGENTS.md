# Model selection

Use the Claude Agent provider (Claude 5.5 family) and match the model to the task:

- `claude-agent/opus` (Opus 5.5): heavy logic, architecture, and high-level orchestration/planning.
- `claude-agent/sonnet` (Sonnet 5.5): debugging and lower-complexity logic tasks.
- `claude-agent/haiku` (Haiku 5.5): trivial tasks such as lookups, simple edits, and formatting.

Use subagents when necessary, such as for parallel or independent work, broad codebase exploration, or isolating large outputs. Pick each subagent's model by the same rules.

# Completion pop-ups

- When you finish a task, or a long-running command completes (build, rebuild, install, download, test run), show a desktop pop-up with `notify-send "opencode" "<message>"`.
- Word the message the same way you word your replies: plain, direct language that states the outcome first. Say what happened, not what you tried. Report failures and skipped steps honestly; never claim success you didn't verify.
- Keep it to one short sentence (under about 100 characters), with no markdown, code blocks, or emoji. Example: `notify-send "opencode" "Rebuild finished; hyprwhspr now uses the AVX2 build."`
- For failures, add `-u critical` so the pop-up stays until dismissed. Example: `notify-send -u critical "opencode" "Rebuild failed: hash mismatch in pywhispercpp."`
- Send one pop-up per finished task or long command, not for every tool call or quick command.
- If `notify-send` isn't available (e.g. over SSH or on a headless machine), skip the pop-up silently.
- Skip these pop-ups when your task or instructions say how results are shown or to show no pop-ups (e.g. omniprompt requests and the subagents they start).

# Git commits

- Only commit when the user explicitly asks you to. Never commit proactively, automatically, or as part of finishing a task.
- Commit as the current default git user (from the existing git config). Never set or override the author or committer (no `--author`, `-c user.name`/`user.email`, or `GIT_AUTHOR_*`/`GIT_COMMITTER_*` environment variables).
- Never add attribution of any kind: no `Co-authored-by:`, `Signed-off-by:`, `Generated-by:` or similar trailers, no "Generated with ..." lines, no AI/tool/model mentions, and no emoji signatures.
- Every commit must have a subject line and a body (separated by a blank line) describing what changed and why. Omit the body only when the user explicitly asks for no body.
