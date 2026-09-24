# Authentication

Every CLI that talks to an account (GitHub, Vercel, Cloudflare, AWS…) needs
a login, and on a new Mac all of them need it again. Each platform has its own
guide here, with how much manual work its login takes.

## Two ways to log in

- **Interactive login.** The CLI's own flow (`gh auth login`, `vercel login`…).
  It usually opens a browser, sometimes asks for 2FA, and stores a token on
  this Mac. It has to be repeated on every Mac.
- **Token in 1Password.** You create a token once and store it in
  1Password. A [1Password Shell Plugin](https://www.1password.dev/cli/shell-plugins/)
  then hands it to the CLI on each command, after Touch ID. On a new Mac you
  only point the plugin at the existing item; there's no browser and no
  token saved on disk.

## Friction

Each platform guide measures both ways with the same criteria:

| Criterion        | Question                                              |
|------------------|-------------------------------------------------------|
| Manual steps     | How many actions does it take from you?               |
| Browser          | Does it open a browser to authorize?                  |
| 2FA              | Does it ask for a second factor?                      |
| Per machine      | Must it be repeated on every Mac?                     |
| Expires          | Does the credential expire and need renewing?         |
| Secret on disk   | Is a token left in a file on this Mac?                |

| Platform                 | Interactive login | Token in 1Password |
|--------------------------|-------------------|--------------------|
| [GitHub](github.md)      | not measured      | ~10 min once (2FA, fine-grained token); per Mac: not measured |
