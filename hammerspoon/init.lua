-- For the 'hs' command line tool
-- https://www.hammerspoon.org/docs/hs.ipc.html
if hs.ipc.cliStatus() == false then
  hs.ipc.cliInstall()
end
require("hs.ipc")

local fnutils = require("hs.fnutils")
local hyper = {'cmd', 'alt', 'ctrl'}
local shift_hyper = {'cmd', 'alt', 'ctrl', 'shift'}


--- App hotkeys
local app_hotkeys = {
  {key = "1", app = "iTerm"},
  {key = "2", app = "Google Chrome"},
  {key = "3", app = "SourceTree"},
  {key = "4", app = "com.apple.iCal"},
  {key = "5", app = "Slack"},
  {key = "6", app = "Spotify"},
  {key = "F2", app = "Postman"},
  {key = "F3", app = "Studio 3T"},
}
hs.application.enableSpotlightForNameSearches(true)
local bind_app_hotkey = function(hotkey)
  hs.hotkey.bind(hyper, hotkey.key, function()
    local app = hs.application.find(hotkey.app)
    if not app then
      print('app not found: ', hotkey.app)
      return
    end
    local fm = hs.application.frontmostApplication();
    if app:isFrontmost() then
      -- If already focused on the app, go to the previous one
      -- (trying to be equivalent to alt+tab)
      -- Based on https://github.com/AWildDevAppears/hammerspoon-config/blob/master/alttab.lua
      local windows = hs.window.orderedWindows()
      if #windows >= 2 then
        if app:name() == 'Google Chrome' then
          windows[3]:focus()
        else
          windows[2]:focus()
        end
      end
    else
      hs.application.launchOrFocusByBundleID(app:bundleID())
    end
  end)
end
fnutils.each(app_hotkeys, bind_app_hotkey)


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


-- Display sleep
local display_sleep = function()
  hs.execute('pmset displaysleepnow')
  if hs.spotify.isRunning() then
    hs.spotify.pause()
  end
end

-- Display sleep (hyper + l)
hs.hotkey.bind(hyper, "l", display_sleep)

-- Display sleep + clock out (hyper + L)
hs.hotkey.bind(shift_hyper, "l", function()
  display_sleep()
  hs.execute('timer -o', true)
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


--- Volume Control
local changeVolume = function(delta)
  local new_volume = hs.audiodevice.current().volume + delta
  hs.audiodevice.defaultOutputDevice():setVolume(new_volume)
  local actual_volume = hs.audiodevice.current().volume
  hs.alert.closeAll()
  hs.alert.show(string.format("%.0f", actual_volume))
end

local deltaVol = 6
local deltaVolSoft = 1

local incVolume = function()
  changeVolume(deltaVol)
end

local incVolumeSoft = function()
  changeVolume(deltaVolSoft)
end

local decVolume = function()
  changeVolume(-deltaVol)
end

local decVolumeSoft = function()
  changeVolume(-deltaVolSoft)
end

hs.hotkey.bind(hyper, 'k', hs.spotify.playpause)
hs.hotkey.bind(hyper, ']', incVolume)
hs.hotkey.bind(hyper, '[', decVolume)
hs.hotkey.bind(shift_hyper, ']', incVolumeSoft)
hs.hotkey.bind(shift_hyper, '[', decVolumeSoft)


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
