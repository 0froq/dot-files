local eventtap = hs.eventtap
local ax = hs.axuielement

-- ------- sketchybar 状态文件（推荐：解耦） -------
local cacheDir = os.getenv('HOME') .. '/.cache/hs'
local stateFile = cacheDir .. '/keys'
local modeFile = cacheDir .. '/vimode'
-- local sketchybarBin = (hs.execute('which sketchybar') or ''):gsub('%s+$', '')
local sketchybarBin = "/opt/homebrew/bin/sketchybar"

hs.fs.mkdir(cacheDir)

local function triggerBar()
  if sketchybarBin == '' then return end
  hs.task.new(sketchybarBin, function() end, { '--trigger', 'vimode_changed' }):start()
end

local function setBarState(s)
  local f = io.open(stateFile, 'w')
  if f then
    f:write(s or ''); f:close()
  end
  triggerBar()
end

local function setViMode(enabled)
  local f = io.open(modeFile, 'w')
  if f then
    f:write(enabled and '1' or '0'); f:close()
  end
  triggerBar()
end

-- ------- Vi Mode 状态 -------
local viModeActive = false
local keySequence = ''
local passthrough = false
local tap = nil
local idleTimer = nil
local handlers = {}
local M = {}

local specialKeys = {
  [36] = '↩', -- return
  [48] = '⇥', -- tab
  [51] = '⌫', -- delete
  [53] = '⎋', -- esc
  [123] = '←',
  [124] = '→',
  [125] = '↓',
  [126] = '↑',
}

local function describeKey(e)
  local flags = e:getFlags()
  local keyCode = e:getKeyCode()
  local parts = {}

  if flags.cmd then table.insert(parts, '⌘') end
  if flags.ctrl then table.insert(parts, '⌃') end
  if flags.alt then table.insert(parts, '⌥') end
  if flags.shift then table.insert(parts, '⇧') end

  local ch = e:getCharacters()
  if ch and ch ~= '' then
    table.insert(parts, ch)
  else
    table.insert(parts, specialKeys[keyCode] or tostring(keyCode))
  end

  return table.concat(parts)
end

function M.register(map)
  if type(map) ~= 'table' then return end
  table.insert(handlers, map)
end

local function AlmostMaximumWindow()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen()
  if not screen then return end
  local maxFrame = screen:frame()
  local gap = 160
  local newFrame = {
    x = maxFrame.x + gap,
    y = maxFrame.y + gap,
    w = maxFrame.w - 2 * gap,
    h = maxFrame.h - 2 * gap,
  }
  win:setFrame(newFrame)
end

local function exitViMode()
  if tap then tap:stop() end
  if idleTimer then idleTimer:stop(); idleTimer = nil end
  viModeActive = false
  keySequence = ''
  setViMode(false)
  setBarState('')
end

local function updateKeyDisplay()
  if viModeActive then
    setBarState(':' .. keySequence)
  else
    setBarState('')
  end
end

-- ------- Alt + ; 切换 Vi Mode -------
hs.hotkey.bind({'alt'}, ';', function()
  viModeActive = not viModeActive
  keySequence = ''
  setViMode(viModeActive)
  updateKeyDisplay()
  
  if viModeActive then
    if tap then tap:start() end
    if idleTimer then idleTimer:stop() end
    idleTimer = hs.timer.doAfter(1.0, exitViMode)
    hs.alert.show('Vi Mode: ON', 0.5)
  else
    if tap then tap:stop() end
    if idleTimer then idleTimer:stop(); idleTimer = nil end
    hs.alert.show('Vi Mode: OFF', 0.5)
  end
end)

-- ------- Vi Mode 快捷键监听 -------
tap = eventtap.new({ eventtap.event.types.keyDown }, function(e)
  if passthrough then return false end
  if not viModeActive then return false end

  -- 处理 Escape 退出模式
  local keyCode = e:getKeyCode()
  if keyCode == 53 then
    exitViMode()
    return true
  end

  -- 记录并展示按键（包含修饰键与特殊键）
  local keyId = describeKey(e)
  keySequence = keySequence .. keyId
  updateKeyDisplay()

  if idleTimer then idleTimer:stop() end
  idleTimer = hs.timer.doAfter(1.0, exitViMode)

  -- 自定义映射
  local handled = false
  for _, map in ipairs(handlers) do
    local fn = map[keyId] or map[keyCode]
    if not fn and e:getCharacters() and e:getCharacters() ~= '' then
      fn = map[e:getCharacters()]
    end
    if fn then
      handled = true
      local rv = fn(e)
      if rv == true or rv == 'exit' then
        exitViMode()
      end
      break
    end
  end

  -- 默认 Enter 行为（若未被自定义处理覆盖）
  if (keyCode == 36 or e:getCharacters() == '\r') and not handled then
    AlmostMaximumWindow()
    if idleTimer then idleTimer:stop() end
    idleTimer = hs.timer.doAfter(1.0, exitViMode)
  end

  -- 在 Vi Mode 中吞掉所有按键
  return true
end)

return M
