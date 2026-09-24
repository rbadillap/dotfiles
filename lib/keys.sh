# Keyboard combos such as cmd+shift+opt+left. Sourced by dot.

# key_combo <combo>: sets KEY_CODE and KEY_FLAGS (macOS virtual key code and
# modifier flags) for apps that store shortcuts that way. A helper, not a
# check; returns 1 on an invalid combo.
key_combo() {
  KEY_CODE= KEY_FLAGS=0
  for part in $(printf %s "$1" | tr + ' '); do
    case $part in
      cmd)   KEY_FLAGS=$((KEY_FLAGS + 1048576)) ;;
      opt)   KEY_FLAGS=$((KEY_FLAGS + 524288)) ;;
      ctrl)  KEY_FLAGS=$((KEY_FLAGS + 262144)) ;;
      shift) KEY_FLAGS=$((KEY_FLAGS + 131072)) ;;
      *)
        [ -z "$KEY_CODE" ] || return 1   # one key only
        case $part in
          left) KEY_CODE=123 ;; right) KEY_CODE=124 ;; down) KEY_CODE=125 ;; up) KEY_CODE=126 ;;
          return|enter) KEY_CODE=36 ;; space) KEY_CODE=49 ;;
          a) KEY_CODE=0 ;; s) KEY_CODE=1 ;; d) KEY_CODE=2 ;; f) KEY_CODE=3 ;; h) KEY_CODE=4 ;;
          g) KEY_CODE=5 ;; z) KEY_CODE=6 ;; x) KEY_CODE=7 ;; c) KEY_CODE=8 ;; v) KEY_CODE=9 ;;
          b) KEY_CODE=11 ;; q) KEY_CODE=12 ;; w) KEY_CODE=13 ;; e) KEY_CODE=14 ;; r) KEY_CODE=15 ;;
          y) KEY_CODE=16 ;; t) KEY_CODE=17 ;; o) KEY_CODE=31 ;; u) KEY_CODE=32 ;; i) KEY_CODE=34 ;;
          p) KEY_CODE=35 ;; l) KEY_CODE=37 ;; j) KEY_CODE=38 ;; k) KEY_CODE=40 ;; n) KEY_CODE=45 ;;
          m) KEY_CODE=46 ;;
          *) return 1 ;;
        esac ;;
    esac
  done
  [ -n "$KEY_CODE" ] && [ "$KEY_FLAGS" -gt 0 ]
}
