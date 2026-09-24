# AGENTS.md

macOS setup as code: `config/` declares settings, `./dot check|apply` compares
them with the machine and fixes differences. Human docs: README.md (entry
point) and docs/ (index: docs/README.md).

## Rules

- Run `./dot check` freely: it never changes anything. It never needs Touch ID
  or a password either; keep it that way when adding settings.
- Ask before `./dot apply`, before anything that uses sudo, and before any
  other command that changes the machine.
- Never commit `dot.conf`, secrets, or machine-specific values.
- Never rewrite `~/.zshrc`: only the marked `# >>> dotfiles` block belongs to
  the repo. Tools may append to the rest.
- Files under `home/` are linked into `~`, and apps edit them in place (e.g.
  Zed's settings). Treat unexpected diffs there as the user's changes: never
  revert them without asking.
- 1Password items this repo creates or uses (not logins) are tagged
  `dotfiles`. Don't pass `--vault`: `op` defaults to the built-in personal
  vault, whatever its name (Personal, Private or Employee).
- Never read or print private keys or tokens. Public keys come from
  1Password's agent (`ssh_pubkey`); tokens reach CLIs only through 1Password
  shell plugins.
- Commits are signed through 1Password (Touch ID). Never bypass signing
  (`--no-gpg-sign`, `-c commit.gpgsign=false`); if signing fails, stop and ask.
- The repo is public. Ask before `git push`, and never rewrite pushed history.
- Everything in this repo is written in English.
- Keep it minimal: add files and folders only when needed. Update README.md
  and this file in the same change as the structure they describe.
- README.md stays short: what this is and where to go. Details belong in
  docs/: one document per purpose, listed in docs/README.md.
- Docs describe what exists and how it works, never how it was decided (what
  was tried, which alternatives lost). That belongs in commit messages.
- Record every step a clean machine needs in docs/getting-started.md, with
  details in the topic's doc.

## Where things go

| Task                              | Location                                   |
|-----------------------------------|--------------------------------------------|
| Change a preference               | `config/<theme>.sh`                        |
| Install an app (GUI)              | `brew cask <name>` in `config/apps.sh`      |
| Install a CLI tool                | `brew formula <name>` or `brew cask <name>` in `config/packages.sh` |
| Install a font                    | `brew cask <name>` in `config/fonts.sh`     |
| Put an app's config file in `~`   | the file under `home/`, mirroring its path in `~`, plus a catalog setting that calls `link` |
| Change the shell                  | `shell/<topic>.zsh`, listed in `shell/init.zsh` |
| Add a setting                     | function in `catalog/<topic>.sh`, line in `config/<theme>.sh`, row in docs/settings.md |
| Add a personal value (names, …)   | `dot.conf` (real) and `dot.conf.example` (placeholder) |
| Support a new tool (defaults, git…) | new `lib/<tool>.sh`                      |
| Document a clean-machine step     | `docs/getting-started.md`, details in the topic doc |
| Document a topic (shell, editor…) | `docs/<topic>.md`, listed in `docs/README.md` |
| Document a login (GitHub, Vercel…) | `docs/auth/<platform>.md`, plus its row in `docs/auth/README.md` |
| Change what happens before the repo exists | `install.sh` |

New files in `config/`, `catalog/` and `lib/` are picked up automatically.

## Layers

**config/<theme>.sh** holds data and is never executed. A file groups lines by
theme and may mix topics; `./dot check <theme>` runs that file. It's read on
fd 3, so commands run by a setting keep the real stdin.
- One `<topic> <setting> <value>` per line, with no verbs. Lines starting
  with `#` are comments.
- Values are split on spaces, except that a whole word `$name` is replaced
  by `name` from `dot.conf` as a single value, even if it contains spaces.
- Personal values always go through `dot.conf`, never literally in config/ or
  catalog/.

**catalog/<topic>.sh** holds one function per setting, named
`<topic>_<setting>()` (hyphens become underscores).
- Only functions defined in catalog/ are settings: `dot` refuses anything
  else, so lib/ functions can't be called directly from the CLI.
- A comment above each function gives its syntax and accepted values.
- Validate input and call `fail "<message>"; return` on bad values.
- Call lib functions; never touch the system directly.
- After the lib calls, declare effects:
  - `restart <app>` is done automatically at the end of apply; an app that
    doesn't come back on its own (not the Dock) is reopened.
  - `note "<text>"` adds information under the setting (e.g. lines in
    `~/.zshrc` that aren't from the repo). It never counts as a difference.
  - `effect "<step>"` is reported to the user (e.g. log out).
  - `restart` and `effect` are no-ops unless the setting actually changed
    something; notes always show.

**lib/<tool>.sh**, one file per tool (defaults, scutil, git, brew, ssh, gh,
op, file, link, keys), is the only code that reads or changes the system.
- Each function reads the current value and returns 0 if it matches.
- Otherwise, in apply mode it changes it and sets `DOT_CHANGED=1`. In both
  modes it calls `changed "<what>" "<from>" "<to>" [note]`.
- Mark sudo with the note `sudo` and in the function's comment.
- Never print directly; use lib/output.sh.
- Current functions:
  - `default` / `default_unset` in defaults.sh
  - `scutil_name` in scutil.sh (sudo)
  - `gitconfig [-f <file>]` in gitconfig.sh (global ~/.gitconfig, or another
    file such as an identity under ~/.config/git/identities/)
  - `brewpkg` in brew.sh (installs only; never uninstalls)
  - `file_block` in file.sh (appends a block if missing; never rewrites the
    rest of the file, so tools can keep editing it)
  - `gh_ssh_key` in gh.sh (check reads GitHub's public key lists with curl, no
    token; apply adds keys via `gh` through 1Password, which may ask for
    Touch ID)
  - `op_document` in op.sh (backs a file up to 1Password, tagged `dotfiles`;
    check compares it with a local record of the last upload, so it needs no
    Touch ID; a Mac without that record never overwrites an existing backup)
  - `link` in link.sh (symlinks a `home/` file into `~`; backs up an existing
    file instead of overwriting it)
  - `default_shortcut` in defaults.sh (a `{keyCode, modifierFlags}` shortcut, as
    Rectangle stores them)
  - `key_combo` in keys.sh is a helper: turns `cmd+opt+left` into a key code
    and modifier flags
  - `ssh_pubkey` in ssh.sh is a helper, not a check: it prints a public key
    from 1Password's agent by item title, without Touch ID

**home/** mirrors `~`. Each file is linked into place by a catalog setting
that calls `link`, and apps edit it through the link. Keep app settings in
the format the app writes back (Zed: plain JSON, no comments).

**shell/** holds zsh files, one per topic, loaded in the order listed in
`shell/init.zsh`. `~/.zshrc` only sources `init.zsh` through the managed
block.

## install.sh

- It runs before the repo exists, via `curl`, so it must stay self-contained:
  it never sources lib/ or catalog/.
- It never runs `git`, `python3`, `make` or `cc` before confirming the
  Command Line Tools exist at `/Library/Developer/CommandLineTools`.
- It shows its plan before changing anything. Every step is skipped when
  already done.
- All code lives in functions, and `main "$@"` stays the last line, so a
  truncated download never runs.
- Agents run it without a terminal: `sh install.sh --yes --no-apply` installs
  and stops after `./dot check`, so the human can review before `./dot apply`.
  With no flags and no terminal it stops before changing anything. Installing
  Homebrew needs sudo; if sudo needs a password, it stops and asks the human
  to run it.
- Restoring dot.conf writes the same record as `op_document`
  (`~/.local/state/dotfiles/dotfiles-dot-conf.sha256`); keep the two in sync.
- Test it with `sh install.sh --dry-run`, and `HOME=$(mktemp -d)` to simulate
  a clean machine.

## Verify

- `sh -n <file>` for every changed script (POSIX sh), `zsh -n` for `shell/`,
  and `/usr/bin/jq .` for JSON under `home/`.
- `./dot check <theme>` exits 0 when the machine matches, 1 on differences
  or errors, and 2 on bad usage (unknown command, option or theme) or a
  missing `dot.conf`.
- To test an apply path without touching real settings, source the libs in a
  subshell with `DOT_MODE=apply` against a throwaway defaults domain, then
  `defaults delete` it.
- After an approved apply, `./dot check <topic>` must be all ✓.
