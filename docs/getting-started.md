# Getting started

From a clean macOS install to a configured Mac. Each step links to its
topic for details.

## 1. Run the installer

Open Terminal and run:

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"

It prints a plan (each step, why it's needed, and whether it's already done)
and changes nothing until you confirm. Questions take a single keypress: `y`
or `n`, and Enter keeps the default. Then it:

1. **Installs Homebrew**, the package manager for everything else. It asks
   for your password once: Homebrew needs admin rights to create
   `/opt/homebrew`.
2. **Installs the Xcode Command Line Tools** (git, compilers, macOS SDK)
   through Homebrew's installer, without a GUI dialog. On a clean Mac,
   `/usr/bin/git` is only a stub that asks to install them.
3. **Clones this repo** over HTTPS into `~/code/rbadillap/dotfiles`. Repos live
   at `~/code/<owner>/<repo>`, mirroring GitHub. A fork sets
   `DOTFILES_REPO=<owner>/<repo>`.
4. **Creates `dot.conf`** (step 2), then runs `./dot check` and asks before
   `./dot apply` (step 3).

Every step is skipped when already done, so rerunning is safe; after a
failure, it says which step failed and a rerun continues from there.

| Option        | Does                                                   |
|---------------|--------------------------------------------------------|
| `--dry-run`   | shows the plan and exits                               |
| `--yes`       | no questions (also with `NONINTERACTIVE` or `CI`)      |
| `--no-apply`  | stops after `./dot check`                              |
| `--help`      | usage                                                  |

Pass options after `--`: `sh -c "$(curl …)" -- --dry-run`. An agent runs
`sh install.sh --yes --no-apply` and shows you the check before applying.
Only Apple Silicon Macs are supported, as with current Homebrew.

## 2. Personal values

Everything personal (hostname, git identity, editor…) lives in `dot.conf`,
which git ignores. The installer offers a short wizard that asks for each
value in `dot.conf.example`; Enter keeps the default. Otherwise:

    cp dot.conf.example dot.conf

One `name=value` per line, without quotes; values may contain spaces. Lines
starting with `#` are comments. `dot` won't run without this file.

Keep a copy somewhere safe (planned: 1Password): it isn't in git.

## 3. Check, then apply

    ./dot check    # what differs from config/; changes nothing
    ./dot apply    # fix only what differs

See [dot.md](dot.md) for the output, narrower runs and exit codes, and
[settings.md](settings.md) for everything that gets configured.

## 4. 1Password and GitHub

Sign in to 1Password, turn on its SSH agent, create an SSH key, log in to
GitHub, and turn on signed commits: [1password.md](1password.md), then
[auth/github.md](auth/github.md).

## 5. Manual steps

macOS doesn't let scripts do these:

- [ ] **Log out and back in** after keyboard or trackpad changes (`apply`
      reminds you).
- [ ] **Default browser:** accept the browser's "make default" prompt, or pick
      it in *System Settings → Desktop & Dock → Default web browser*.
- [ ] **Rectangle:** grant Accessibility permission when it asks, or in
      *System Settings → Privacy & Security → Accessibility*
      ([windows.md](windows.md)).
- [ ] **1Password:** sign in and turn on the developer features
      ([1password.md](1password.md)).

## 6. Open a new terminal

Ghostty (from `config/apps.sh`) with zsh and Starship: [shell.md](shell.md).
Your editor is set too: [editor.md](editor.md).
