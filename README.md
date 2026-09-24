# dotfiles

My macOS setup as code. Settings are declared in plain text:

    trackpad tap-to-click true
    dock visibility hidden
    system hostname $hostname

`./dot check` shows what differs from the Mac, and `./dot apply` fixes only
that. It uses only POSIX shell and tools that ship with macOS. It's
agent-friendly: agents check freely and ask before applying (see
[AGENTS.md](AGENTS.md)).

## Quick start

On a clean Mac (it shows its plan and asks before changing anything):

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"

Afterwards, from the repo:

    ./dot check    # what would change; changes nothing
    ./dot apply    # apply it

For details, see **[docs/getting-started.md](docs/getting-started.md)**.
