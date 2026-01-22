local icons = require('icons')
local colors = require('colors')
local settings = require('settings')
local Widget = require('helpers.widget')

sbar.exec('killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0')

local cpu = Widget:new({
  name = 'widgets.cpu',
  position = 'right',
  item = {
    type = 'graph',
    graph_width = 42,
    graph = { color = colors.azure[2] },
    background = {
      height = 22,
      color = colors.transparent,
      border_width = 0,
    },
    icon = {
      string = icons.cpu,
      color = colors.white,
    },
    label = {
      string = 'CPU ??%',
      color = colors.white,
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map['Bold'],
        size = 11.0,
      },
      align = 'right',
      padding_right = 0,
      width = 10,
      y_offset = 4
    },
    padding_right = settings.paddings + 6
  },
})

cpu:subscribe('cpu_update', function(env)
  local load = tonumber(env.total_load)
  local main_item = cpu:get('main')
  main_item:push({ load / 100. })

  local color = colors.azure[2]
  if load > 30 then
    if load < 60 then
      color = colors.amber[2]
    elseif load < 80 then
      color = colors.coral[2]
    else
      color = colors.rose[2]
    end
  end

  cpu:set('main', {
    graph = { color = color },
    label = 'CPU ' .. env.total_load .. '%',
  })
end)

cpu:subscribe('mouse.clicked', function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

return cpu
