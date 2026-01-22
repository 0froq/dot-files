local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local Separator = require("helpers.separator")

sbar.add("item", { width = 8 })

local apple = sbar.add("item", {
  icon = {
    y_offset = 0,
    color = colors.white,
    font = { size = 20.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = {
    color = colors.transparent,
    border_width = 0,
  },
  padding_left = 0,
  padding_right = 0,
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0"
})

Separator.new("apple.separator", {
  position = "left",
  color = colors.soft_600
})
