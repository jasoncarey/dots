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
| `wt <branch>` | Create a NEW worktree (if missing) + its tmux session, then jump to it. Local branch → checked out; branch on origin → tracked; otherwise a new branch off freshly-fetched `origin/<default>` (no upstream). New worktrees are prepared by `__wt_setup` (below). |
| `wt rm <branch>` | Kill the session and remove the worktree (the branch is kept). |
| `wt ls` | List this repo's open worktree sessions. |
| `nb <branch>` | In the current worktree: fetch origin's default branch and `switch -c <branch> --no-track origin/<default>`. Reuse a worktree for a new task without checking out `main` (which another worktree may hold). |
| `prefix + f` | Fleet picker popup: open sessions (`●`) on top, then every worktree that has no session yet (`○`), each with its branch + a git status/log preview. `enter` switches to a session, or creates the fleet session for a `○` worktree and jumps in. `ctrl-n` prompts for a branch and runs `wt <branch>` in the highlighted row's repo. `ctrl-d` deletes the highlighted worktree (confirms; offers `--force` if dirty; keeps the branch; refuses the main checkout and the session you're in). `ctrl-x` kills the highlighted session (session only — not the worktree); `ctrl-r` renames it. |
| `prefix + r` | Reload tmux config. |

In practice the whole lifecycle runs from `prefix + f`: `ctrl-n` to start a
task, `enter` to move between them (a `○` row reopens a worktree after a reboot
or `ctrl-x`), `ctrl-d` when it's done. `wt` is the same thing from the shell.

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
- `wt <branch>` *creates* new worktrees at `~/dev/wt/<repo>/<label>`, where the
  label is the branch with `/` flattened to `-` (`feat/x` → `feat-x`), so the
  session is `<repo>/feat-x` and matches what `prefix + f` shows.
- On creation `__wt_setup` symlinks the main checkout's **untracked** `.env*`
  files into the worktree (one shared local config; tracked ones like
  `.env.test` are skipped) and installs deps from whichever lockfile exists
  (pnpm / yarn / bun / npm, `--frozen-lockfile --prefer-offline`).
- Repos with
  pre-existing worktrees elsewhere (e.g. `shufflecom-api/wt/<label>`) are opened
  via `wt` (picker) or `work <label>`, not re-created.

### Session persistence (surviving a reboot)

tmux-resurrect + tmux-continuum (via tpm) keep the fleet across restarts.
Continuum autosaves every 15 min and **auto-restores when the tmux server
starts** — so after a reboot the first `work`/`wt`/`tmux` brings every session
back: names, windows (nvim/claude/shell), layouts and per-window cwd.

- **nvim** relaunches automatically (it's in resurrect's default restore list);
  use LazyVim's `<leader>qs` to reload that directory's buffers.
- **claude** deliberately does *not* relaunch — a restored window would start a
  fresh conversation. The claude window comes back as a fish shell in the right
  worktree; run `claude --continue` there to resume.
- Manual save/restore: `prefix + C-s` / `prefix + C-r`. Saves live in
  `~/.tmux/resurrect/` (timestamped files + a `last` symlink).
- Pane scrollback capture is off on purpose: resurrect writes capture files
  named `pane-<session>:<win>.<pane>`, and fleet session names contain a slash
  (`repo/worktree`), so those writes fail. Turning it on would only add
  scrollback for non-worktree sessions and error on the rest.

Plugins are declared in `tmux/tmux.conf`; tpm itself is untracked and lives in
`~/.tmux/plugins/` — bootstrap with
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then
`prefix + I`.

### Files

- `fish/functions/work.fish` — the `work` command (+ `fish/completions/work.fish`).
- `fish/functions/wt.fish` — the `wt` command (+ `fish/completions/wt.fish`).
- `fish/functions/__fleet_session.fish` — shared helper: builds the
  nvim/claude/shell windows and jumps. Used by both `work` and `wt`.
- `fish/functions/__fleet_name.fish` — shared helper: derives the worktree-aware
  session name for a directory. Used by both `work` and `wt`.
- `fish/functions/__wt_setup.fish` — new-worktree prep for `wt`: link untracked
  `.env*` from the main checkout, install deps. (Un-ignored in `.gitignore`, like
  the other tracked functions.)
