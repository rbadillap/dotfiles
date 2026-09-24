# Varlock settings (https://varlock.dev). Installed from config/packages.conf.

# varlock telemetry <enable|disable>   Varlock's anonymous usage analytics
varlock_telemetry() {
  case $1 in
    enable|disable) varlock_telemetry_state "$1" ;;
    *) fail "varlock telemetry: expected enable or disable, got '$1'" ;;
  esac
}
