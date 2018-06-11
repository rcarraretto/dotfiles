-- https://github.com/lodestone/hyper-hacks/blob/master/hammerspoon/init.lua
-- https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e
-- https://github.com/Linell/hammerspoon-config/blob/master/init.lua
local fnutils = require("hs.fnutils")

local hyper = {'cmd', 'alt', 'ctrl'}

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
