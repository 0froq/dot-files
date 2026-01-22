local colors = require("colors")

local Separator = {}

function Separator.new(name, config)
  config = config or {}

  local separator_config = {
    position = config.position or "right",
    icon = {
      string = config.icon or "/",
      color = config.color or colors.soft_500,
      padding_left = config.padding_left or 8,
      padding_right = config.padding_right or 8,
      font = config.font or nil,
    },
    label = { drawing = false },
    background = {
      color = colors.transparent,
      border_width = 0,
    },
    padding_left = 0,
    padding_right = 0,
  }

  return sbar.add("item", name, separator_config)
end

return Separator
