local icons = require('icons')
local colors = require('colors')
local settings = require('settings')
local Widget = require('helpers.widget')

local battery = Widget:new({
  name = 'widgets.battery',
  position = 'right',
  item = {
    icon = {
      font = {
        style = settings.font.style_map['Regular'],
        size = 14.0,
      },
      color = colors.white,
    },
    label = {
      font = { family = settings.font.numbers },
      color = colors.white,
    },
    update_freq = 180,
    popup = { align = 'center' },
    background = { color = colors.transparent }
  },
})

local remaining_time = sbar.add('item', {
  position = 'popup.' .. battery.name,
  icon = {
    string = 'Time remaining:',
    width = 100,
    align = 'left'
  },
  label = {
    string = '??:??h',
    width = 100,
    align = 'right'
  },
})

battery:subscribe({ 'routine', 'power_source_change', 'system_woke' }, function()
  sbar.exec('pmset -g batt', function(batt_info)
    local icon = '!'
    local label = '?'

    local found, _, charge = batt_info:find('(%d+)%%')
    if found then
      charge = tonumber(charge)
      label = charge .. '%'
    end

    local color = colors.emerald[2]
    local charging, _, _ = batt_info:find('AC Power')

    if charging then
      icon = icons.battery.charging
    else
      if found and charge > 80 then
        icon = icons.battery._100
      elseif found and charge > 60 then
        icon = icons.battery._75
      elseif found and charge > 40 then
        icon = icons.battery._50
      elseif found and charge > 20 then
        icon = icons.battery._25
        color = colors.amber[2]
      else
        icon = icons.battery._0
        color = colors.rose[2]
      end
    end

    local lead = ''
    if found and charge < 10 then
      lead = '0'
    end

    battery:set('main', {
      icon = {
        string = icon,
        color = color
      },
      label = { string = lead .. label },
    })
  end)
end)

battery:subscribe('mouse.clicked', function(env)
  local main_item = battery:get('main')
  local drawing = main_item:query().popup.drawing
  main_item:set({ popup = { drawing = 'toggle' } })

  if drawing == 'off' then
    sbar.exec('pmset -g batt', function(batt_info)
      local found, _, remaining = batt_info:find(' (%d+:%d+) remaining')
      local label = found and remaining .. 'h' or 'No estimate'
      remaining_time:set({ label = label })
    end)
  end
end)

return battery
