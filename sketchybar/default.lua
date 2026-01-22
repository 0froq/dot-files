local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 16.0,
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 0 } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 13.0,
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 28,
    corner_radius = 0,
    border_width = 0,
    border_color = colors.transparent,
    image = {
      corner_radius = 0,
      border_color = colors.transparent,
      border_width = 0,
    },
  },
  popup = {
    background = {
      border_width = 1,
      corner_radius = 4,
      border_color = colors.soft_600,
      color = colors.with_alpha(colors.soft_800, 0.95),
      shadow = { drawing = true },
    },
    blur_radius = 50,
  },
  padding_left = 5,
  padding_right = 5,
  scroll_texts = true,
  margin = 5,
})
