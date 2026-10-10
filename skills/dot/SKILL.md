---
name: dot
description: How to use `dot`, the command that sets up and maintains this Mac from a dotfiles repo, from any project. Use whenever a task clones or forks a GitHub repo, stores or attaches a project secret (API keys, tokens, .env.schema), needs a login for gh, vercel or another account CLI, installs an app or command-line tool, changes a macOS preference, or the user mentions `dot`. Read it before reaching for git clone, brew install, defaults write or a token in a file.
---

# dot

This Mac is set up as code by a dotfiles repo, and `dot` is its single entry
point: it clones projects, keeps project secrets in 1Password, checks logins,
and keeps the Mac matching the repo's `config/`. Prefer it over doing the
same thing by hand, so the Mac stays reproducible and no secret lands on disk.

## Finding it

The zsh function `dot` only exists in interactive shells, and an agent's shell
may have the function without `$DOT_ROOT`. Call the binary by its path. An
interactive zsh loads dot's setup, so it knows the repo:

```sh
DOT_ROOT=${DOT_ROOT:-$(zsh -ic 'printf %s "$DOT_ROOT"' 2>/dev/null)}
"$DOT_ROOT/bin/dot" --help
```

If `DOT_ROOT` is still empty, dot isn't set up on this Mac: say so and stop
instead of doing its work by hand.

`dot <command> --help` documents every command; trust it over this page when
they differ. The human docs are in `$DOT_ROOT/docs/`.

## What you may run, and what waits for the human

Run freely (they change nothing and never ask for Touch ID):

- `dot check [<file>]`: compares the Mac with `config/`.
- `dot explain [<topic>]`, `dot doctor`, `dot --help`, `dot <cmd> --help`.
- `dot clone <repo> --resolve`: prints `owner/repo` without cloning.

Ask first:

- `dot apply`, `dot upgrade`, and anything with `sudo`.
- `dot clone` and `dot fork`: they write to `~/code` (and `fork` creates a
  repo on GitHub).
- `dot conf restore`: it replaces `dot.toml`.

The human's step, never yours:

- Typing or changing a secret's value (`dot secret add`, `dot secret update`).
  Give them the exact command to run.
- `dot defaults diff`: it waits for them to change something in System
  Settings.

## Task → command

| Task | Do this | Not this |
|------|---------|----------|
| Get a GitHub repo onto this Mac | `dot clone <repo>`: it prints the path, `~/code/<owner>/<repo>`; then `cd` there | `git clone` into an arbitrary folder |
| Contribute to someone else's repo | `dot fork <repo>`: forks (or reuses your fork), clones, adds `upstream` | forking in the browser and cloning by hand |
| Give a project an API key or token | the human runs `dot secret add <project>-<use>`; then `dot secret attach <name> <VARIABLE>` in the project adds it to `.env.schema` | a value in `.env`, a file, an argument or the output |
| See which secrets exist | `dot secret list` (references only, never values) | `op item get` |
| Check that a login works (1Password, GitHub, SSH, Vercel, AWS) | `dot auth status` | `gh auth login`, `vercel login` |
| Install an app, font or command-line tool | a `brew cask <name>` or `brew formula <name>` line in the right `config/*.conf`, then `dot apply <file>` (ask) | `brew install` by hand |
| Change a macOS preference | a line in `config/<topic>.conf` (see `dot explain <topic>`), then `dot apply <topic>` (ask) | `defaults write` by hand |
| Pull the latest dotfiles | `dot update` (pulls, then runs `check`; never applies) | `git pull` in the repo and stopping there |

A preference with no setting yet means adding one to the repo: follow its
`AGENTS.md`.

## Output and exit codes

- stdout carries only the result (a path for `clone` and `fork`, a reference
  for `secret add`); messages go to stderr. Capture stdout:
  `dir=$("$DOT_ROOT/bin/dot" clone owner/repo) && cd "$dir"`.
- Exit codes: 0 success, 1 failure or differences (`check` exits 1 when the
  Mac differs, which isn't an error), 2 bad usage or a missing `dot.toml`.

## 1Password and Touch ID

- Tokens reach CLIs only through 1Password shell plugins: `gh` and `vercel`
  run as `op plugin run -- gh …`. In an interactive shell `gh` may already be
  that plugin; in a script, call `op plugin run -- gh` explicitly.
- Each shell you start is a new 1Password session, and the first command in
  it that goes through `op` (`gh`, `vercel`, `dot auth status`, `dot fork`,
  `dot secret`, `dot conf`) asks the human for Touch ID. Batch those commands
  into one shell call instead of one call each.
- Commits are signed through 1Password. Never bypass signing; if it fails,
  stop and ask.
- Never read or print a token, private key or secret value, and never show
  the content of a file the human owns (such as `~/.zshrc`): point to it by
  line number.
