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
failure, it says which step failed and a rerun continues from there. If
something seems off later, `dot doctor` says what's missing and how to fix it.

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
which git ignores. The installer offers three ways to create it:

- **`r` restore from 1Password:** installs 1Password, waits while you sign in
  and turn on *Settings → Developer → Integrate with 1Password CLI*, then
  downloads your backup ([1password.md](1password.md#backup-of-dotconf)).
- **`w` wizard:** asks for each value in `dot.conf.example`; Enter keeps the
  default.
- **`m` by hand:** `cp dot.conf.example dot.conf`, then edit it.

Later, `dot conf restore` gets the backup and `dot conf edit` opens the file
([dot.md](dot.md#conf)).
One `name=value` per line, without quotes; values may contain spaces. Lines
starting with `#` are comments. `dot` won't run without this file.

## 3. Check, then apply

From the repo:

    ./dot check    # what differs from config/; changes nothing
    ./dot apply    # fix only what differs

See [dot.md](dot.md) for the output and exit codes, and
[settings.md](settings.md) for everything that gets configured.

## 4. Open a new terminal

Ghostty (from `config/apps.conf`) with zsh and Starship: [shell.md](shell.md).
From now on `dot` works from any folder, with completion ([dot.md](dot.md)),
and your editor is set ([editor.md](editor.md)). Node, pnpm and Bun are ready, with
the right versions in each project ([runtimes.md](runtimes.md)).

## 5. 1Password and GitHub

Sign in to 1Password, turn on its SSH agent, create an SSH key, log in to
GitHub, and turn on signed commits: [1password.md](1password.md), then
[auth/github.md](auth/github.md). `dot auth status` confirms every login
works.

## 6. Manual steps

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
