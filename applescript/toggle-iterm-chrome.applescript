tell application "System Events"
    set activeApp to name of first application process whose frontmost is true
    if "iTerm2" is in activeApp then
		tell application "Google Chrome" to activate
    else
		tell application "iTerm2" to activate
    end if
end tell
