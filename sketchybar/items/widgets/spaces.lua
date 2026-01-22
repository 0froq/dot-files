local colors = require('colors')
local settings = require('settings')

local space_colors = {
  colors.coral[2],
  colors.teal[2],
  colors.azure[2],
  colors.cyan[2],
  colors.amber[2],
  colors.indigo[2],
  colors.mauve[2],
  colors.plum[2],
  colors.iris[2],
  colors.emerald[2]
}

local current_space = sbar.add('item', 'current_space', {
  icon = {
    font = { family = settings.font.numbers },
    string = '1',
    padding_left = 10,
    padding_right = 10,
    color = colors.white,
  },
  label = {
    drawing = false,
  },
  padding_right = 6,
  padding_left = 6,
  background = {
    color = colors.coral[2],
    border_width = 0,
    height = 24,
    corner_radius = 1,
  },
})

local function update_space_color()
  sbar.exec("yabai -m query --spaces --space | jq -r '.index'", function(result)
    local space_id = tonumber(result)
    if space_id then
      local space_bg_color = space_colors[space_id] or colors.grey

      current_space:set({
        icon = { string = tostring(space_id) },
        background = { color = space_bg_color }
      })
    end
  end)
end

current_space:subscribe('space_change', update_space_color)
current_space:subscribe('forced', update_space_color)

update_space_color()

local space_window_observer = sbar.add('item', {
  drawing = false,
  updates = true,
})
