# dots

Personal dotfiles. macOS, fish shell, tmux (prefix `C-a`), Neovim, ghostty.

## Worktree fleet workflow

Run multiple Claude sessions in parallel — one git worktree per task, each in its
own tmux session with three windows: **nvim / claude / shell**. Switch between them
to monitor, edit manually in the per-worktree nvim, review results with codediff.

Orchestration lives in **shell + tmux**, not nvim. nvim is just the editor inside
each session. A "fleet session" is just a tmux session with the three windows
rooted at a directory — that's the same whether the directory is a worktree, a
plain repo, or any folder. Two commands create one:

- **`work`** — for any folder / non-worktree repo (e.g. this `dots` repo). Replaces
  the old "`z` into a folder, then open nvim + claude" habit.
- **`wt`** — for worktree-per-task repos; also creates/removes the worktree itself.

Both share `__fleet_session` (the helper that builds the nvim/claude/shell windows
and jumps to them).

### Daily commands

| Command | What it does |
|---|---|
| `work <query>` | zoxide-jump to a project + open/attach its fleet session. No arg = current dir. Session named after the repo (or folder). |
| `wt` (no arg) | fzf-pick one of the current repo's existing worktrees and open its session. The way to re-enter a worktree made earlier. |
| `wt <branch>` | Create a NEW worktree (if missing) + its tmux session, then jump to it. |
| `wt rm <branch>` | Kill the session and remove the worktree. |
| `wt ls` | List this repo's open worktree sessions. |
| `prefix + f` | fzf popup to switch sessions (the fleet). `enter` switches; `ctrl-x` kills the highlighted session (session only — not the worktree). |
| `prefix + r` | Reload tmux config. |

To open an **existing** worktree you can also `work <label>` from anywhere
(zoxide-jump to it), or `wt` inside the repo to pick from the list.

Inside a session: `prefix + 1/2/3` (or `prefix + n/p`) to move between the
nvim / claude / shell windows.

### Conventions

- Session names are worktree-aware (`__fleet_name`): `<repo>` for a main
  checkout, `<repo>/<worktree-dir-label>` for a linked worktree. Opening an
  existing worktree works **regardless of where it lives** — the name comes from
  the worktree's directory label, not its branch (labels are often decoupled from
  branches, e.g. dir `wt/feat` on branch `feat/fiat-rollover`).
- `wt <branch>` *creates* new worktrees at `~/dev/wt/<repo>/<branch>`. Repos with
  pre-existing worktrees elsewhere (e.g. `shufflecom-api/wt/<label>`) are opened
  via `wt` (picker) or `work <label>`, not re-created.

### Attention indicator

When a Claude session finishes or asks a question, a Stop/Notification hook
(`~/.claude/settings.json` → `tmux/wt-flag.sh`) sets the tmux option `@attention`
on that session. The status bar then shows `● <session>` for every waiting agent,
so you can see who needs you from anywhere. The flag clears when you switch into
that session (`client-session-changed` hook in `tmux/tmux.conf`).

### Files

- `fish/functions/work.fish` — the `work` command (+ `fish/completions/work.fish`).
- `fish/functions/wt.fish` — the `wt` command (+ `fish/completions/wt.fish`).
- `fish/functions/__fleet_session.fish` — shared helper: builds the
  nvim/claude/shell windows and jumps. Used by both `work` and `wt`.
- `fish/functions/__fleet_name.fish` — shared helper: derives the worktree-aware
  session name for a directory. Used by both `work` and `wt`.
- `tmux/wt-switch.sh` — fzf session switcher (`prefix + f`).
- `tmux/wt-attention.sh` — emits the `●` chips for the status bar.
- `tmux/wt-flag.sh` — the Claude hook that raises the flag.
- `tmux/tmux.conf` — bindings, the clear hook, `status-right`.
- `~/.claude/settings.json` — registers the `Stop` / `Notification` hooks.

### Requirements

`fzf` and `git` worktree support; tmux ≥ 3.x. fish autoloads `wt` from the
symlinked `~/.config/fish` → `dots/fish`.
