local fnutils = require("hs.fnutils")

local hyper = {'cmd', 'alt', 'ctrl'}

--- App hotkeys
local app_hotkeys = {
  {key = "1", app = "iTerm"},
  {key = "2", app = "Google Chrome"},
  {key = "3", app = "SourceTree"},
  {key = "4", app = "Slack"},
  {key = "5", app = "Calendar"},
  {key = "F1", app = "Spotify"},
  {key = "F2", app = "Postman"},
  {key = "F3", app = "Studio 3T"},
}
local bind_app_hotkey = function(hotkey)
  hs.hotkey.bind(hyper, hotkey.key, function()
    hs.application.launchOrFocus(hotkey.app)
  end)
end
fnutils.each(app_hotkeys, bind_app_hotkey)
