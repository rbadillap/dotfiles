# dot

Your Mac, as code. Set it up from plain text, keep it that way, and work on
your projects.

```sh
# config/dock.conf
dock visibility hidden

# config/trackpad.conf
trackpad tap-to-click true
```

`dot check` shows what differs from the Mac and changes nothing; `dot apply`
fixes only that. `dot clone` puts every repository at `~/code/<owner>/<repo>`,
and `dot secret` keeps project secrets in 1Password, never on disk. The
engine is POSIX shell plus the tools macOS already has, and it's built for
coding agents too ([AGENTS.md](AGENTS.md)).

## Install

Fork this repo, then on a clean Mac (it shows its plan and asks before
changing anything):

```sh
DOTFILES_REPO=<you>/dotfiles sh -c "$(curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/install.sh)"
```

Step by step: [Install](docs/02-get-started/01-install.mdx). Everything else:
[the docs](docs/index.mdx).

## License

[MIT](LICENSE): fork it and make it yours.
