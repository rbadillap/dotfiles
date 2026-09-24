# Window tiling

[Rectangle](https://rectangleapp.com) tiles windows in thirds and fourths,
which suits an ultrawide screen. It comes from `config/apps.sh`, and its
shortcuts are declared in `config/windows.sh`:

| Shortcut | Window             |
|----------|--------------------|
| `⌘⌥←`    | left third (33%)   |
| `⌘⌥↑`    | center third (33%) |
| `⌘⌥→`    | right third (33%)  |
| `⌘⇧⌥←`   | left fourth (25%)  |
| `⌘⇧⌥↑`   | center half (50%)  |
| `⌘⇧⌥→`   | right fourth (25%) |

    ./dot apply windows

This also turns off macOS's own edge tiling (`windows native-tiling false`),
so the two don't compete, and restarts Rectangle to load the shortcuts. Sizes
are fractions of the screen, so they work on any display.

**Once per Mac:** Rectangle needs **Accessibility** permission to move
windows. Grant it when it asks, or in *System Settings → Privacy & Security →
Accessibility*; macOS doesn't let scripts grant it.

`⌘⌥←` and `⌘⌥→` switch tabs in Chrome, Dia and Zed; Rectangle takes them
first.

## Changing shortcuts

    rectangle shortcut <action> <combo>

`<combo>` is modifiers and one key joined by `+`: modifiers `cmd`, `opt`,
`ctrl`, `shift`; keys `left`, `right`, `up`, `down`, `space`, `return`, or a
letter. The actions are listed in `catalog/rectangle.sh`.
