# AWS settings.

# aws sso <table>   profiles in ~/.aws/config for IAM Identity Center (SSO).
# Each table under <table> in dot.toml is an organization, with start_url and
# region, and each table under it a profile, with account, role and
# optionally region: $aws.* reads [aws.<org>] and [aws.<org>.<profile>], and
# the profile is named <org>-<profile>. Kept in one managed block of
# ~/.aws/config; the rest of the file is left alone. No default profile.
aws_sso() {
  [ $# -eq 1 ] || { fail "aws sso: expected a table, such as \$aws.*"; return; }
  [ -n "$(conf_tables "$1")" ] || { note "no [$1.*] tables in dot.toml"; return 0; }
  block=
  for org in $(conf_tables "$1"); do
    url=$(conf_get "$1.$org.start_url") && region=$(conf_get "$1.$org.region") ||
      { fail "aws sso: [$1.$org] needs start_url and region"; return; }
    case $url in https://?*) ;; *) fail "aws sso: [$1.$org] start_url must start with https://"; return ;; esac
    case $region in [a-z][a-z]-*-[0-9]|[a-z][a-z]-*-[0-9][0-9]) ;; *) fail "aws sso: [$1.$org] not a region: '$region'"; return ;; esac
    block="$block
[sso-session $org]
sso_start_url = $url
sso_region = $region
sso_registration_scopes = sso:account:access
"
    for profile in $(conf_tables "$1.$org"); do
      at="[$1.$org.$profile]"
      account=$(conf_get "$1.$org.$profile.account") && role=$(conf_get "$1.$org.$profile.role") ||
        { fail "aws sso: $at needs account and role"; return; }
      case $account in *[!0-9]*|'') fail "aws sso: $at account must be a 12-digit ID"; return ;; esac
      [ ${#account} -eq 12 ] || { fail "aws sso: $at account must be a 12-digit ID"; return; }
      profile_region=$(conf_get "$1.$org.$profile.region") || profile_region=$region
      case $profile_region in [a-z][a-z]-*-[0-9]|[a-z][a-z]-*-[0-9][0-9]) ;; *) fail "aws sso: $at not a region: '$profile_region'"; return ;; esac
      block="$block
[profile $org-$profile]
sso_session = $org
sso_account_id = $account
sso_role_name = $role
region = $profile_region
"
    done
  done
  file_managed_block "$HOME/.aws/config" 600 "# >>> dotfiles: managed by dot apply aws$block# <<< dotfiles"
}

# aws aliases <linked>   ~/.aws/cli/alias is a link to this repo's
# config/home/.aws/cli/alias: shortcuts such as aws whoami
aws_aliases() {
  [ "$1" = linked ] || { fail "aws aliases: only 'linked' is supported, got '$1'"; return; }
  link config/home/.aws/cli/alias "$HOME/.aws/cli/alias"
}
