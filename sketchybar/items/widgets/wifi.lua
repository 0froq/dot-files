local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local Widget = require("helpers.widget")

sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0")

local popup_width = 250

local wifi = Widget:new({
  name = "widgets.wifi",
  position = "right",
  additional_items = {
    {
      name = "up",
      padding_left = -5,
      width = 0,
      icon = {
        padding_right = 0,
        font = {
          style = settings.font.style_map["Bold"],
          size = 11.0,
        },
        string = icons.wifi.upload,
      },
      label = {
        font = {
          family = settings.font.numbers,
          style = settings.font.style_map["Bold"],
          size = 11.0,
        },
        color = colors.rose[2],
        string = "??? Bps",
      },
      y_offset = 4,
      background = { color = colors.transparent }
    },
    {
      name = "down",
      padding_left = -5,
      icon = {
        padding_right = 0,
        font = {
          style = settings.font.style_map["Bold"],
          size = 11.0,
        },
        string = icons.wifi.download,
      },
      label = {
        font = {
          family = settings.font.numbers,
          style = settings.font.style_map["Bold"],
          size = 11.0,
        },
        color = colors.cyan[2],
        string = "??? Bps",
      },
      y_offset = -4,
      background = { color = colors.transparent }
    },
    {
      name = "padding",
      label = { drawing = false },
      background = { color = colors.transparent }
    }
  },
  bracket = true,
  bracket_config = {
    background = { color = colors.transparent },
    popup = { align = "center", height = 30 }
  },
})

local ssid = sbar.add("item", { 
  position = "popup." .. wifi.bracket.name,
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"]
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.soft_300,
    y_offset = -15
  }
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi.bracket.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = sbar.add("item", {
  position = "popup." .. wifi.bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = sbar.add("item", {
  position = "popup." .. wifi.bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = sbar.add("item", {
  position = "popup." .. wifi.bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

wifi:subscribe("up", "network_update", function(env)
  local up_color = (env.upload == "000 Bps") and colors.grey or colors.red
  local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
  wifi:set("up", {
    icon = { color = up_color },
    label = {
      string = env.upload,
      color = up_color
    }
  })
  wifi:set("down", {
    icon = { color = down_color },
    label = {
      string = env.download,
      color = down_color
    }
  })
end)

wifi:subscribe("padding", { "wifi_change", "system_woke" }, function(env)
  sbar.exec("ipconfig getifaddr en0", function(ip)
    local connected = not (ip == "")
    wifi:set("padding", {
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    })
  end)
end)

local function hide_details()
  wifi.bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi.bracket:query().popup.drawing == "off"
  if should_draw then
    wifi.bracket:set({ popup = { drawing = true } })
    sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
    end)
    sbar.exec("ipconfig getifaddr en0", function(result)
      ip:set({ label = result })
    end)
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set({ label = result })
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set({ label = result })
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set({ label = result })
    end)
  else
    hide_details()
  end
end

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

wifi:subscribe("up", "mouse.clicked", toggle_details)
wifi:subscribe("down", "mouse.clicked", toggle_details)
wifi:subscribe("padding", "mouse.clicked", toggle_details)
wifi:subscribe("padding", "mouse.exited.global", hide_details)

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)

return wifi
