local colors = require("colors")
local settings = require("settings")

local Widget = {}
Widget.__index = Widget

local function merge_tables(...)
  local result = {}
  for _, t in ipairs({ ... }) do
    if t then
      for k, v in pairs(t) do
        if type(v) == "table" and type(result[k]) == "table" then
          result[k] = merge_tables(result[k], v)
        else
          result[k] = v
        end
      end
    end
  end
  return result
end

function Widget:new(config)
  local widget = setmetatable({}, Widget)

  widget.name = config.name or "widget"
  widget.position = config.position or "right"
  widget.items = {}

  if config.item then
    local item_config = merge_tables({
      position = widget.position,
    }, config.item)

    local item_type = config.item.type or "item"

    if item_type == "graph" then
      local graph_width = config.item.graph_width or 42
      widget.items.main = sbar.add("graph", widget.name, graph_width, item_config)
    else
      widget.items.main = sbar.add(item_type, widget.name, item_config)
    end
  end

  if config.additional_items then
    for i, item_conf in ipairs(config.additional_items) do
      local item_name = item_conf.name or tostring(i)
      local full_name = widget.name .. "." .. item_name

      local item_config = merge_tables({
        position = widget.position,
      }, item_conf)

      widget.items[item_name] = sbar.add(
        item_conf.type or "item",
        full_name,
        item_config
      )
    end
  end

  if config.bracket then
    local bracket_items = {}
    for _, item in pairs(widget.items) do
      if type(item) == "table" and item.name then
        table.insert(bracket_items, item.name)
      end
    end

    local bracket_config = config.bracket_config or {
      background = { color = colors.transparent }
    }

    if #bracket_items > 0 then
      widget.bracket = sbar.add("bracket", widget.name .. ".bracket", bracket_items, bracket_config)
    end
  end

  if config.subscriptions then
    for _, sub in ipairs(config.subscriptions) do
      local target_item = widget.items[sub.item or "main"]
      if target_item then
        target_item:subscribe(sub.event, sub.callback)
      end
    end
  end

  return widget
end

function Widget:set(item_name, props)
  local item = self.items[item_name or "main"]
  if item then
    item:set(props)
  end
end

function Widget:get(item_name)
  return self.items[item_name or "main"]
end

function Widget:subscribe(item_name, event, callback)
  local item
  local actual_event
  local actual_callback

  if type(item_name) == "string" and type(event) == "string" then
    item = self.items[item_name]
    actual_event = event
    actual_callback = callback
  elseif type(item_name) == "string" and type(event) == "table" then
    item = self.items[item_name]
    actual_event = event
    actual_callback = callback
  elseif type(item_name) == "table" or type(item_name) == "string" then
    item = self.items.main
    actual_event = item_name
    actual_callback = event
  end

  if item and actual_event and actual_callback then
    item:subscribe(actual_event, actual_callback)
  end
end

return Widget
