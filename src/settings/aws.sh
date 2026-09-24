# AWS settings.

# aws sso <table>   profiles in ~/.aws/config for IAM Identity Center (SSO).
# Each table under <table> in dot.toml is an organization, with start_url and
# region: $aws.* reads [aws.<org>]. With account and role, it's also a profile
# named <org>. Each table under it, [aws.<org>.<name>], is a profile named
# <org>-<name>, with role, and account and region unless it takes the
# organization's. Kept in one managed block of ~/.aws/config; the rest of the
# file is left alone. No default profile.
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
    # Profiles as "<table>=<name>": the organization's own, if it has a role,
    # then one per table under it.
    org_account=$(conf_get "$1.$org.account") || org_account=
    profiles=
    conf_get "$1.$org.role" >/dev/null && profiles="$1.$org=$org"
    for name in $(conf_tables "$1.$org"); do profiles="$profiles $1.$org.$name=$org-$name"; done
    for entry in $profiles; do
      table=${entry%%=*} profile=${entry#*=} at="[${entry%%=*}]"
      role=$(conf_get "$table.role") || { fail "aws sso: $at needs a role"; return; }
      account=$(conf_get "$table.account") || account=$org_account
      if [ -z "$account" ]; then
        if [ "$profile" = "$org" ]; then fail "aws sso: $at needs an account"; else fail "aws sso: $at needs an account, or [$1.$org] one"; fi
        return
      fi
      case $account in *[!0-9]*) fail "aws sso: $at account must be a 12-digit ID"; return ;; esac
      [ ${#account} -eq 12 ] || { fail "aws sso: $at account must be a 12-digit ID"; return; }
      profile_region=$(conf_get "$table.region") || profile_region=$region
      case $profile_region in [a-z][a-z]-*-[0-9]|[a-z][a-z]-*-[0-9][0-9]) ;; *) fail "aws sso: $at not a region: '$profile_region'"; return ;; esac
      block="$block
[profile $profile]
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
