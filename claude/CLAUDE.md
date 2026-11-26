# Global rules

## Capturing rules
When I state a rule ("always…", "never…", "don't do that again"), save it as one terse line, then tell me where:
- About how I work in any repo → this file (`~/dev/dots/claude/CLAUDE.md`).
- A fact or convention of the current repo → that repo's `CLAUDE.md`.
- Must happen every time, no exceptions → propose a hook in `~/dev/dots/claude/settings.json` instead of a text rule.
Don't save one-off instructions. Before adding, check for an existing line to update instead.

## Environment
- macOS, fish shell. Dotfiles live in `~/dev/dots` (symlinked into place); edit there, not the symlink targets.
- I run parallel Claude sessions in git worktrees (`~/dev/wt/<repo>/<label>`) — another session may hold `main`.

## Database
- Never create or run migrations, in any repo. Suggest a migration name and its target database instead (e.g. `AddOfflineFiatDepositTable` for the main db).
