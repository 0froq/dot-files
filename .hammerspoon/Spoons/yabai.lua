-- Spoon: yabai keybindings
local mash = { 'alt' }
local shift = { 'alt', 'shift' }

local function sh(cmd)
  hs.task.new('/bin/zsh', nil, { '-lc', cmd }):start()
end

-- Spaces: alt+q w f a r s -> 1..6; alt+shift+... moves window
local spaceKeys = { q = 1, w = 2, f = 3, a = 4, r = 5, s = 6 }
for key, num in pairs(spaceKeys) do
  hs.hotkey.bind(mash, key, function() sh(string.format('yabai -m space --focus %d', num)) end)
  hs.hotkey.bind(shift, key, function() sh(string.format('yabai -m window --space %d', num)) end)
end

-- Float and center window
hs.hotkey.bind(shift, 'return', function()
  sh('yabai -m window --toggle float --grid 16:16:1:1:14:14 --sub-layer below')
end)

-- Balance spaces
hs.hotkey.bind(shift, 'e', function() sh('yabai -m space --balance') end)

local directionMap = {
  h = 'west',
  j = 'south',
  k = 'north',
  l = 'east',
  left = 'west',
  down = 'south',
  up = 'north',
  right = 'east',
}

for key, dir in pairs(directionMap) do
  hs.hotkey.bind(mash, key, function() sh(string.format('yabai -m window --focus %s', dir)) end)
  hs.hotkey.bind(shift, key, function() sh(string.format('yabai -m window --warp %s', dir)) end)
end
