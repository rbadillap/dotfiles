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
- **Default browser.** macOS always asks you to confirm this, so it can't be
  set from the command line. Open the browser you want (Chrome or Dia) and
  accept its "make default" prompt, or pick it in *System Settings → Desktop
  & Dock → Default web browser*.

## 5. 1Password

1Password holds every secret this setup needs: SSH keys, API keys, and later
the backup of `dot.conf`. Nothing secret is ever written to this repo or to
disk. The same SSH key is used for two things:

- **Authentication**: `git push` to GitHub. 1Password's SSH agent serves the
  key when needed, after Touch ID, and the private key never leaves 1Password.
- **Commit signing**: GitHub shows your commits as *Verified*.

`./dot apply` already installed the app (`1password`, from `config/apps.sh`)
and the CLI (`op`, from `config/packages.sh`). The steps below are manual
because they involve your account.

### 5.1 Sign in

Open 1Password from Applications and sign in to your account.

### 5.2 Turn on the developer features

In 1Password, open **Settings → Developer** and turn on:

- **Use the SSH agent**, so SSH and git can use keys stored in 1Password.
- **Integrate with 1Password CLI**, so `op` works with the app's session and
  asks for Touch ID instead of a password.

If 1Password offers to update `~/.ssh/config` for the agent, either answer is
fine: step 5.4 adds the same block if it's missing.

To check that both work:

    op vault list                   # asks for Touch ID, then lists your vaults
    ls ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

The second command must print the path, not "No such file". That file is the
SSH agent's socket.

### 5.3 Create an SSH key

Use **Ed25519**: it's the modern key type GitHub recommends, short and fast.
Save it in your **Personal** vault. By default, 1Password's SSH agent only
offers keys from the Personal (or Private) vault, so a key saved elsewhere
won't work for `git push`.

Either way below works, and the key is generated inside 1Password:

- **In the app:** *+ New Item → SSH Key → Add Private Key → Generate a New
  Key → Ed25519*, in the Personal vault. Title it `GitHub`.
- **From the terminal:**

      op item create --vault Personal --category "SSH Key" --title "GitHub" --ssh-generate-key ed25519

A clean Mac has no key to reuse, and creating a new one per machine is
fine: GitHub accepts several, and removing one later doesn't affect the
others.

### 5.4 Use the key for GitHub

First log in to GitHub from the terminal: follow
[docs/auth/github.md](auth/github.md). Logins have their own guides, one per
platform, because every account-based CLI needs one ([docs/auth](auth/README.md)).

Then tell `dot` which key to use. In `dot.conf`, `ssh_key` is the **title**
of the SSH key item in 1Password:

    ssh_key=GitHub

and apply the three settings that use it:

    ./dot apply ssh       # ssh agent 1password: SSH gets keys from 1Password
    ./dot apply git       # git signing-key: sign every commit and tag
    ./dot apply github    # github ssh-key: add the key to your GitHub account

What each one does:

- **`ssh agent 1password`** adds a `Host *` block to `~/.ssh/config`
  pointing at 1Password's agent. If 1Password already wrote it when you
  turned the agent on, it's left as is. Only that block is managed; anything
  else in the file stays yours.
- **`git signing-key GitHub`** configures git to sign commits and tags with
  that key through 1Password (`op-ssh-sign`), and writes
  `~/.config/git/allowed_signers` so git can verify signatures locally.
- **`github ssh-key GitHub`** uploads the public key to your account twice:
  as an **authentication** key (for `git push`) and as a **signing** key (so
  commits show *Verified*). On GitHub it's titled after the hostname,
  e.g. `ronny (1Password)`.

The public key is read from 1Password's agent, so `./dot check` doesn't ask
for Touch ID. Signing a commit does, and so does anything that calls GitHub
through `gh`.

To confirm it all works:

    ssh -T git@github.com                 # "Hi <you>! You've successfully authenticated"
    git commit --allow-empty -m test      # in a throwaway repo; Touch ID, then:
    git log --show-signature -1           # Good "git" signature for <your email>

Commits made before this step aren't signed. If they haven't been pushed,
re-sign them with `git rebase --root --force-rebase` (one Touch ID per
commit, unless 1Password remembers the approval).

## What gets configured

| Topic      | Setting             | Values                              |
|------------|---------------------|-------------------------------------|
| `brew`     | `formula`           | a Homebrew formula (CLI tool), e.g. `gh` |
| `brew`     | `cask`              | a Homebrew cask (app or binary), e.g. `1password` |
| `dock`     | `visibility`        | `always`, `autohide`, `hidden`      |
| `git`      | `name`              | any text, spaces allowed; from `$git_name` |
| `git`      | `email`             | an email address; from `$git_email` |
| `git`      | `signing-key`       | title of an SSH key in 1Password; from `$ssh_key` |
| `github`   | `ssh-key`           | title of an SSH key in 1Password; added for auth and signing (needs `gh`) |
| `keyboard` | `repeat-rate`       | integer; lower is faster (UI minimum is 2) |
| `keyboard` | `repeat-delay`      | integer; lower is shorter (UI minimum is 15) |
| `mouse`    | `speed`             | `0.0`–`3.0`                         |
| `mouse`    | `secondary-click`   | `right`, `left`, `off`              |
| `mouse`    | `natural-scrolling` | `true`, `false`; also applies to the trackpad |
| `ssh`      | `agent`             | `1password` |
| `system`   | `hostname`          | letters, digits, hyphens; sets all three macOS names (sudo) |
| `trackpad` | `speed`             | `0.0`–`3.0`                         |
| `trackpad` | `tap-to-click`      | `true`, `false`                     |
| `trackpad` | `three-finger-drag` | `true`, `false`                     |

My choices live in `config/<theme>.sh`. Change the values there, or delete a
line to leave that setting alone; a package whose line is removed stays
installed. A config file is named after its theme, not its topic:
`config/apps.sh` and `config/packages.sh` both hold `brew …` lines, and
`./dot check apps` checks only the first.

## Apps and packages

Both are installed with Homebrew and split by what they are:

| File                  | Holds                          | Now                                  |
|-----------------------|--------------------------------|--------------------------------------|
| `config/apps.sh`      | Apps you open (casks)          | 1Password, Google Chrome, Dia        |
| `config/packages.sh`  | Command-line tools             | 1Password CLI (`op`), GitHub CLI (`gh`) |

To add one, find its exact name with `brew search <name>`, then add a line:
`brew cask <name>` for an app or prebuilt binary, `brew formula <name>` for a
CLI tool. `./dot apply apps` or `./dot apply packages` installs it. Removing
a line doesn't uninstall anything.

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
- **lib/** has one file per tool (`defaults`, `scutil`, `git`, `brew`, `ssh`,
  `gh`, plus `file` for managed blocks inside files). It is the only
  code that reads or changes the system, and it's where check vs. apply
  happens.
- **dot** is the CLI that ties them together. It only accepts settings
  defined in catalog/. Everything is POSIX shell plus tools that ship with
  macOS (and git, from the Command Line Tools), so it runs right after the
  installer, before anything else is installed.

To add a setting, write a function in `catalog/<topic>.sh`, then add its line
to `config/<theme>.sh`. New files are picked up automatically. AGENTS.md has
the exact conventions.
