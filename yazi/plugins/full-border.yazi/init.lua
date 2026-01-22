-- Full Border with PLAIN (straight corners)
-- return {
--   type = ui.Border.PLAIN,  -- 直角边框（默认是 ROUNDED）
--   -- 可选：调整样式
--   style = { fg = "white" },  -- 边框颜色
-- }
require('full-border'):setup {
  -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
  type = ui.Border.ROUNDED,
}
