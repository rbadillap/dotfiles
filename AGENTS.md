# AGENTS.md

macOS setup as code. `config/*.conf` declares settings; `dot check` compares
them with the Mac and `dot apply` fixes the differences. `dot` is the single
entry point for everything. Human docs: README.md and docs/ (index:
docs/README.md). Run `./dot --help` from the repo root; in scripts, call `dot`
by its path, since the shell function only exists in interactive zsh.

## Rules

- Run `dot check` freely: it never changes anything. It never needs Touch ID
  or a password either; keep it that way when adding settings.
- Ask before `dot apply`, before anything that uses sudo, and before any other
  command that changes the machine (including `dot clone` and `dot fork`).
- Never commit `dot.conf`, secrets, or machine-specific values.
- Never rewrite shared files such as `~/.zshrc`: only the marked
  `# >>> dotfiles` block belongs to the repo. Tools may append to the rest.
- Files under `config/home/` are linked into `~`, and apps edit them in place
  (e.g. Zed's settings). Treat unexpected diffs there as the user's changes:
  never revert them without asking.
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

## Layout

| Path                     | Holds                                                   |
|--------------------------|---------------------------------------------------------|
| `dot`                    | the dispatcher: finds and runs `src/commands/dot-<cmd>` |
| `install.sh`             | clean-Mac installer (self-contained)                    |
| `dot.conf`               | personal values, ignored by git; `dot.conf.example` is the template |
| `src/commands/`          | one file per command                                    |
| `src/settings/<topic>.sh`| one function per setting                                |
| `src/lib/`               | shared code; the only code that changes the system      |
| `config/*.conf`          | the owner's declarations (data, never executed)         |
| `config/home/`           | files linked into `~`, mirroring their path             |
| `config/shell/`          | the owner's zsh files, loaded by `dot init zsh`         |

`src/` is the engine; `config/` and `dot.conf` are what a fork changes.

## Where things go

| Task                               | Location                                              |
|------------------------------------|-------------------------------------------------------|
| Change a preference                | a line in `config/<file>.conf`                        |
| Install an app                     | `brew cask <name>` in `config/apps.conf`               |
| Install a command-line tool        | `brew formula <name>` or `brew cask <name>` in `config/packages.conf` |
| Install a font                     | `brew cask <name>` in `config/fonts.conf`              |
| Add a setting                      | function in `src/settings/<topic>.sh`, line in `config/`, row in docs/settings.md |
| Add a command                      | `src/commands/dot-<name>` (or `dot-<group>-<sub>`), row in docs/dot.md |
| Put an app's config file in `~`    | `config/home/<path>`, plus a setting that calls `link` |
| Add something to the shell         | `config/shell/<topic>.zsh`                            |
| Add a personal value (names, …)    | `dot.conf` (real) and `dot.conf.example` (placeholder) |
| Support a new system tool          | `src/lib/<tool>.sh`                                   |
| Document a clean-machine step      | docs/getting-started.md, details in the topic doc     |
| Document a topic (shell, editor…)  | `docs/<topic>.md`, listed in docs/README.md           |
| Document a login (GitHub, Vercel…) | `docs/auth/<platform>.md`, plus its row in docs/auth/README.md |
| Change what happens before the repo exists | `install.sh`                                  |

New files in `config/`, `src/settings/`, `src/lib/` and `src/commands/` are
picked up automatically.

## Commands

Each command is an executable `src/commands/dot-<name>` in POSIX sh. Its
header is its documentation; `dot --help`, `dot <cmd> --help` and completion
come from it:

    #!/bin/sh
    # Summary: One line, starting with a verb
    # Usage: dot <name> <args>          (one line per form)
    # Group: core | repos | additional | hidden
    #
    # Description paragraph(s).
    #
    # FLAGS / ARGUMENTS / EXAMPLES / EXIT CODES   (optional sections)
    set -eu

- The dispatcher handles `-h`/`--help`, `help <cmd>`, `--version`, unknown
  commands and suggestions; commands never implement help.
- `DOT_ROOT` is set. Messages go to stderr, prefixed `dot <name>:`; stdout
  carries only the result (for example a path), so scripts and agents can use
  it. Exit codes: 0 success, 1 failure or differences, 2 bad usage.
- Validate input, never overwrite, and leave nothing half-done on failure.
- Commands whose result is a folder (`clone`, `fork`, `cd`) print only that
  path; the zsh `dot` function from `dot init zsh` cds into it. Add a new one
  to the `case` in `src/commands/dot-init`.
- Completion candidates come from `src/commands/dot-__complete`; extend it
  when a command takes arguments that can be listed.

## Settings

**config/*.conf** holds data and is never executed. Files are read on fd 3, so
commands run by a setting keep the real stdin.
- One `<topic> <setting> <value>` per line, with no verbs. Lines starting with
  `#` are comments. A file may mix topics.
- Values are split on spaces, except that a whole word `$name` is replaced by
  `name` from `dot.conf` as a single value, even if it contains spaces.
- Personal values always go through `dot.conf`, never literally in config/ or
  src/.

**src/settings/<topic>.sh** holds one function per setting, named
`<topic>_<setting>()` (hyphens become underscores).
- Only these functions are settings: `dot` refuses anything else, so lib
  functions can't be called from the command line.
- The comment block above each function is its documentation, shown by
  `dot settings`. The first line is the syntax, then three spaces and a short
  description: `# dock visibility <always|autohide|hidden>   what it does`.
  Values written as `<a|b|c>` become completion candidates.
- Validate input and call `fail "<message>"; return` on bad values.
- Call lib functions; never touch the system directly.
- After the lib calls, declare effects:
  - `restart <app>` is done automatically at the end of apply; an app that
    doesn't come back on its own (not the Dock) is reopened.
  - `note "<text>"` adds information under the setting. It never counts as a
    difference.
  - `effect "<step>"` is reported to the user (e.g. log out).
  - `restart` and `effect` are no-ops unless the setting actually changed
    something; notes always show.

**src/lib/<tool>.sh** is the only code that reads or changes the system.
- Each function reads the current value and returns 0 if it matches.
- Otherwise, in apply mode it changes it and sets `DOT_CHANGED=1`. In both
  modes it calls `changed "<what>" "<from>" "<to>" [note]`.
- Mark sudo with the note `sudo` and in the function's comment.
- Never print directly; use `src/lib/output.sh`. `src/lib/run.sh` runs
  config files for `dot check` and `dot apply`.
- Current functions:
  - `default`, `default_unset`, `default_shortcut` in defaults.sh
  - `scutil_name` in scutil.sh (sudo)
  - `gitconfig [-f <file>]` in gitconfig.sh (global ~/.gitconfig, or another
    file such as an identity under ~/.config/git/identities/)
  - `brewpkg` in brew.sh (installs only; never uninstalls; adopts apps
    installed by hand)
  - `file_block` in file.sh (appends a block if missing) and
    `file_managed_block` (keeps a `# >>> name` … `# <<< name` block, replacing
    it when it changes); neither touches the rest of the file
  - `gh_ssh_key` in gh.sh (check reads GitHub's public key lists with curl,
    no token; apply adds keys via `gh` through 1Password)
  - `op_document` in op.sh (backs a file up to 1Password, tagged `dotfiles`;
    check compares it with a local record of the last upload, so it needs no
    Touch ID; a Mac without that record never overwrites an existing backup)
  - `link` in link.sh (symlinks a `config/home/` file into `~`; backs up an
    existing file instead of overwriting it)
  - Helpers that aren't checks: `ssh_pubkey` in ssh.sh (a public key from
    1Password's agent by item title, no Touch ID) and `key_combo` in keys.sh
    (`cmd+opt+left` to a key code and modifier flags)

**config/home/** mirrors `~`. Keep app settings in the format the app writes
back (Zed: plain JSON, no comments).

## install.sh

- It runs before the repo exists, via `curl`, so it must stay self-contained:
  it never sources src/.
- It never runs `git`, `python3`, `make` or `cc` before confirming the
  Command Line Tools exist at `/Library/Developer/CommandLineTools`.
- It shows its plan before changing anything. Every step is skipped when
  already done.
- All code lives in functions, and `main "$@"` stays the last line, so a
  truncated download never runs.
- Agents run it without a terminal: `sh install.sh --yes --no-apply` installs
  and stops after `./dot check`, so the human can review before applying.
  With no flags and no terminal it stops before changing anything. Installing
  Homebrew needs sudo; if sudo needs a password, it stops and asks the human
  to run it.
- Restoring dot.conf writes the same record as `op_document`
  (`~/.local/state/dotfiles/dotfiles-dot-conf.sha256`); keep the two in sync.
- Test it with `sh install.sh --dry-run`, and `HOME=$(mktemp -d)` to simulate
  a clean machine.

## Verify

- `sh -n` for every changed script (POSIX sh: `dot`, `install.sh`,
  `src/**`), `zsh -n` for `config/shell/`, and `/usr/bin/jq .` for JSON under
  `config/home/`.
- `./dot check [<file>]` exits 0 when the Mac matches, 1 on differences or
  errors, and 2 on bad usage or a missing `dot.conf`.
- `./dot --help` and `./dot <cmd> --help` must render; `./dot __complete …`
  must list what completion should offer.
- To test an apply path without touching real settings, source the libs in a
  subshell with `DOT_MODE=apply` against a throwaway defaults domain, then
  `defaults delete` it.
- Test `dot clone` and `dot fork` against a throwaway `CODE_DIR=$(mktemp -d)`,
  never ~/code.
- After an approved apply, `./dot check <file>` must be all ✓.
