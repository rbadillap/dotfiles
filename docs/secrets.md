# Secrets in projects

App secrets (API keys, database URLs…) live in 1Password, and
[Varlock](https://varlock.dev) hands them to a project when it runs. No secret
is written to a `.env` file or exported in the shell.

    dot apply packages    # installs Varlock (from the dmno-dev/tap Homebrew tap)

`config/shell/varlock.zsh` adds its completion, and `dot doctor` checks it's
installed.

## How a project uses it

A project commits a `.env.schema`: which variables exist, their types, and
where each value comes from. Secrets are references to 1Password, not values:

    # @plugin(@varlock/1password-plugin)
    # @initOp(allowAppAuth=forEnv(dev))
    # ---
    # @sensitive
    STRIPE_KEY=op(op://Dev/stripe-test/credential)
    APP_URL=http://localhost:3000

The 1Password plugin's options are in
[varlock.dev/plugins/1password](https://varlock.dev/plugins/1password/). Then:

    varlock load                  # validate the schema and show what resolves
    varlock run -- pnpm dev       # run with the values injected

- **Only that process gets the secrets.** `varlock run` resolves the values
  (1Password asks for Touch ID) and injects them into the command it starts;
  your shell never has them. For shells and agents, `--inject vars` passes
  plain variables only.
- **Sensitive values are redacted** in output that's piped, such as logs.
- **Next.js** has a native integration (`@varlock/nextjs-integration`) that
  validates env at build time and keeps sensitive values out of client code:
  [varlock.dev/integrations/nextjs](https://varlock.dev/integrations/nextjs/).
- **Cache:** resolved values can be cached in `~/.config/varlock/cache/`,
  encrypted with a Secure Enclave key that needs Touch ID.

Local overrides (`.env.local`, `.env.*.local`) belong in each project's
`.gitignore`.

## Telemetry

Varlock sends anonymous usage analytics unless they're turned off. Here that's a
personal value in `dot.conf`:

    varlock_telemetry=disable    # or enable

`config/varlock.conf` applies it (`varlock telemetry $varlock_telemetry`).
`DO_NOT_TRACK=1` also turns it off for a single run.

## Where each secret lives

| Secret                              | Lives in   | Reaches its user through             |
|-------------------------------------|------------|--------------------------------------|
| App secrets (API keys, DB URLs)     | 1Password  | Varlock, per process                 |
| GitHub token for `gh`               | 1Password  | the `gh` shell plugin, per command ([auth/github.md](auth/github.md)) |
| SSH key                             | 1Password  | the SSH agent ([1password.md](1password.md)) |
| `dot.conf` backup                   | 1Password  | `dot conf restore`                   |
