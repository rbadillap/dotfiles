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

`./dot --help` (or `-h`, anywhere on the line) prints a short usage summary.

### Exit codes

| Code | Meaning                                              |
|------|------------------------------------------------------|
| `0`  | Everything matches (check) or was applied (apply)    |
| `1`  | Differences found, or a setting had an error         |
| `2`  | Bad usage (unknown command, option or theme), or `dot.conf` missing |

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

### 5.5 Identities per folder

Your global git identity (`git_name`, `git_email`) is the default. Repos under
a given folder can use another name and email, without configuring each
repo:

    # dot.conf
    site_dir=~/code/rbadillap/rbadillap
    site_git_name=Ronny Badilla
    site_git_email=info@ronnybadilla.com

    # config/git.sh
    git identity $site_dir $site_git_name $site_git_email

`./dot apply git` writes the name and email to
`~/.config/git/identities/<folder>` and tells git to include that file for
repos under the folder (git's `includeIf gitdir`). A repo cloned there later
picks it up automatically. To check which identity a repo uses:

    git -C <repo> var GIT_AUTHOR_IDENT

Signing keeps the same 1Password key, and the extra email is added to
`~/.config/git/allowed_signers`. For GitHub to show those commits as
*Verified*, the email must be verified on your GitHub account. Add one
`git identity` line per folder that needs its own identity.

## 6. Shell

zsh, with no framework, and the [Starship](https://starship.rs) prompt. zsh is
macOS's default shell, so there's nothing to install for it; Starship comes
from `config/packages.sh`.

    ./dot apply packages   # installs starship
    ./dot apply shell      # connects ~/.zshrc to this repo

**`~/.zshrc` stays yours.** Many tools (Homebrew, 1Password, version
managers) tell you to append a line to it, and they should be free to. So
this repo never owns or rewrites the file; `shell init zsh` only adds one
marked block that loads the repo's shell setup:

    # >>> dotfiles: managed by ./dot apply shell
    source "/Users/you/code/<owner>/dotfiles/shell/init.zsh"
    # <<< dotfiles

`./dot check shell` lists every other line in `~/.zshrc` as a note:

    ✓ shell init zsh
        · not from this repo: source /Users/you/.config/op/plugins.sh

A note never counts as a difference. It tells you something was added
outside the repo, so you can decide: move it into `shell/` to make it part of
the setup, or leave it.

**One file per topic** in `shell/`, loaded by `shell/init.zsh` in a fixed
order:

| File                | Does                                                 |
|---------------------|------------------------------------------------------|
| `shell/path.zsh`    | Homebrew: `PATH`, `MANPATH` and completions          |
| `shell/op.zsh`      | 1Password shell plugins (e.g. `gh` gets its token)   |
| `shell/editor.zsh`  | `EDITOR` and `VISUAL`, from git's `core.editor` (step 7) |
| `shell/prompt.zsh`  | Starship                                             |

Open a new terminal to see it. Personal customization (history, completion,
aliases) comes later, each as its own file.

**Symbols in the prompt.** Some of Starship's default symbols need a Nerd
Font. [Ghostty](https://ghostty.org), the terminal in `config/apps.sh`, ships
with JetBrains Mono and Nerd Font symbols built in, so it needs no setup.
Other apps (Terminal.app, editors) can use JetBrains Mono Nerd Font from
`config/fonts.sh`; pick it in their font settings.

## 7. Editor

Which editor you use is a personal value, in `dot.conf`:

    editor=zed          # zed, code, cursor, nvim, vim or nano

`./dot apply editor` sets git's `core.editor` to it (`zed --wait`: GUI editors
must wait until you close the file). The shell exports the same command as
`EDITOR` and `VISUAL` (`shell/editor.zsh` reads it from git), so tools that
open an editor all agree, from one source of truth.

Zed itself comes from `config/apps.sh`, and its settings live in this repo:

    ./dot apply zed     # ~/.config/zed/settings.json → home/.config/zed/settings.json

**Linked, not copied.** `~/.config/zed/settings.json` becomes a symlink to the
repo's file. When you change a setting in Zed, Zed writes it into the repo,
and `git diff` shows it: commit it to keep it, or discard it. If a settings
file already exists, `apply` keeps it as `settings.json.backup` rather than
overwriting it.

Keep the file plain JSON, without comments. Zed rewrites it on every change
and doesn't keep comments in place, so explanations belong in these docs.

**`home/` mirrors your home folder.** A file at `home/.config/zed/settings.json`
is linked to `~/.config/zed/settings.json`, so where a file goes is obvious
from its path. More apps (Ghostty, Starship…) will follow the same pattern.

## 8. Window tiling

On a 49" ultrawide, three columns work best. macOS tiles windows natively
(halves, quarters, fill, center) but has **no thirds**, so
[Rectangle](https://rectangleapp.com) does the tiling. It's open source, comes
from `config/apps.sh`, and its shortcuts are declared in `config/windows.sh`:

| Shortcut  | Window                  |
|-----------|-------------------------|
| `⌘⌥←`     | left third (33%)        |
| `⌘⌥↑`     | center third (33%)      |
| `⌘⌥→`     | right third (33%)       |
| `⌘⇧⌥←`    | left fourth (25%)       |
| `⌘⇧⌥↑`    | center half (50%)       |
| `⌘⇧⌥→`    | right fourth (25%)      |

    ./dot apply windows

It also turns off macOS's own tiling (`windows native-tiling false`), so the
two don't compete, and restarts Rectangle to load the shortcuts. Sizes are
fractions of the screen, so they work on any display.

**Manual, once per Mac:** Rectangle needs **Accessibility** permission to
move windows. Grant it when it asks, or in *System Settings → Privacy &
Security → Accessibility*. macOS doesn't allow scripts to grant it.

Note that `⌘⌥←/→` switches tabs in Chrome, Dia and Zed; Rectangle takes those
keys first.

**Why not macOS alone, or the Shortcuts app?** Both were tried. Native tiling
has no thirds. The Shortcuts app can resize and move windows, but each Mac
would need six shortcuts built or imported by hand, with fixed pixel sizes;
Rectangle needs one permission.

## What gets configured

| Topic      | Setting             | Values                              |
|------------|---------------------|-------------------------------------|
| `brew`     | `formula`           | a Homebrew formula (CLI tool), e.g. `gh` |
| `brew`     | `cask`              | a Homebrew cask (app or binary), e.g. `1password` |
| `dock`     | `visibility`        | `always`, `autohide`, `hidden`      |
| `editor`   | `default`           | `zed`, `code`, `cursor`, `nvim`, `vim`, `nano`; from `$editor` |
| `git`      | `name`              | any text, spaces allowed; from `$git_name` |
| `git`      | `email`             | an email address; from `$git_email` |
| `git`      | `signing-key`       | title of an SSH key in 1Password; from `$ssh_key` |
| `git`      | `identity`          | `<dir> <name> <email>`: identity for repos under `<dir>`; from `$site_*` |
| `github`   | `ssh-key`           | title of an SSH key in 1Password; added for auth and signing (needs `gh`) |
| `keyboard` | `repeat-rate`       | integer; lower is faster (UI minimum is 2) |
| `keyboard` | `repeat-delay`      | integer; lower is shorter (UI minimum is 15) |
| `mouse`    | `speed`             | `0.0`–`3.0`                         |
| `mouse`    | `secondary-click`   | `right`, `left`, `off`              |
| `mouse`    | `natural-scrolling` | `true`, `false`; also applies to the trackpad |
| `shell`    | `init`              | `zsh`: adds the managed block to `~/.zshrc` |
| `rectangle` | `shortcut`         | `<action> <combo>`, e.g. `first-third cmd+opt+left` (actions in `catalog/rectangle.sh`) |
| `ssh`      | `agent`             | `1password` |
| `system`   | `hostname`          | letters, digits, hyphens; sets all three macOS names (sudo) |
| `trackpad` | `speed`             | `0.0`–`3.0`                         |
| `trackpad` | `tap-to-click`      | `true`, `false`                     |
| `trackpad` | `three-finger-drag` | `true`, `false`                     |
| `windows`  | `native-tiling`     | `true`, `false`: macOS's own edge tiling |
| `zed`      | `settings`          | `linked`: symlink to `home/.config/zed/settings.json` |

My choices live in `config/<theme>.sh`. Change the values there, or delete a
line to leave that setting alone; a package whose line is removed stays
installed. A config file is named after its theme, not its topic:
`config/apps.sh` and `config/packages.sh` both hold `brew …` lines, and
`./dot check apps` checks only the first.

## Apps and packages

All are installed with Homebrew and split by what they are:

| File                  | Holds                          | Now                                  |
|-----------------------|--------------------------------|--------------------------------------|
| `config/apps.sh`      | Apps you open (casks)          | 1Password, Google Chrome, Dia, Ghostty, Zed, Discord, Slack, Rectangle |
| `config/fonts.sh`     | Fonts (casks)                  | JetBrains Mono Nerd Font             |
| `config/packages.sh`  | Command-line tools             | 1Password CLI (`op`), GitHub CLI (`gh`), Starship |

To add one, find its exact name with `brew search <name>`, then add a line:
`brew cask <name>` for an app or prebuilt binary, `brew formula <name>` for a
CLI tool. `./dot apply apps` (or `packages`, `fonts`) installs it. Removing
a line doesn't uninstall anything.

An app you already installed by hand is adopted instead of reinstalled
(`brew install --adopt`), as long as it's the same version. Adopting may ask
for your password, because Homebrew fixes the app's ownership.

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
  `gh`), plus `file` for managed blocks inside files and `link` for files
  linked from `home/`. It is the only code that reads or changes the system,
  and it's where check vs. apply happens.
- **home/** mirrors your home folder: its files are linked into `~` (step 7).
- **shell/** holds the zsh setup, one file per topic (step 6).
- **dot** is the CLI that ties them together. It only accepts settings
  defined in catalog/. Everything is POSIX shell plus tools that ship with
  macOS (and git, from the Command Line Tools), so it runs right after the
  installer, before anything else is installed.

To add a setting, write a function in `catalog/<topic>.sh`, then add its line
to `config/<theme>.sh`. New files are picked up automatically. AGENTS.md has
the exact conventions.
