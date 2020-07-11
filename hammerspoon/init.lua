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

local get_key_for_value = function(t, value)
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

local cycle_list = function(list, current)
  local key = get_key_for_value(list, current)
  local next_key
  if (key == #list) or key == nil then
    next_key = 1
  else
    next_key = key + 1
  end
  return list[next_key]
end

local setSourceId = function(source_id, notify)
  if type(notify) == "nil" then
    notify = true
  end
  local ret = hs.keycodes.currentSourceID(source_id)
  if ret and notify then
    hs.alert.closeAll()
    hs.alert.show(hs.keycodes.currentLayout())
  end
end

-- Toggle input source (hyper + `)
hs.hotkey.bind(hyper, "`", function()
  -- When on Japanese keyboard, source_id is "com.apple.inputmethod.Kotoeri.Japanese".
  -- But this source_id is not listed in source_ids.
  local source_ids = hs.keycodes.layouts(true)
  local source_id = hs.keycodes.currentSourceID()
  local next_source_id = cycle_list(source_ids, source_id)
  setSourceId(next_source_id)
end)

local setMethod = function(method)
  local ret = hs.keycodes.setMethod(method)
  if ret then
    hs.alert.closeAll()
    hs.alert.show(hs.keycodes.currentMethod())
  end
end

-- Toggle Hiragana and Katakana (hyper + shift + `)
hs.hotkey.bind(shift_hyper, "`", function()
  -- hs.keycodes.methods() without "Romaji"
  local methods = {"Hiragana", "Katakana"}
  local method = hs.keycodes.currentMethod()
  local next_method = cycle_list(methods, method)
  setMethod(next_method)
end)

function switchToPreviousKeyboardLayout()
  if prev_method then
    return setMethod(prev_method)
  end
  if prev_source_id then
    return setSourceId(prev_source_id)
  end
end

function switchToStandardKeyboardLayout()
  local target_source_id = "com.apple.keylayout.Brazilian"
  if hs.keycodes.currentSourceID() == target_source_id then
    prev_method = nil
    prev_source_id = nil
    return
  end
  prev_method = hs.keycodes.currentMethod()
  prev_source_id = hs.keycodes.currentSourceID()
  setSourceId(target_source_id, false)
end

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
local showTrack = function()
  hs.alert.closeAll()
  hs.alert.show(hs.spotify.getCurrentTrack())
end

-- Play/pause
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

hs.hotkey.bind(hyper, ',', function()
  hs.spotify.previous()
  showTrack()
end)
hs.hotkey.bind(hyper, '.', function()
  hs.spotify.next()
  showTrack()
end)


-- Reconnect wifi
hs.hotkey.bind(shift_hyper, "w", function()
  hs.execute('networksetup -setairportpower en0 off', true)
  hs.execute('networksetup -setairportpower en0 on', true)
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
