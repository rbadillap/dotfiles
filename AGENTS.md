# AGENTS.md

macOS setup as code: `config/` declares settings, `./dot check|apply` compares
them with the machine and fixes differences. Human docs: README.md (entry
point) and docs/getting-started.md (the full guide).

## Rules

- Run `./dot check` freely: it never changes anything.
- Ask before `./dot apply`, before anything that uses sudo, and before any
  other command that changes the machine.
- Never commit `dot.conf`, secrets, or machine-specific values.
- Everything in this repo is written in English.
- Keep it minimal: add files and folders only when needed. Update README.md
  and this file in the same change as the structure they describe.
- README.md stays short: what this is and where to go. Details belong in
  docs/getting-started.md.
- Record every step taken on a clean machine in docs/getting-started.md.

## Where things go

| Task                              | Location                                   |
|-----------------------------------|--------------------------------------------|
| Change a preference               | `config/<topic>.sh`                        |
| Add a setting                     | function in `catalog/<topic>.sh`, line in `config/<topic>.sh`, row in the "What gets configured" table of docs/getting-started.md |
| Add a personal value (names, …)   | `dot.conf` (real) and `dot.conf.example` (placeholder) |
| Support a new macOS tool          | new `lib/<tool>.sh`                        |
| Document a clean-machine step     | `docs/getting-started.md`                  |
| Change what happens before the repo exists | `install.sh` |

New files in `config/`, `catalog/` and `lib/` are picked up automatically.

## Layers

**config/<topic>.sh** holds data and is never executed.
- One `<topic> <setting> <value>` per line, with no verbs. Lines starting
  with `#` are comments.
- Values are split on spaces.
- A whole word `$name` is replaced by `name` from `dot.conf`. Personal values
  always go through `dot.conf`, never literally in config/ or catalog/.

**catalog/<topic>.sh** holds one function per setting, named
`<topic>_<setting>()` (hyphens become underscores).
- A comment above each function gives its syntax and accepted values.
- Validate input and call `fail "<message>"; return` on bad values.
- Call lib functions; never touch the system directly.
- After the lib calls, declare effects:
  - `restart <app>` is done automatically at the end of apply.
  - `effect "<step>"` is reported to the user (e.g. log out).
  - Both are no-ops unless the setting actually changed something.

**lib/<tool>.sh** is the only code that reads or changes the system.
- Each function reads the current value and returns 0 if it matches.
- Otherwise, in apply mode it changes it and sets `DOT_CHANGED=1`. In both
  modes it calls `changed "<what>" "<from>" "<to>" [note]`.
- Mark sudo with the note `sudo` and in the function's comment.
- Never print directly; use lib/output.sh.
- Current functions:
  - `default` / `default_unset` in defaults.sh
  - `scutil_name` in scutil.sh (sudo)
  - `gitconfig` in gitconfig.sh (global ~/.gitconfig)

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
- Test it with `sh install.sh --dry-run`, and `HOME=$(mktemp -d)` to simulate
  a clean machine.

## Verify

- `sh -n <file>` for every changed script. Scripts are POSIX sh.
- `./dot check <topic>` exits 0 when the machine matches, 1 on differences
  or errors, and 2 on bad usage or a missing `dot.conf`.
- To test an apply path without touching real settings, source the libs in a
  subshell with `DOT_MODE=apply` against a throwaway defaults domain, then
  `defaults delete` it.
- After an approved apply, `./dot check <topic>` must be all ✓.
