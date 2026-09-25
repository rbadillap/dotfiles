# Using dot

`dot` is the only command. Everything this repo does is a subcommand:

    dot <command> [<subcommand>] [flags]

| Command            | Does                                                        |
|--------------------|-------------------------------------------------------------|
| `dot check`        | compares the Mac with `config/`; changes nothing            |
| `dot apply`        | fixes every difference, or tries one setting live           |
| `dot explain`      | explains the settings you can use in `config/`              |
| `dot clone`        | clones a GitHub repo into `~/code/<owner>/<repo>`           |
| `dot fork`         | forks a GitHub repo and clones it with an `upstream` remote |
| `dot cd`           | goes to the dotfiles repo                                   |
| `dot conf`         | backs up, restores or edits `dot.toml` with 1Password       |
| `dot doctor`       | checks that dot's own requirements are in place             |
| `dot update`       | pulls the latest dotfiles, then runs `dot check`            |
| `dot auth status`  | shows which logins work: 1Password, GitHub, SSH, Vercel, AWS |
| `dot init zsh`     | prints the zsh setup that `~/.zshrc` loads                  |
| `dot completion zsh` | prints the zsh completion script                          |

`dot --help` lists them, `dot <command> --help` (or `dot help <command>`)
explains one, and a typo gets a suggestion. Completion covers commands,
config files, settings and their values: `dot apply dock visibility <Tab>`
offers `always autohide hidden`.

Once the shell is set up ([shell.md](shell.md)), `dot` works from any folder.
Before that, or from scripts, run it by path: `~/code/<owner>/dotfiles/bin/dot`.

## check and apply

    dot check                           # everything in config/; changes nothing
    dot apply                           # fix every difference
    dot check dock                      # one file: config/dock.conf
    dot apply keyboard repeat-rate 1    # one setting, not saved anywhere

    ✓ dock visibility hidden
    ~ keyboard repeat-rate 2
        NSGlobalDomain KeyRepeat: 5 → 2
    ~ system hostname ronny
        ComputerName: Ronny’s MacBook Pro → ronny  (sudo)
    ✓ shell init zsh
        · not from this repo: source ~/.config/op/plugins.sh
    ! mouse secondary-click: expected right, left or off, got 'middle'

| Mark     | Meaning                                                          |
|----------|------------------------------------------------------------------|
| `✓`      | matches                                                          |
| `~`      | differs; each indented line is an underlying value and its target |
| `→`      | changed by `apply`                                               |
| `!`      | error: an invalid value or a failed step; nothing changed for it |
| `·`      | a note: information only, never a difference                     |
| `(sudo)` | needs your password; `apply` asks for it                         |

`check` never changes anything and never asks for a password or Touch ID.
`apply` changes only what differs, so running it twice is safe; at the end it
restarts apps that need it and lists anything left for you, such as logging
out.

To try a setting, apply it alone: `dot apply keyboard repeat-rate 1`. To keep
it, add the same line to a file in `config/`.

## explain

    dot explain                       # every setting, with values and where config/ uses it
    dot explain trackpad              # one topic
    dot explain dock visibility       # one setting
    dot explain brew cask ghostty     # one line

The more you give, the more it says. Given a whole line, it shows that line
in `config/` with the comment above it, and what the line refers to on this
Mac; for a package, its description, version, and whether it's installed:

    brew cask <name>
        an app, font or prebuilt binary, e.g. 1password

        in config/apps.conf:
          # Terminal.
          brew cask ghostty

        ghostty: Terminal emulator that uses platform-native UI and GPU acceleration
          https://ghostty.org/
          version 1.3.1, installed 1.3.1

A line that isn't in `config/` yet is explained too, with a reminder to add
it. `explain` changes nothing.

## clone and fork

    dot clone vercel/next.js                   # ~/code/vercel/next.js
    dot clone https://github.com/shadcn-ui/ui  # URLs work too
    dot fork vercel/next.js                    # your fork in ~/code/<you>/next.js

- **clone** accepts `owner/repo` and any GitHub URL form (`https://`, `git@`,
  `ssh://`, with `.git`, `/tree/…`, `?…` or `#…`); other hosts are refused.
  It clones over SSH with your 1Password key, uses GitHub's spelling of the
  name, and only prints the path if the repo is already there. It never
  overwrites a folder holding something else, and a failed clone leaves
  nothing behind.
- **fork** forks the repo to your account, or reuses your fork (even one
  GitHub renamed), clones it, and adds the original as `upstream`. Forking
  your own repo just clones it. Your username comes from `user` under
  `[github]` in `dot.toml`.

In zsh, both take you to the repo, as does `dot cd`. For scripts, the only
thing on stdout is the path: `dir=$(dot clone vercel/next.js)`.

## conf

    dot conf edit       # open dot.toml in your editor
    dot conf backup     # save it to 1Password
    dot conf restore    # get it back from 1Password

See [1password.md](1password.md#backup-of-dottoml).

## doctor, update and auth

- **`dot doctor`** checks what `dot` itself needs: Command Line Tools,
  Homebrew, 1Password and its CLI and SSH agent, `gh`, Varlock, `dot.toml`
  (errors, and values missing from it), and the shell setup. Each problem comes
  with its fix. No Touch ID.
- **`dot update`** fast-forwards the repo from GitHub, then runs `dot check`
  to show what the new version would change. It never applies.
- **`dot auth status`** checks each login this setup uses: the 1Password CLI,
  `gh`, SSH to GitHub, `vercel`, and each AWS organization in `dot.toml`. It
  asks for Touch ID. See [auth/](auth/README.md).

## Exit codes

| Code | Meaning                                                            |
|------|--------------------------------------------------------------------|
| `0`  | success: everything matches, applied, cloned                       |
| `1`  | differences found, or something failed                             |
| `2`  | bad usage: unknown command, flag or file, or `dot.toml` missing or invalid |

Messages go to stderr and results to stdout. Without a terminal (agents,
logs) output is plain text; `NO_COLOR` turns colors off too.
