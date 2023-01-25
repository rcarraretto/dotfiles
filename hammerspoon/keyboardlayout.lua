local NOTIFY_ON_AUTO_CHANGE = false
local STD_SOURCE_ID = "com.apple.keylayout.ABC"

local refreshTmuxStatus = function()
  -- Hack to get Hammerspoon to call tmux in a non-blocking way.
  -- This would block:
  -- hs.execute('tmux refresh-client -S &', true)
  hs.task.new("~/work/dotfiles/bin/hs-refresh-tmux-status", nil):start()
end

local showAlert = function(msg, notify)
  if type(notify) == "nil" then
    notify = true
  end
  if notify then
    hs.alert.closeAll()
    hs.alert.show(msg)
    print(msg)
  end
end

local setSourceId = function(source_id, notify)
  local ret = hs.keycodes.currentSourceID(source_id)
  if ret then
    refreshTmuxStatus()
    showAlert(hs.keycodes.currentLayout(), notify)
  end
end

local setMethod = function(method, notify)
  local ret = hs.keycodes.setMethod(method)
  if ret then
    refreshTmuxStatus()
    showAlert(hs.keycodes.currentMethod(), notify)
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

local addHotkeys = function(hyper, shift_hyper)
  -- Toggle input source (hyper + `)
  hs.hotkey.bind(hyper, "`", function()
    -- When on Japanese keyboard, source_id is "com.apple.inputmethod.Kotoeri.Japanese".
    -- But this source_id is not listed in source_ids.
    local source_ids = hs.keycodes.layouts(true)
    local source_id = hs.keycodes.currentSourceID()
    -- Reverse list, so ABC layout is the default layout,
    -- when coming from Japanese layout.
    local next_source_id = cycle_list(reverse(source_ids), source_id)
    setSourceId(next_source_id)
  end)

  -- Toggle Hiragana and Katakana (hyper + a)
  hs.hotkey.bind(hyper, "a", function()
    -- hs.keycodes.methods() without "Romaji"
    local methods = {"Hiragana", "Katakana"}
    local method = hs.keycodes.currentMethod()
    local next_method = cycle_list(methods, method)
    setMethod(next_method)
  end)
end

function getKeyboardLayout()
  local method = hs.keycodes.currentMethod()
  if method then
    if method == "Hiragana" then
      return "あ"
    end
    if method == "Katakana" then
      return "ア"
    end
    return method
  end
  local layout = hs.keycodes.currentLayout()
  if layout:find("U%.S%. International") ~= nil then
    return "US"
  end
  return layout
end

function switchToPreviousKeyboardLayout()
  if prev_method then
    return setMethod(prev_method, NOTIFY_ON_AUTO_CHANGE)
  end
  if prev_source_id then
    return setSourceId(prev_source_id, NOTIFY_ON_AUTO_CHANGE)
  end
end

function switchToStandardKeyboardLayout()
  if hs.keycodes.currentSourceID() == STD_SOURCE_ID then
    prev_method = nil
    prev_source_id = nil
    return
  end
  prev_method = hs.keycodes.currentMethod()
  prev_source_id = hs.keycodes.currentSourceID()
  setSourceId(STD_SOURCE_ID, NOTIFY_ON_AUTO_CHANGE)
end

return {
  addHotkeys = addHotkeys
}
