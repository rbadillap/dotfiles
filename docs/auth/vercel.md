# Vercel

`vercel`, the Vercel CLI, needs a login to reach your projects: deployments,
their logs, environment variables and domains.

This guide uses the **token in 1Password** way. The interactive alternative
is at the end, for comparison.

## Requirements

1Password with **Integrate with 1Password CLI** turned on
([1password.md](../1password.md), step 2).

## 1. Install the CLI

    dot apply packages    # installs what's missing: here, vercel

This installs `vercel` and `op`, from `config/packages.conf`; what's already
installed stays as it is. The next steps
need both: `op plugin init vercel` only works once `vercel` exists.

## 2. Create a token (once, ever)

Open <https://vercel.com/account/settings/tokens> and create one:

- **Token name:** `vercel CLI (1Password)`
- **Scope:** the team your projects live in. A token reaches only its scope,
  so if your projects are spread across teams, choose your full account.
- **Expiration:** your choice. A date means rotating the token when it
  expires (see *Renewing*).

Copy the token at the end: it's shown only once, and the next step stores
it.

## 3. Connect it to vercel (once per Mac)

    op plugin init vercel

It asks three things:

1. **Credential:** choose *Import into 1Password*, paste the token, and save
   it in your built-in personal vault (Personal, or Private on business
   accounts). On a later Mac, choose the item that already exists instead.
2. **Scope:** choose *Use as global default on my system*, so `vercel` uses
   this token everywhere. It's the third option: the list starts on *Prompt
   me for each new terminal session*, so move down before pressing Enter.
3. It finishes by printing a command that adds a line to `~/.zshrc`. Skip it:
   `config/shell/op.zsh` already loads the plugins ([shell.md](../shell.md)).
   Open a new terminal instead, so the plugin is active.

If you choose another scope, 1Password saves the token but `vercel` doesn't
use it outside that scope, and `vercel whoami` answers "Logged out". Run
`op plugin init vercel` again, pick the existing item, and choose the global
default.

Then add the `dotfiles` tag to the item it created, "Vercel API Token",
keeping the tag `op` added:

    op item edit "Vercel API Token" --tags "1Password Shell Plugins,dotfiles"

## 4. Check it

    vercel whoami

It asks for Touch ID, then prints your Vercel username. The plugin passes the
token with `--token` for that single command; nothing is written to disk.
`dot auth status` checks it too.

If the CLI offers to upgrade itself, answer no: Homebrew installed it, so
`brew upgrade vercel` updates it once the formula has the new version.

## Friction

| Criterion        | Token in 1Password                          | Interactive login |
|------------------|---------------------------------------------|-------------------|
| Time             | a few minutes to create the token; per Mac: under a minute (`op plugin init` took 36 s) | not measured |
| Browser          | once, to create the token                   | on every Mac      |
| 2FA              | once, when creating the token, if asked     | on every Mac, if asked |
| Per machine      | `op plugin init vercel` (the shell line comes from `dot apply shell`) | the whole login   |
| Expires          | as set when creating the token              | when Vercel ends the session |
| Secret on disk   | no                                          | yes, in the CLI's config folder |

The token is created once; each later Mac repeats steps 1, 3 and 4.

## Renewing

If the token has an expiration date, Vercel emails you before it expires.
Create a new one, then replace the value in the 1Password item. Every Mac
picks up the new value on its next `vercel` command.

## Alternative: interactive login

    vercel login

It opens the browser to authorize this Mac, then stores a token in the
CLI's config folder, in plain text. It has to be repeated on every Mac.
