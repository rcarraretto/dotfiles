local fnutils = require("hs.fnutils")

local hyper = {'cmd', 'alt', 'ctrl'}

--- App hotkeys
local apps = {
  {key = "1", name = "iTerm"},
  {key = "2", name = "Google Chrome"},
  {key = "3", name = "SourceTree"},
  {key = "4", name = "Slack"},
  {key = "5", name = "Calendar"},
}
local bind_hotkey = function(app)
  hs.hotkey.bind(hyper, app.key, function()
    hs.application.launchOrFocus(app.name)
  end)
end
fnutils.each(apps, bind_hotkey)

-- Display sleep (hyper + l)
hs.hotkey.bind(hyper, "l", function()
  hs.execute('pmset displaysleepnow')
end)

-- Toggle iTerm and Chrome
hs.hotkey.bind(hyper, "t", function()
  if hs.application.frontmostApplication():title() == "iTerm2" then
    hs.application.launchOrFocus("Google Chrome")
  else
    hs.application.launchOrFocus("iTerm")
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
