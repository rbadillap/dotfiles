# Getting started

This guide takes a Mac from a clean install to a configured machine. It
records every step, including the ones that can't be automated, with the
reason for each decision. It is written as the setup happens, so it only
covers what exists so far.

## 0. Run the installer

On a clean Mac, open Terminal and run:

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"

It first prints a plan: each step, why it's needed, and whether it's already
done. Nothing changes until you confirm. To only see the plan:

    sh -c "$(curl -fsSL …/install.sh)" -- --dry-run

Then it:

1. **Installs Homebrew**, the package manager for everything else. It asks for
   your password once, because Homebrew needs admin rights to create
   `/opt/homebrew`.
2. **Installs the Xcode Command Line Tools (CLT)**. Homebrew's official
   installer adds them, without the usual GUI dialog. They provide git,
   compilers and the macOS SDK. A clean macOS has none of these: `/usr/bin/git`
   is only a stub that opens an install dialog.
3. **Clones this repo** into `~/code/rbadillap/dotfiles` (see step 1).
4. **Creates `dot.conf`** with your personal values (see step 2), then runs
   `./dot check` and asks before `./dot apply` (see step 3).

Every step is skipped when it's already done, so rerunning is safe. If
something fails, the installer says which step, and rerunning continues from
there. Questions take a single keypress (`y` or `n`; Enter keeps the default).

Options: `--dry-run`, `--yes` (no questions, e.g. in CI), `--no-apply` (stop
after `./dot check`), `--help`. An agent runs it as
`sh install.sh --yes --no-apply`, then shows you the check before applying.
Without a terminal, `dot` and the installer print plain text without colors.

**Why let Homebrew install the CLT?** The alternative is running
`xcode-select --install` first. That's one more step, and it opens a dialog
that can't be automated. Homebrew's installer does the same thing unattended,
and it is Homebrew's documented behavior, not a workaround.

**Git.** The CLT ship Apple's git, which is a few versions behind. A newer git
will come from Homebrew later. It takes precedence because `/opt/homebrew/bin`
comes before `/usr/bin` in `PATH`. Apple's copy can't be removed; it's
protected by the system.

**Intel Macs** aren't supported: current Homebrew only runs on Apple Silicon.

## 1. Get the repo

The installer clones the repo over HTTPS, since a clean Mac has no SSH key
yet. If the repo is already there, it runs `git pull` instead.

> Not yet verified end to end: the repo isn't published on GitHub yet.

Repos live at `~/code/<owner>/<repo>`, mirroring GitHub, with no exceptions.
This one goes in `~/code/rbadillap/dotfiles`. A fork can use its own with
`DOTFILES_REPO=<owner>/<repo>`.

## 2. Personal values

Everything personal, such as the hostname, lives in `dot.conf`. That file is
ignored by git, so a public repo never carries anyone's details.

The installer offers a short wizard: it asks for each value in
`dot.conf.example`, and Enter keeps the default. If you decline, create it
from the template and edit it yourself:

    cp dot.conf.example dot.conf

The format is `name=value`, one per line, without quotes. Values may contain
spaces (`git_name=Your Name`). Lines starting with `#` are comments. `dot`
stops with an error if the file is missing.

**Backup.** Because `dot.conf` isn't in git, keep a copy elsewhere (planned:
1Password). Without it you'd have to recreate it by hand on a new Mac.

## 3. Check, then apply

First see what differs. `check` never changes anything:

    ./dot check

    ✓ dock visibility hidden
    ~ keyboard repeat-rate 2
        NSGlobalDomain KeyRepeat: 5 → 2
    ~ system hostname ronny
        ComputerName: Ronny’s MacBook Pro → ronny  (sudo)
        ...

- `✓` means the setting already matches.
- `~` means it differs; the indented lines show each underlying value and
  what it would become.
- `(sudo)` marks changes that need your password.

Then apply:

    ./dot apply

`apply` changes only what differs, so running it again is safe. At the end
it:
- restarts apps that need it, such as the Dock;
- lists steps it can't do for you:

      To take effect:
        - log out and back in (keyboard repeat)

Run `./dot check` again afterwards; everything should show `✓`.

### Narrower runs

    ./dot check trackpad                   # one topic: config/trackpad.sh
    ./dot apply trackpad
    ./dot check keyboard repeat-rate 1     # one setting, not saved anywhere
    ./dot apply keyboard repeat-rate 1

The single-setting form is for trying something live. If you like it, copy
the same line (`keyboard repeat-rate 1`) into `config/keyboard.sh`. If you
don't, apply the old value again.

### Exit codes

| Code | Meaning                                              |
|------|------------------------------------------------------|
| `0`  | Everything matches (check) or was applied (apply)    |
| `1`  | Differences found, or a setting had an error         |
| `2`  | Bad usage, unknown topic, or `dot.conf` missing      |

## 4. Manual steps

Some things can't be set from the command line, or only take effect after a
manual action:

- **Log out and back in** after changing keyboard or trackpad settings.
  `apply` reminds you.
- **Three-finger drag** moves the three-finger swipe gestures (switching
  desktops, Mission Control) to four fingers, just as System Settings does.

## What gets configured

| Topic      | Setting             | Values                              |
|------------|---------------------|-------------------------------------|
| `dock`     | `visibility`        | `always`, `autohide`, `hidden`      |
| `git`      | `name`              | any text, spaces allowed; from `$git_name` |
| `git`      | `email`             | an email address; from `$git_email` |
| `keyboard` | `repeat-rate`       | integer; lower is faster (UI minimum is 2) |
| `keyboard` | `repeat-delay`      | integer; lower is shorter (UI minimum is 15) |
| `mouse`    | `speed`             | `0.0`–`3.0`                         |
| `mouse`    | `secondary-click`   | `right`, `left`, `off`              |
| `mouse`    | `natural-scrolling` | `true`, `false`; also applies to the trackpad |
| `system`   | `hostname`          | letters, digits, hyphens; sets all three macOS names (sudo) |
| `trackpad` | `speed`             | `0.0`–`3.0`                         |
| `trackpad` | `tap-to-click`      | `true`, `false`                     |
| `trackpad` | `three-finger-drag` | `true`, `false`                     |

My choices live in `config/<topic>.sh`. Change the values there, or delete a
line to leave that setting alone.

## How it works

Each setting passes through three layers:

    config/trackpad.sh     trackpad tap-to-click true           what you want
            ↓
    catalog/trackpad.sh    trackpad_tap_to_click()              what it means
            ↓
    lib/defaults.sh        default <domain> <key> <type> <val>  how macOS does it

- **config/** is data, never executed: one `<topic> <setting> <value>` per
  line. A word like `$hostname` is replaced by its value from `dot.conf`.
- **catalog/** has one function per setting. It validates the value and
  expands it into what macOS actually needs. For example, tap-to-click is
  three keys: built-in trackpad, Bluetooth trackpad and a per-host global.
- **lib/** has one file per tool (`defaults`, `scutil`, `git`). It is the only
  code that reads or changes the system, and it's where check vs. apply
  happens.
- **dot** is the CLI that ties them together. It only accepts settings
  defined in catalog/. Everything is POSIX shell plus tools that ship with
  macOS (and git, from the Command Line Tools), so it runs right after the
  installer, before anything else is installed.

To add a setting, write a function in `catalog/<topic>.sh`, then add its line
to `config/<topic>.sh`. New files are picked up automatically. AGENTS.md has
the exact conventions.
