# Settings

Every setting `dot` knows; `dot explain` prints the same list from the code,
with what `config/` sets. Your values live in `config/*.conf`: change them
there, or delete a line to leave that setting alone. A file can mix topics
(`config/windows.conf` holds `rectangle …` and `windows …` lines).

| Topic       | Setting             | Values                                           |
|-------------|---------------------|--------------------------------------------------|
| `aws`       | `aliases`           | `linked`: symlink to `config/home/.aws/cli/alias` (`aws whoami`) |
| `aws`       | `sso`               | profiles in `~/.aws/config` for IAM Identity Center; from `$aws.*` ([auth/aws.md](auth/aws.md)) |
| `brew`      | `formula`           | a Homebrew formula (command-line tool), e.g. `gh` |
| `brew`      | `cask`              | a Homebrew cask (app, font or binary), e.g. `1password` |
| `brew`      | `tap`               | `owner/repo`: a third-party package source, trusted explicitly |
| `dock`      | `visibility`        | `always`, `autohide`, `hidden`                   |
| `editor`    | `default`           | `zed`, `code`, `cursor`, `nvim`, `vim`, `nano`; from `$editor` |
| `git`       | `name`              | any text; from `$git.name`                       |
| `git`       | `email`             | an email address; from `$git.email`              |
| `git`       | `signing-key`       | title of an SSH key in 1Password; from `$ssh_key` |
| `git`       | `identity`          | `<dir> <name> <email>`: name and email for repos under `<dir>` |
| `git`       | `identities`        | one `git identity` per table; from `$git.identity.*` ([1password.md](1password.md#identities-per-folder)) |
| `github`    | `ssh-key`           | `<user> <title>`: an SSH key in 1Password, added to your account for authentication and signing; from `$github.user $ssh_key` |
| `keyboard`  | `repeat-rate`       | integer; lower is faster (System Settings stops at 2) |
| `keyboard`  | `repeat-delay`      | integer; lower is shorter (System Settings stops at 15) |
| `mise`      | `config`            | `linked`: symlink to `config/home/.config/mise/config.toml` |
| `mise`      | `tools`             | `installed`: every tool in the global mise config |
| `mouse`     | `speed`             | `0.0`–`3.0`                                      |
| `mouse`     | `secondary-click`   | `right`, `left`, `off`                           |
| `mouse`     | `natural-scrolling` | `true`, `false`; macOS applies it to the trackpad too |
| `rectangle` | `shortcut`          | `<action> <combo>`, e.g. `first-third cmd+opt+left`; actions in `src/settings/rectangle.sh` |
| `screenshot` | `save-to`         | `clipboard`, `desktop` (macOS default), `preview`: where ⌘⇧3 and ⌘⇧4 send it |
| `shell`     | `init`              | `zsh`: the managed block in `~/.zshrc`           |
| `ssh`       | `agent`             | `1password`                                      |
| `system`    | `hostname`          | letters, digits, hyphens; sets all three macOS names (sudo) |
| `varlock`   | `telemetry`         | `enable`, `disable`: Varlock's usage analytics; from `$varlock.telemetry` |
| `trackpad`  | `speed`             | `0.0`–`3.0`                                      |
| `trackpad`  | `tap-to-click`      | `true`, `false`                                  |
| `trackpad`  | `three-finger-drag` | `true`, `false`; moves three-finger swipes to four fingers |
| `windows`   | `native-tiling`     | `true`, `false`: macOS's own edge tiling         |
| `zed`       | `settings`          | `linked`: symlink to `config/home/.config/zed/settings.json` |

`$…` values come from `dot.toml` ([how-it-works.md](how-it-works.md#personal-values)).

## Apps, fonts and command-line tools

All come from Homebrew:

| File                  | Holds                  | Installed                                          |
|-----------------------|------------------------|----------------------------------------------------|
| `config/apps.conf`      | apps                   | 1Password, Google Chrome, Dia, Ghostty, Zed, Discord, Slack, Rectangle |
| `config/fonts.conf`     | fonts                  | JetBrains Mono Nerd Font                           |
| `config/packages.conf`  | command-line tools     | 1Password CLI (`op`), GitHub CLI (`gh`), Starship, Varlock ([secrets.md](secrets.md)), Vercel CLI ([auth/vercel.md](auth/vercel.md)) |
| `config/mise.conf`      | languages and runtimes | mise; through it Node 24, pnpm, Bun, Python 3.13, uv ([runtimes.md](runtimes.md)) |
| `config/aws.conf`       | cloud                  | AWS CLI, with its SSO profiles ([auth/aws.md](auth/aws.md)) |

To add one, find its exact name with `brew search <name>` and add
`brew cask <name>` (apps, fonts, binaries) or `brew formula <name>`
(command-line tools) to the right file. Removing a line doesn't uninstall
anything. An app already installed by hand is adopted, as long as it's the
same version; adopting may ask for your password.

`dot explain brew cask <name>` shows what a package is, its version, and
whether it's installed.
