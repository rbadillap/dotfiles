# GitHub

`gh`, the GitHub CLI, needs a login to call GitHub's API: creating repos,
opening pull requests, adding SSH keys. `git push` and `git pull` don't use
it; they go over SSH with the key from 1Password ([1password.md](../1password.md)).

This guide uses the **token in 1Password** way. The interactive alternative
is at the end, for comparison.

## Requirements

1Password with **Integrate with 1Password CLI** turned on
([1password.md](../1password.md), step 2).

## 1. Install the CLI

    dot apply packages    # installs what's missing: here, gh

This installs `gh` and `op`, from `config/packages.conf`; what's already
installed stays as it is. `op plugin init gh` only works once `gh` exists.

## 2. Create a token (once, ever)

GitHub offers two kinds of personal access token. Pick one:

| Kind              | Creating it                         | Access                   |
|-------------------|-------------------------------------|--------------------------|
| **Fine-grained**  | GitHub's default; permissions picked one by one | Only what you grant |
| **Classic**       | One pre-filled link, below          | Broad scopes             |

Both need GitHub's 2FA when you create them. Either way, copy the token at
the end: it's shown only once, and the next step stores it.

### Fine-grained (what GitHub offers by default)

Open <https://github.com/settings/personal-access-tokens/new>:

- **Name:** `gh CLI (1Password)`
- **Expiration:** your choice. A date means rotating the token when it
  expires (see *Renewing*).
- **Repository access:** *All repositories*.
- **Repository permissions:** set these to *Read and write*:
  - *Administration* (create repos)
  - *Contents*
  - *Issues*
  - *Pull requests*
  - *Workflows*

  *Metadata* becomes *Read-only* automatically.
- **Account permissions:** set these to *Read and write*. Without them,
  `dot apply github` fails with HTTP 403:
  - *Git SSH keys* (upload your SSH key for authentication)
  - *SSH signing keys* (upload it for commit signing)

Picking permissions one by one is where most of the time goes.

### Classic (fastest)

This link opens the form with the name and every scope already filled in;
just pick an expiration and generate:

<https://github.com/settings/tokens/new?description=gh%20CLI%20(1Password)&scopes=repo,read:org,workflow,gist,admin:public_key,admin:ssh_signing_key>

| Scope                   | Why                                             |
|-------------------------|-------------------------------------------------|
| `repo`                  | Work with your repositories, including private ones |
| `read:org`              | Read organizations; `gh` expects it             |
| `workflow`              | Edit GitHub Actions workflows                   |
| `gist`                  | Create gists                                    |
| `admin:public_key`      | Add your SSH key for authentication             |
| `admin:ssh_signing_key` | Add your SSH key for commit signing             |

## 3. Connect it to gh (once per Mac)

    op plugin init gh

It asks three things:

1. **Credential:** choose *Import into 1Password*, paste the token, and save
   it in your built-in personal vault (Personal, or Private on business
   accounts). On a later Mac, choose the item that already exists instead.
2. **Scope:** choose *Use as global default on my system*, so `gh` uses this
   token everywhere. It's the third option: the list starts on *Prompt me
   for each new terminal session*, so move down before pressing Enter.
3. It finishes by printing a command to run, like this one:

       echo "source /Users/you/.config/op/plugins.sh" >> ~/.zshrc && source ~/.zshrc

   Run it, or skip it if you use this repo's shell setup (see step 4).

## 4. Activate the plugin in your shell (once per Mac)

The plugin works by making `gh` an alias that goes through 1Password. That
alias lives in `~/.config/op/plugins.sh`, and the command above does two
things:

- It adds a line to `~/.zshrc` that loads the alias in every new terminal.
  On a clean Mac this creates `~/.zshrc`.
- It runs `source ~/.zshrc`, so the terminal you're in has the alias right
  away.

With this repo's shell setup ([shell.md](../shell.md)) the command isn't
needed: `config/shell/op.zsh` already loads `plugins.sh`. Running it anyway is
harmless; `dot check shell` then lists that line as a note, and you can
delete it from `~/.zshrc`.

Then add the `dotfiles` tag, keeping the one `op` added:

    op item edit "GitHub Personal Access Token" --tags "1Password Shell Plugins,dotfiles"

## 5. Check it

    gh auth status

It asks for Touch ID, then shows you logged in to github.com with the token
from `GH_TOKEN`. That variable is set by the plugin for that single command;
nothing is written to disk.

## Friction

| Criterion        | Token in 1Password                          | Interactive login |
|------------------|---------------------------------------------|-------------------|
| Time             | ~10 min to create the token (fine-grained); per Mac: not measured | not measured |
| Browser          | once, to create the token                   | on every Mac      |
| 2FA              | once, when creating the token               | on every Mac, if asked |
| Per machine      | `op plugin init gh` (the shell line comes from `dot apply shell`) | the whole login   |
| Expires          | as set when creating the token              | no                |
| Secret on disk   | no                                          | in the macOS Keychain |

The token is created once; each later Mac repeats steps 1 and 3–5.

## Renewing

If the token has an expiration date, GitHub emails you before it expires.
Regenerate it on GitHub, then replace the value in the 1Password item. Every
Mac picks up the new value on its next `gh` command.

## Alternative: interactive login

    gh auth login --hostname github.com --git-protocol ssh --web

It shows a one-time code and opens the browser, where you paste it and
authorize. The token is stored in the macOS Keychain, and this has to be
repeated on every Mac.
