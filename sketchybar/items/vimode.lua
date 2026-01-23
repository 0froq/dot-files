local colors = require("colors")

-- Vi Mode 指示器
local vimode = sbar.add("item", "vimode_indicator", {
  position = "left",
  icon = {
    string = "",
    color = colors.white,
    padding_left = 8,
    padding_right = 0,
  },
  label = {
    string = "",
    color = colors.white,
    padding_left = 4,
    padding_right = 8,
  },
  background = {
    color = colors.transparent,
  },
  drawing = true, -- 调试时显示
})

local function readFile(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

-- 监听模式变化
vimode:subscribe("vimode_changed", function()
  local modeFile = os.getenv("HOME") .. "/.cache/hs/vimode"
  local keysFile = os.getenv("HOME") .. "/.cache/hs/keys"
  
  local modeContent = readFile(modeFile)
  local keysContent = readFile(keysFile)
  
  local isActive = modeContent == "1"
  
  if isActive then
    -- Vi Mode 激活时显示指示器
    vimode:set({
      label = { string = (keysContent and keysContent ~= "" and keysContent) or ":" }
    })
    
    -- 改变整个 bar 的背景色为灰色
    sbar.bar({
      color = colors.soft_700,
    })
  else
    -- 关闭模式时清空内容并恢复颜色
    vimode:set({
      label = { string = "" }
    })

    -- 恢复 bar 的默认背景色
    sbar.bar({
      color = colors.soft_950,
    })
  end
end)

-- 定期更新按键显示（当在 Vi Mode 中时）
sbar.add("event", "vimode_update")
vimode:subscribe("routine", function()
  local modeFile = os.getenv("HOME") .. "/.cache/hs/vimode"
  local keysFile = os.getenv("HOME") .. "/.cache/hs/keys"
  
  local modeContent = readFile(modeFile)
  local keysContent = readFile(keysFile)
  
  if modeContent == "1" then
    vimode:set({
      label = { string = keysContent or ":" }
    })
  else
    vimode:set({
      label = { string = "" }
    })
  end
end)
