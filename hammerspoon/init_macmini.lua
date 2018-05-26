-- https://github.com/lodestone/hyper-hacks/blob/master/hammerspoon/init.lua
-- https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e
-- https://github.com/Linell/hammerspoon-config/blob/master/init.lua
local fnutils = require("hs.fnutils")

local hyper = {'cmd', 'alt', 'ctrl'}
local shift_hyper = {'cmd', 'alt', 'ctrl', 'shift'}

--- App hotkeys
local app_hotkeys = {
  {key = "1", name = "iTerm"},
  {key = "2", name = "Google Chrome"},
  {key = "3", name = "SourceTree"},
  {key = "4", name = "Slack"},
}
local bind_hotkey = function(app)
  hs.hotkey.bind(hyper, app.key, function()
    hs.application.launchOrFocus(app.name)
  end)
end
fnutils.each(app_hotkeys, bind_hotkey)



--- Volume Control
local changeVolume = function(delta)
  local new_volume = hs.audiodevice.current().volume + delta
  hs.audiodevice.defaultOutputDevice():setVolume(new_volume)
  local actual_volume = hs.audiodevice.current().volume
  hs.alert.closeAll()
  hs.alert.show(string.format("%.0f", actual_volume))
end

local deltaVol = 6

local incVolume = function()
  changeVolume(deltaVol)
end

local incVolumeSoft = function()
  changeVolume(deltaVol / 2)
end

local decVolume = function()
  changeVolume(-deltaVol)
end

local decVolumeSoft = function()
  changeVolume(-deltaVol / 2)
end

hs.hotkey.bind(hyper, 'k', hs.spotify.playpause)
hs.hotkey.bind(hyper, ']', incVolume)
hs.hotkey.bind(hyper, '[', decVolume)
hs.hotkey.bind(shift_hyper, ']', incVolumeSoft)
hs.hotkey.bind(shift_hyper, '[', decVolumeSoft)
