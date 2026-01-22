local colors = require('colors')
local settings = require('settings')
local app_icons = require('helpers.app_icons')

local space_apps = {}
local current_front_app = nil

local function clear_apps()
  for app_name, item in pairs(space_apps) do
    if item and item.name then
      sbar.remove(item.name)
    end
  end
  space_apps = {}
end

local function update_apps()
  sbar.exec("yabai -m query --windows --space | jq -r '.[].app' | sort -u", function(result)
    if not result or result == '' then
      clear_apps()
      return
    end

    sbar.exec("yabai -m query --windows --window | jq -r '.app'", function(front_app)
      current_front_app = front_app:gsub('%s+$', '')

      local apps_list = {}
      for app_name in result:gmatch('[^\r\n]+') do
        app_name = app_name:gsub('%s+$', '')
        if app_name ~= '' then
          table.insert(apps_list, app_name)
        end
      end

      clear_apps()

      for _, app_name in ipairs(apps_list) do
        local icon = app_icons[app_name] or app_icons['default']
        local item_name = 'space.app.' .. app_name:gsub('[%s%.]', '_')
        local is_front = (app_name == current_front_app)

        local item = sbar.add('item', item_name, {
          icon = {
            string = icon,
            font = 'sketchybar-app-font:Regular:16.0',
            color = is_front and colors.white or colors.soft_500,
            padding_left = 4,
            padding_right = 4,
          },
          label = { drawing = false },
          background = {
            color = is_front and colors.with_alpha(colors.soft_700, 0.5) or colors.transparent,
            corner_radius = 4,
            height = 24,
            border_width = 0,
          },
          padding_left = 2,
          padding_right = 2,
        })

        space_apps[app_name] = item
      end
    end)
  end)
end

local space_observer = sbar.add('item', {
  drawing = false,
  updates = true,
})

space_observer:subscribe('space_change', function(env)
  update_apps()
end)

space_observer:subscribe('front_app_switched', function(env)
  update_apps()
end)

space_observer:subscribe('space_windows_change', function(env)
  update_apps()
end)

update_apps()
