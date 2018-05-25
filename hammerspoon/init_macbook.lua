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
