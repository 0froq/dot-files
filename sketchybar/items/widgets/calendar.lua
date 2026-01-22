local settings = require("settings")
local colors = require("colors")
local Widget = require("helpers.widget")

local calendar = Widget:new({
  name = "calendar",
  position = "right",
  item = {
    icon = {
      color = colors.white,
      padding_left = 8,
      font = {
        size = 12.0,
      },
    },
    label = {
      color = colors.white,
      padding_right = 8,
      width = 49,
      align = "right",
    },
    update_freq = 30,
    padding_left = 1,
    padding_right = 1,
    background = {
      color = colors.transparent,
      border_width = 0
    },
  },
})

calendar:subscribe({ "forced", "routine", "system_woke" }, function(env)
  calendar:set("main", {
    icon = {
      string = os.date("%D"),
      color = colors.soft_500
    },
    label = {
      string = os.date("%H:%M")
    }
  })
end)

return calendar
