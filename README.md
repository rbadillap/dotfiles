# dotfiles

My macOS setup as code, and the command I work with every day.

**The Mac.** Settings are declared in plain text:

    trackpad tap-to-click true
    dock visibility hidden
    system hostname $hostname

`dot check` shows what differs from the Mac, and `dot apply` fixes only
that. The engine is POSIX shell; settings use macOS's own tools, plus
Homebrew, mise, git, 1Password and `gh` where needed.

**The work.** `dot` stays after setup: `dot clone` puts every repository at
`~/code/<owner>/<repo>`, and `dot secret` keeps project secrets in 1Password,
attached to a project by reference, never as a value on disk.

`dot --help` lists every command. It's agent-friendly: agents check freely
and ask before applying (see [AGENTS.md](AGENTS.md)).

## Quick start

On a clean Mac (it shows its plan and asks before changing anything):

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"

Afterwards, in a new terminal:

    dot check    # what would change; changes nothing
    dot apply    # apply it

Step by step: **[docs/getting-started.md](docs/getting-started.md)**. Everything
else: [docs/](docs/README.md).

## License

[MIT](LICENSE): fork it and make it yours.
