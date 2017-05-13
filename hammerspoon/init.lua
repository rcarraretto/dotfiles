-- https://github.com/lodestone/hyper-hacks/blob/master/hammerspoon/init.lua
-- https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e

-- Global variable for Hyper Mode
k = hs.hotkey.modal.new({}, 'F17')

-- Hyper+key setup in Alfred
hyperBindings = {'1', '2', '3', '6', 't'}

for i,key in ipairs(hyperBindings) do
  k:bind({}, key, nil, function()
    hs.eventtap.keyStroke({'cmd','alt','ctrl'}, key)
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
f18 = hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)
