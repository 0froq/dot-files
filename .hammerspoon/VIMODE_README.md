# Vi Mode for Hammerspoon + Sketchybar 集成

## 功能说明

这是一个类似 Vi 的模式切换系统，为 macOS 提供全局快捷键支持，并与 Sketchybar 深度集成。

### 核心特性

1. **模式切换**: 按 `Alt + ;` 进入/退出 Vi Mode
2. **窗口管理**: 在 Vi Mode 中按 `Enter` 最大化窗口（上下左右留 160px 空间）
3. **视觉反馈**: 
   - Vi Mode 激活时，Sketchybar 整体背景变为灰色
   - 左侧显示 `:` 提示符和实时按键序列
4. **退出模式**: 按 `Esc` 或等待操作完成后自动退出

## 安装说明

### 1. Hammerspoon 配置

确保你的 `~/.config/.hammerspoon/init.lua` 包含：

```lua
require('Spoons.vimode')
```

### 2. Sketchybar 配置

确保你的 `~/.config/sketchybar/items/init.lua` 包含：

```lua
require("items.vimode")
```

### 3. 重新加载配置

**Hammerspoon:**
- 点击菜单栏的 Hammerspoon 图标
- 选择 "Reload Config"

或者使用快捷键（如果你配置了的话）

**Sketchybar:**
```bash
sketchybar --reload
```

## 使用方法

1. **进入 Vi Mode**: 
   - 按 `Alt + ;`
   - 你会看到屏幕提示 "Vi Mode: ON"
   - Sketchybar 背景变为灰色
   - 左侧出现 `:` 提示符

2. **窗口最大化**:
   - 在 Vi Mode 中按 `Enter`
   - 当前窗口会最大化，留出 160px 边距
   - 0.6秒后自动退出 Vi Mode

3. **查看按键序列**:
   - 在 Vi Mode 中按任何键
   - 按键会显示在 Sketchybar 左侧的 `:` 后面
   - 例如: `:abc` 表示你按了 a、b、c

4. **退出 Vi Mode**:
   - 按 `Esc` 立即退出
   - 或执行操作后自动退出

## 扩展功能

你可以在 `vimode.lua` 的按键处理部分添加更多快捷键，例如：

```lua
-- 处理 h/j/k/l 移动窗口
if ch == 'h' then
  -- 向左移动窗口
  moveWindowLeft()
  exitViMode()
  return true
elseif ch == 'j' then
  -- 向下移动窗口
  moveWindowDown()
  exitViMode()
  return true
end
-- ... 等等
```

## 文件结构

```
~/.config/
├── .hammerspoon/
│   ├── init.lua
│   └── Spoons/
│       └── vimode.lua          # Vi Mode 主逻辑
├── sketchybar/
│   ├── init.lua
│   └── items/
│       ├── init.lua
│       └── vimode.lua          # Sketchybar 集成
└── .cache/hs/
    ├── vimode                  # 模式状态文件
    └── keys                    # 按键序列文件
```

## 技术细节

- **状态管理**: 通过 `~/.cache/hs/vimode` 和 `~/.cache/hs/keys` 文件实现 Hammerspoon 和 Sketchybar 之间的通信
- **事件触发**: 使用 `sketchybar --trigger vimode_changed` 通知 Sketchybar 更新
- **输入过滤**: 自动排除文本输入框，避免干扰正常输入

## 故障排除

如果功能不工作：

1. 检查 Hammerspoon 控制台是否有错误信息
2. 确认 `~/.cache/hs/` 目录存在且可写
3. 使用 `sketchybar --query vimode_indicator` 检查 item 是否正确加载
4. 重新加载两个配置

## 自定义

### 修改边距

在 `vimode.lua` 中修改 `gap` 值：

```lua
local gap = 160  -- 改为你想要的像素值
```

### 修改颜色

在 `items/vimode.lua` 中修改：

```lua
sbar.bar({
  color = colors.soft_700,  -- 改为其他颜色
})
```
