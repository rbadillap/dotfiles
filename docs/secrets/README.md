# Secrets in projects

App secrets (API keys, database URLs…) live in 1Password, and
[Varlock](https://varlock.dev) hands them to a project when it runs. No secret
is written to a `.env` file or exported in the shell.

    dot apply packages    # installs Varlock (from the dmno-dev/tap Homebrew tap)

`config/shell/varlock.zsh` adds its completion, and `dot doctor` checks it's
installed.

## Adding a secret to a project

Project secrets live in a 1Password vault kept for development secrets,
apart from your logins; `dot.toml` names it:

    [secrets]
    vault = "Dev"

A project never stores a value: its `.env.schema` holds a reference, and
Varlock resolves it when the project runs. Which secrets a project needs,
and with what permissions, is the project's own documentation.

### 1. Create it with the least it needs

Give each secret only what its job requires, and one secret per job, so
revoking one breaks nothing else. A job that only reads gets a read-only
token, never one that can also write; a test environment gets a test key.
Creating one usually happens in the provider's website; each provider's
guide below has the exact steps.

### 2. Store it with `dot secret`

    dot secret add myapp-payments     # name it <project>-<use>

It asks for the value without showing it, stores it in the vault as an API
Credential tagged `dotfiles`, and prints its reference,
`op://Dev/myapp-payments/credential`. The value never becomes a command
argument or a file, so it's not in your shell history or the process list.

    dot secret list                   # names, dates and references; never values
    dot secret update myapp-payments  # a new value, same reference

### 3. Attach it to the project

A project commits a `.env.schema`: which variables exist, their types, and
where each value comes from. `varlock init` creates it, and its header loads
the 1Password plugin. Then, from the project's folder:

    dot secret attach myapp-payments PAYMENTS_KEY

This adds the variable as a reference, never a value:

    # @plugin(@varlock/1password-plugin)
    # @initOp(allowAppAuth=forEnv(dev))
    # ---
    APP_URL=http://localhost:3000

    # @sensitive
    PAYMENTS_KEY=op(op://Dev/myapp-payments/credential)

A reference is `op://<vault>/<item>/<field>`. `dot secret attach` refuses a
variable the schema already has, and a schema without the plugin.

### 4. Run with it

    varlock explain PAYMENTS_KEY  # how one variable resolves, without its value
    varlock load                  # validate the schema and show what resolves
    varlock run -- pnpm dev       # run a command with the values injected

A Next.js project uses Varlock's integration instead
(`@varlock/nextjs-integration`), so `next dev` and `next build` load the
schema themselves.

Local overrides (`.env.local`, `.env.*.local`) belong in each project's
`.gitignore`, and never hold a secret: that's what the schema is for.

## Providers

Creating a secret is the manual part: providers make you do it in their
website, often with 2FA. Each guide measures it with the criteria of
[auth/](../auth/README.md).

| Provider                 | Friction                                          |
|--------------------------|---------------------------------------------------|
| [GitHub](github.md)      | a browser visit per token; nothing per Mac        |

## At runtime

- **Only that process gets the secrets.** `varlock run` resolves the values
  (1Password asks for Touch ID) and injects them into the command it starts;
  your shell never has them. For shells and agents, `--inject vars` passes
  plain variables only.
- **Sensitive values are redacted** in output that's piped, such as logs.
- **Next.js:** the integration validates the environment at build time and
  keeps sensitive values out of client code.
- **Cache:** resolved values can be cached in `~/.config/varlock/cache/`,
  encrypted with a Secure Enclave key that needs Touch ID.

## Telemetry

Varlock sends anonymous usage analytics unless they're turned off. Here that's a
personal value in `dot.toml`:

    [varlock]
    telemetry = "disable"    # or "enable"

`config/varlock.conf` applies it (`varlock telemetry $varlock.telemetry`).
`DO_NOT_TRACK=1` also turns it off for a single run.

## Where each secret lives

| Secret                              | Lives in   | Reaches its user through             |
|-------------------------------------|------------|--------------------------------------|
| App secrets (API keys, DB URLs)     | 1Password, development vault | Varlock, per process |
| GitHub token for `gh`               | 1Password  | the `gh` shell plugin, per command ([auth/github.md](../auth/github.md)) |
| Vercel token for `vercel`           | 1Password  | the `vercel` shell plugin, per command ([auth/vercel.md](../auth/vercel.md)) |
| SSH key                             | 1Password  | the SSH agent ([1password.md](../1password.md)) |
| `dot.toml` backup                   | 1Password  | `dot conf restore`                   |

## Further reading

| Link | For |
|------|-----|
| [Varlock: introduction](https://varlock.dev/getting-started/introduction/) | what Varlock is and how to start |
| [@env-spec](https://varlock.dev/env-spec/overview/) | the `.env.schema` format |
| [Root decorators](https://varlock.dev/reference/root-decorators/) and [item decorators](https://varlock.dev/reference/item-decorators/) | `@plugin`, `@initOp`, `@sensitive`, `@required`… |
| [1Password plugin](https://varlock.dev/plugins/1password/) | `op()` and its options |
| [Next.js integration](https://varlock.dev/integrations/nextjs/) | `next dev` and `next build` with Varlock |
| [1Password secret references](https://developer.1password.com/docs/cli/secret-reference-syntax/) | the `op://vault/item/field` syntax |
| [1Password service accounts](https://developer.1password.com/docs/service-accounts/) | secrets without Touch ID, for a job that runs unattended on a server |
