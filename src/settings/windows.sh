# macOS's own window tiling.

# windows native-tiling <true|false>   macOS tiles windows dragged to a screen
# edge (sides, top, or anywhere while holding Option). Off when Rectangle does
# the tiling: it turns these off itself on first launch, and declaring them
# makes a new Mac match without that prompt.
windows_native_tiling() {
  default com.apple.WindowManager EnableTilingByEdgeDrag -bool "$1"
  default com.apple.WindowManager EnableTopTilingByEdgeDrag -bool "$1"
  default com.apple.WindowManager EnableTilingOptionAccelerator -bool "$1"
}
