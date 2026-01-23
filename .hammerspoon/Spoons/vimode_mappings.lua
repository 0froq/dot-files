local v = require('Spoons.vimode')

v.register({
  h = function() hs.alert('h'); end,
  ['↩'] = function() hs.alert('custom enter'); return 'exit' end,
  ['⌘c'] = function() hs.alert('cmd-c'); end, -- 使用 describeKey 产出的格式
})