- `tmux/wt-switch.sh` — fleet picker (`prefix + f`). Scans worktrees of every repo
  that has an open session plus the repo of the current pane, so worktrees show
  up wherever they live on disk. Plain bash 3.2 (macOS `/bin/bash`).
- `tmux/tmux.conf` — bindings, `status-right`.

### Requirements

`fzf` and `git` worktree support; tmux ≥ 3.x. fish autoloads `wt` from the
symlinked `~/.config/fish` → `dots/fish`. Session persistence needs tpm cloned
to `~/.tmux/plugins/tpm` (see above).

## Theme toggle

`theme` (fish fn) switches the whole terminal look in one shot:

| Command | Look |
|---|---|
| `theme solarized` | Solarized Osaka (official craftzdog palette; whites softened) |
| `theme default` | TokyoNight (fish) + Cyberpunk (tmux) |

It flips **fish** syntax colors (`fish_config theme save` → universal vars, live in
all shells), **tmux** (rewrites the sourced theme path + live-reloads), and
**starship** (comments/uncomments the `solarized_osaka` palette). **ghostty** it
rewrites the `theme =` line but can't reload from the CLI — hit `cmd+shift+,`.

Why a command and not a git branch: the active fish theme lives in the gitignored
`fish/fish_variables`, so a branch checkout can't toggle it.

### Files

- `fish/functions/theme.fish` — the `theme` command (+ `fish/completions/theme.fish`).
- `tmux/themes/solarized-osaka.conf`, `tmux/themes/cyberpunk.conf` — the two
  status-bar blocks; `tmux/tmux.conf` `source-file`s whichever is selected.
- `ghostty/themes/solarized-osaka` — official palette; `solarized-osaka-tuned` is
  the prior hand-tuned backup.
- `starship/starship.toml` — holds the `[palettes.solarized_osaka]` block, which
  overrides the standard color names the default prompt uses. Symlinked to
  `~/.config/starship.toml`; the fn edits the real dots file (`sed -i` would sever
  the symlink).

## fzf

Three places use fzf, all independent:

| Trigger | What |
|---|---|
| `prefix + f` (tmux) | `tmux/wt-switch.sh` — fleet picker (sessions + worktrees) in a popup. |
| `wt` with no arg | picks one of the current repo's worktrees. |
| fish key bindings | `fzf.fish` plugin (below). |

### fzf.fish bindings

Installed with `fisher install patrickf1/fzf.fish` (tracked in `fish/fish_plugins`;
the plugin's own files land in the gitignored `fish/functions`, `conf.d`,
`completions`). Defaults, live in both default and vi-insert mode:

| Key | Search |
|---|---|
| `ctrl-r` | command history |
| `ctrl-alt-f` | directory (files/dirs under cwd, via `fd`) |
| `ctrl-alt-l` | git log |
| `ctrl-alt-s` | git status (modified files) |
| `ctrl-alt-p` | processes |
| `ctrl-v` | shell variables |

Rebind with `fzf_configure_bindings --history=... --directory=...` in
`fish/config.fish` (pass `--<feature>` with no value to disable one).

Deps: `fd` (directory search) and `bat` (file preview — the preview command calls
it with no fallback, so it's required, not optional). `macos-option-as-alt = true`
in `ghostty/config` is what makes the `ctrl-alt-*` keys reach fish.

## Claude Code

Global Claude config lives in `claude/`, symlinked into `~/.claude/`:

| File | Symlink | Purpose |
|---|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Global rules, loaded every session — keep it short. |
| `claude/settings.json` | `~/.claude/settings.json` | Permissions, status line. |
| `claude/statusline.sh` | — (referenced by path) | Status line: dir, branch/state, node, model, context %. |

New machine: `ln -sf ~/dev/dots/claude/{CLAUDE.md,settings.json} ~/.claude/`.
Never track `~/.claude/` machine state (`projects/`, `sessions/`, `history.jsonl`, caches).
`~/.claude/skills/synced/` is managed by claude.ai — add personal skills as
`claude/skills/<name>` and symlink each one, not the whole dir.
