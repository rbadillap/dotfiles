# AWS

The `aws` CLI logs in through **IAM Identity Center** (SSO): the same login
as the AWS access portal in the browser, with your organization's identity
provider (Google Workspace, for example). There are no access keys: the CLI
gets temporary credentials for one account and role at a time.

## Requirements

- Your organization uses IAM Identity Center, and you can reach its access
  portal (a URL like `https://d-xxxxxxxxxx.awsapps.com/start`).
- The portal's region. In the portal, any account's **Access keys** window
  shows it as *SSO region*, next to the *SSO start URL*; you don't need the
  keys it offers.

## 1. Declare it in dot.toml (once, ever)

One table per organization. A profile is an account and the role (the
permission set) you use in it:

    [aws.work]                          # profile "work": view only
    start_url = "https://d-xxxxxxxxxx.awsapps.com/start"
    region = "us-west-2"
    account = "123456789012"
    role = "ViewOnlyAccess"

    [aws.work.admin]                    # profile "work-admin": same account
    role = "AdministratorAccess"

- **The organization's own profile** is named after it (`work`) and comes
  from `account` and `role` in its table. Make it the harmless one:
  `ViewOnlyAccess` shows what exists and how it's configured, without
  reading data or changing anything.
- **Each table under it** is a profile named `<org>-<name>` (`work-admin`),
  so changing things takes a name you type on purpose. It uses the
  organization's account and region unless it sets its own `account` or
  `region`, as another account in the organization would.

The accounts and roles you have are the ones the access portal lists.

## 2. Apply it

    dot apply aws

This installs the AWS CLI, links its aliases (below), and writes one managed
block to `~/.aws/config`: an `[sso-session work]` for the organization and a
`[profile …]` for each profile. Anything else in the file, such as profiles
a client gives you, is left alone. There's no default profile, so every
command names the account it acts on.

## 3. Log in (per session)

    aws sso login --sso-session work

It opens the browser: sign in with your identity provider if asked, then
approve the AWS CLI's request. The terminal continues on its own. One login
covers every profile of that organization.

## 4. Check it

    aws whoami --profile work

It prints the account and an `assumed-role/AWSReservedSSO_<role>_…` ARN.
`whoami` is an alias for `aws sts get-caller-identity`, from
`config/home/.aws/cli/alias`, which `dot apply aws` links to
`~/.aws/cli/alias`; add your own aliases there.
`dot auth status` does the same for each organization in `dot.toml`.

## Everyday use

    aws s3 ls --profile work            # one command
    export AWS_PROFILE=work             # or every command in this terminal
    aws s3 mb s3://new --profile work-admin   # a change takes the admin profile
    aws sso logout                      # end the session early

When the session expires, commands fail with a message to log in again: run
step 3.

## What stays on this Mac

| What                     | Where                 | Lasts                                          |
|--------------------------|-----------------------|------------------------------------------------|
| SSO session token        | `~/.aws/sso/cache/`   | the session: 8 hours by default, set in IAM Identity Center |
| Role credentials         | `~/.aws/cli/cache/`   | 1 hour, renewed from the session as needed     |

Both are plain files, readable by any program running as you while they
last. Nothing is permanent: `aws sso logout` or the session's end makes them
useless, and `~/.aws/credentials` isn't used.

## Friction

| Criterion        | IAM Identity Center                                    |
|------------------|--------------------------------------------------------|
| Manual steps     | the tables in `dot.toml` once; then one browser approval per session |
| Browser          | on every login                                         |
| 2FA              | your identity provider's, when it asks                 |
| Per machine      | the login; the config comes from `dot apply aws`       |
| Expires          | with the session (8 hours by default)                  |
| Secret on disk   | temporary: the session token and role credentials     |

## Another account, role or organization

- **Another role or account** in the same organization: another
  `[aws.<org>.<name>]` table (with its own `account` for another account),
  then `dot apply aws`. No new login.
- **Another organization:** another `[aws.<org>]` table with its profiles,
  then `dot apply aws` and its own `aws sso login --sso-session <org>`.
