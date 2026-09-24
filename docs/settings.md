# Settings

Every setting `dot` knows. Values chosen for this Mac live in
`config/<theme>.sh`; change them there, or delete a line to leave that
setting alone. A config file is named after its theme and may mix topics
(`config/windows.sh` holds `rectangle …` and `windows …` lines).

| Topic       | Setting             | Values                                           |
|-------------|---------------------|--------------------------------------------------|
| `brew`      | `formula`           | a Homebrew formula (command-line tool), e.g. `gh` |
| `brew`      | `cask`              | a Homebrew cask (app, font or binary), e.g. `1password` |
| `backup`    | `dot-conf`          | `1password`: keep `dot.conf` in 1Password as a Document |
| `dock`      | `visibility`        | `always`, `autohide`, `hidden`                   |
| `editor`    | `default`           | `zed`, `code`, `cursor`, `nvim`, `vim`, `nano`; from `$editor` |
| `git`       | `name`              | any text; from `$git_name`                       |
| `git`       | `email`             | an email address; from `$git_email`              |
| `git`       | `signing-key`       | title of an SSH key in 1Password; from `$ssh_key` |
| `git`       | `identity`          | `<dir> <name> <email>`: identity for repos under `<dir>` |
| `github`    | `ssh-key`           | `<user> <title>`: an SSH key in 1Password, added to your account for authentication and signing; from `$github_user $ssh_key` |
| `keyboard`  | `repeat-rate`       | integer; lower is faster (System Settings stops at 2) |
| `keyboard`  | `repeat-delay`      | integer; lower is shorter (System Settings stops at 15) |
| `mouse`     | `speed`             | `0.0`–`3.0`                                      |
| `mouse`     | `secondary-click`   | `right`, `left`, `off`                           |
| `mouse`     | `natural-scrolling` | `true`, `false`; macOS applies it to the trackpad too |
| `rectangle` | `shortcut`          | `<action> <combo>`, e.g. `first-third cmd+opt+left`; actions in `catalog/rectangle.sh` |
| `shell`     | `init`              | `zsh`: the managed block in `~/.zshrc`           |
| `ssh`       | `agent`             | `1password`                                      |
| `system`    | `hostname`          | letters, digits, hyphens; sets all three macOS names (sudo) |
| `trackpad`  | `speed`             | `0.0`–`3.0`                                      |
| `trackpad`  | `tap-to-click`      | `true`, `false`                                  |
| `trackpad`  | `three-finger-drag` | `true`, `false`; moves three-finger swipes to four fingers |
| `windows`   | `native-tiling`     | `true`, `false`: macOS's own edge tiling         |
| `zed`       | `settings`          | `linked`: symlink to `home/.config/zed/settings.json` |

`$name` values come from `dot.conf`.

## Apps, fonts and command-line tools

All come from Homebrew:

| File                  | Holds                  | Installed                                          |
|-----------------------|------------------------|----------------------------------------------------|
| `config/apps.sh`      | apps                   | 1Password, Google Chrome, Dia, Ghostty, Zed, Discord, Slack, Rectangle |
| `config/fonts.sh`     | fonts                  | JetBrains Mono Nerd Font                           |
| `config/packages.sh`  | command-line tools     | 1Password CLI (`op`), GitHub CLI (`gh`), Starship  |

To add one, find its exact name with `brew search <name>` and add
`brew cask <name>` (apps, fonts, binaries) or `brew formula <name>`
(command-line tools) to the right file. Removing a line doesn't uninstall
anything. An app already installed by hand is adopted, as long as it's the
same version; adopting may ask for your password.
