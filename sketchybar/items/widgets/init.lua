local Separator = require("helpers.separator")

require("items.widgets.spaces")
require("items.widgets.space_apps")

require("items.widgets.calendar")
Separator.new("separator.calendar", { position = "right" })

require("items.widgets.battery")
Separator.new("separator.battery", { position = "right" })

require("items.widgets.volume")
Separator.new("separator.volume", { position = "right" })

require("items.widgets.wifi")
Separator.new("separator.wifi", { position = "right" })

require("items.widgets.cpu")
-- Separator.new("separator.cpu", { position = "right" })

-- require("items.widgets.clash")
-- Separator.new("separator.clash", { position = "right" })
