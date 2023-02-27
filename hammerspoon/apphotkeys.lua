local fnutils = require("hs.fnutils")

--- App hotkeys
local app_hotkeys = {
  {key = "1", app = "iTerm"},
  {key = "2", app = "Google Chrome"},
  {key = "3", app = "SourceTree"},
  {key = "4", app = "com.apple.iCal"},
  {key = "5", app = "Slack"},
  {key = "6", app = "Spotify"},
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

-- Toggle between 2 apps
local toggle_app_hotkeys = {
  {key = "t", app1 = "/Applications/iTerm.app", app2 = "/Applications/Google Chrome.app"},
  {key = "v", app1 = "/Applications/IntelliJ IDEA.app", app2 = "/Applications/iTerm.app"},
}
local bind_toggle_app_hotkey = function(hotkey)
  hs.hotkey.bind(hyper, hotkey.key, function()
    if hs.application.frontmostApplication():path() == hotkey.app1 then
      hs.application.launchOrFocus(hotkey.app2)
    else
      hs.application.launchOrFocus(hotkey.app1)
    end
  end)
end
fnutils.each(toggle_app_hotkeys, bind_toggle_app_hotkey)
