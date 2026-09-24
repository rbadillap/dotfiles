# GitHub

`gh`, the GitHub CLI, needs a login to call GitHub's API: creating repos,
opening pull requests, adding SSH keys. `git push` and `git pull` don't use
it; they go over SSH with the key from 1Password (getting-started, step 5).

This guide uses the **token in 1Password** way. The interactive alternative
is at the end, for comparison.

## Requirements

- 1Password with **Integrate with 1Password CLI** turned on
  (getting-started, step 5.2).
- `gh` and `op` installed; `./dot apply packages` does it.

## 1. Create a token (once, ever)

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
  `./dot apply github` fails with HTTP 403:
  - *Git SSH keys* (upload your SSH key for authentication)
  - *SSH signing keys* (upload it for commit signing)

Picking permissions one by one is where most of the time goes (see
*Friction*).

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

## 2. Connect it to gh (once per Mac)

    op plugin init gh

It asks three things:

1. **Credential:** choose *Import into 1Password*, paste the token, and save
   it in the **Personal** vault. On a later Mac, choose the item that
   already exists instead.
2. **Scope:** choose *Use as global default on my system*, so `gh` uses this
   token everywhere.
3. It finishes by printing a command to run, like this one:

       echo "source /Users/you/.config/op/plugins.sh" >> ~/.zshrc && source ~/.zshrc

   Run it; that's step 3.

## 3. Activate the plugin in your shell (once per Mac)

The plugin works by making `gh` an alias that goes through 1Password. That
alias lives in `~/.config/op/plugins.sh`, and the command above does two
things:

- It adds a line to `~/.zshrc` that loads the alias in every new terminal.
  On a clean Mac this creates `~/.zshrc`.
- It runs `source ~/.zshrc`, so the terminal you're in has the alias right
  away.

> Temporary: once the shell setup is part of this repo, `./dot apply` will
> add that line, and this step goes away.

## 4. Check it

    gh auth status

It asks for Touch ID, then shows you logged in to github.com with the token
from `GH_TOKEN`. That variable is set by the plugin for that single command;
nothing is written to disk.

## Friction

Measured on the first Mac (2026-09-23), with a fine-grained token: **about 10
minutes**, 2FA included. Almost all of it was picking permissions by hand in
the browser. The pre-filled classic link above should cut that part to a
minute or two, but that hasn't been measured yet.

| Criterion        | Token in 1Password                          | Interactive login |
|------------------|---------------------------------------------|-------------------|
| Time             | ~10 min the first time; per Mac: not yet measured | not measured |
| Browser          | once, to create the token                   | on every Mac      |
| 2FA              | once, when creating the token               | on every Mac, if asked |
| Per machine      | `op plugin init gh` + the shell line        | the whole login   |
| Expires          | as set when creating the token              | no                |
| Secret on disk   | no                                          | in the macOS Keychain |

The first-time cost is paid once; from then on each Mac only repeats
steps 2–4. That per-Mac time is what matters most, and it gets measured on
the next machine.

## Renewing

If the token has an expiration date, GitHub emails you before it expires.
Regenerate it on GitHub, then replace the value in the 1Password item. Every
Mac picks up the new value on its next `gh` command.

## Alternative: interactive login

    gh auth login --hostname github.com --git-protocol ssh --web

It shows a one-time code and opens the browser, where you paste it and
authorize. The token is stored in the macOS Keychain, and this has to be
repeated on every Mac.
