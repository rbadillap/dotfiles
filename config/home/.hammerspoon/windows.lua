-- Window tiling: each shortcut puts the focused window in a range of its
-- screen's width. The shortcuts and ranges come from ~/.hammerspoon/tiles,
-- which dot writes from `hammerspoon tile` lines in config/windows.conf:
-- one "<combo> <from> <to>" per line (cmd+shift+opt+left 0 30), in percent.

hs.window.animationDuration = 0

local mods = { cmd = "cmd", opt = "alt", ctrl = "ctrl", shift = "shift" }

local function tile(combo, from, to)
  local parts = {}
  for part in combo:gmatch("[^+]+") do table.insert(parts, mods[part] or part) end
  local key = table.remove(parts)
  hs.hotkey.bind(parts, key, function()
    local win = hs.window.focusedWindow()
    if win then win:moveToUnit(hs.geometry.rect(from / 100, 0, (to - from) / 100, 1)) end
  end)
end

local file = io.open(hs.configdir .. "/tiles")
if not file then
  print("windows: no ~/.hammerspoon/tiles; run dot apply windows")
  return
end
for line in file:lines() do
  local combo, from, to = line:match("^(%S+) (%d+) (%d+)$")
  if combo then tile(combo, tonumber(from), tonumber(to)) end
end
file:close()
