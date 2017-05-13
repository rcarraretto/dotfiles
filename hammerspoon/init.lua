-- https://github.com/lodestone/hyper-hacks/blob/master/hammerspoon/init.lua
-- https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e
-- https://github.com/Linell/hammerspoon-config/blob/master/init.lua

local hyper = {'cmd', 'alt', 'ctrl'}
local shift_hyper = {'cmd', 'alt', 'ctrl', 'shift'}

-- Global variable for Hyper Mode
k = hs.hotkey.modal.new({}, 'F17')

-- Hyper+key setup in Alfred
hyperBindings = {'1', '2', '3', '6', 'k', 't', 'y', '[', ']'}

for i,key in ipairs(hyperBindings) do
  k:bind({}, key, nil, function()
    hs.eventtap.keyStroke(hyper, key)
  end)
  k:bind({'shift'}, key, nil, function()
    hs.eventtap.keyStroke(shift_hyper, key)
  end)
end

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
pressedF18 = function()
  k:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed
releasedF18 = function()
  k:exit()
end

-- Bind the Hyper key
hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)

local changeVolume = function(delta)
  hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume + delta)
end

local deltaVol = 5

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
