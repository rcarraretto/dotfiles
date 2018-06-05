local fnutils = require("hs.fnutils")
local hyper = {'cmd', 'alt', 'ctrl'}


-- Utility functions
-- print table
function p(t)
  for k, v in pairs(t) do
    print(k, v)
  end
end

function get_key_for_value(t, value)
  for k, v in pairs(t) do
    if v == value then
      return k
    end
  end
  return nil
end


-- Window management
hs.grid.setGrid('12x12')
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0.0

local window_hotkeys = {
  {key = "m", cell = '0,0 12x12'},
  {key = "right", cell = '6,0 6x12'},
  {key = "left", cell = '0,0 6x12'},
  {key = "up", cell = '0,0 12x6'},
  {key = "down", cell = '0,6 12x6'},
}
local bind_window_hotkey = function(hotkey)
  hs.hotkey.bind(hyper, hotkey.key, function ()
    local win = hs.window.frontmostWindow()
    hs.grid.set(win, hotkey.cell)
  end)
end
fnutils.each(window_hotkeys, bind_window_hotkey)


-- Toggle iTerm and Chrome
hs.hotkey.bind(hyper, "t", function()
  if hs.application.frontmostApplication():title() == "iTerm2" then
    hs.application.launchOrFocus("Google Chrome")
  else
    hs.application.launchOrFocus("iTerm")
  end
end)


-- Display sleep (hyper + l)
hs.hotkey.bind(hyper, "l", function()
  hs.execute('pmset displaysleepnow')
end)


-- Toggle input source (hyper + `)
hs.hotkey.bind(hyper, "`", function()
  source_ids = hs.keycodes.layouts(true)
  source_id = hs.keycodes.currentSourceID()
  key = get_key_for_value(source_ids, source_id)
  if (key == #source_ids) then
    next_key = 1
  else
    next_key = key + 1
  end
  next_source_id = source_ids[next_key]
  ret = hs.keycodes.currentSourceID(next_source_id)
  if ret then
    hs.alert.closeAll()
    hs.alert.show(hs.keycodes.currentLayout())
  end
end)


-- Reload config when any lua file in config directory changes
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reloadConfig):start()
hs.alert.show('Hammerspoon config loaded')


-- Machine-specific config
if string.match(hs.host.localizedName(), 'rc-') then
  require("init_macbook")
else
  require("init_macmini")
end
