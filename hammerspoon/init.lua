-- Enable 'hs' command line tool
-- https://www.hammerspoon.org/docs/hs.ipc.html
require("hs.ipc")

-- Globals
hyper = {'cmd', 'alt', 'ctrl'}
shift_hyper = {'cmd', 'alt', 'ctrl', 'shift'}

require("apphotkeys")
require("keyboardlayout")
local fnutils = require("hs.fnutils")

-- Utility functions
-- print table
function p(t)
  for k, v in pairs(t) do
    print(k, v)
  end
end

-- https://www.programming-idioms.org/idiom/19/reverse-a-list/1314/lua
function reverse(t)
  local n = #t
  local i = 1
  while i < n do
    t[i],t[n] = t[n],t[i]
    i = i + 1
    n = n - 1
  end
  return t
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


-- Lock screen
local lock_screen = function()
  --[[
    Lock screen instead of display sleep,
    so it is faster to get back to work.
    When using display sleep, one has to wait for the display to "wake up".
    And besides, when using my Sharp TV as a display,
    the TV apparently shuts down after not receiving signal for a while.

    Hammerspoon also has a lockScreen() API, but that has a small animation.
    That's why I favored locking the screen via the screensaver.
  --]]
  hs.caffeinate.startScreensaver()
  if hs.spotify.isRunning() then
    hs.spotify.pause()
  end
end

-- Lock screen (hyper + l)
hs.hotkey.bind(hyper, "l", lock_screen)

-- Display sleep
local display_sleep = function()
  hs.execute('pmset displaysleepnow')
  if hs.spotify.isRunning() then
    hs.spotify.pause()
  end
end

-- Display sleep + clock out (hyper + L)
hs.hotkey.bind(shift_hyper, "l", function()
  display_sleep()
  hs.execute('timer -o', true)
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

hs.hotkey.bind(hyper, ']', incVolume)
hs.hotkey.bind(hyper, '[', decVolume)
hs.hotkey.bind(shift_hyper, ']', incVolumeSoft)
hs.hotkey.bind(shift_hyper, '[', decVolumeSoft)


-- Spotify track control
-- play/pause
hs.hotkey.bind(hyper, 'k', function()
  if hs.spotify.isRunning() then
    hs.spotify.playpause()
  else
    -- Control other music player (like VLC).
    -- Press PLAY media key (will play/pause)
    hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
    hs.eventtap.event.newSystemKeyEvent('PLAY', false):post()
  end
end)
-- rewind
hs.hotkey.bind(hyper, ',', function()
  hs.spotify.rw()
end)
-- fast forward
hs.hotkey.bind(hyper, '.', function()
  hs.spotify.ff()
end)


-- Reload config when any lua file in config directory changes
local reloadConfig = function(files)
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
