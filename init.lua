-- Hammerspoon config

hs.window.animationDuration = 0

dictationNudge = {
  enabled = true,
  threshold = 25,
  windowSeconds = 90,
  cooldownSeconds = 30 * 60,
  typed = 0,
  windowStartedAt = 0,
  lastShownAt = 0,
}

local textEntryKeys = {
  space = true,
  ['return'] = true,
  tab = true,
}

for char = string.byte('a'), string.byte('z') do
  textEntryKeys[string.char(char)] = true
end

for digit = 0, 9 do
  textEntryKeys[tostring(digit)] = true
end

for _, key in ipairs({ '-', '=', '[', ']', '\\', ';', "'", ',', '.', '/', '`' }) do
  textEntryKeys[key] = true
end

local function maybeNudgeForDictation(event)
  if not dictationNudge.enabled then
    return false
  end

  local flags = event:getFlags()
  if flags.cmd or flags.ctrl or flags.alt or flags.fn then
    return false
  end

  local key = hs.keycodes.map[event:getKeyCode()]
  if not textEntryKeys[key] then
    return false
  end

  local now = hs.timer.secondsSinceEpoch()
  if now - dictationNudge.windowStartedAt > dictationNudge.windowSeconds then
    dictationNudge.typed = 0
    dictationNudge.windowStartedAt = now
  end

  if dictationNudge.windowStartedAt == 0 then
    dictationNudge.windowStartedAt = now
  end

  dictationNudge.typed = dictationNudge.typed + 1

  if dictationNudge.typed >= dictationNudge.threshold and now - dictationNudge.lastShownAt > dictationNudge.cooldownSeconds then
    dictationNudge.lastShownAt = now
    dictationNudge.typed = 0
    dictationNudge.windowStartedAt = now
    hs.alert.show('press fn to dictate', 3)
  end

  return false
end

dictationNudge.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, maybeNudgeForDictation):start()

local ratios = {
  side = { 0.50, 0.67, 0.75, 0.25, 0.33 },
  vertical = { 0.50, 0.67, 0.75 },
  corner = { 0.50, 0.67 },
}

local function unit(position, ratio)
  if position == 'left' then
    return { x = 0.00, y = 0.00, w = ratio, h = 1.00 }
  elseif position == 'right' then
    return { x = 1.00 - ratio, y = 0.00, w = ratio, h = 1.00 }
  elseif position == 'top' then
    return { x = 0.00, y = 0.00, w = 1.00, h = ratio }
  elseif position == 'bottom' then
    return { x = 0.00, y = 1.00 - ratio, w = 1.00, h = ratio }
  elseif position == 'topleft' then
    return { x = 0.00, y = 0.00, w = ratio, h = ratio }
  elseif position == 'topright' then
    return { x = 1.00 - ratio, y = 0.00, w = ratio, h = ratio }
  elseif position == 'bottomleft' then
    return { x = 0.00, y = 1.00 - ratio, w = ratio, h = ratio }
  elseif position == 'bottomright' then
    return { x = 1.00 - ratio, y = 1.00 - ratio, w = ratio, h = ratio }
  end
end

local function nearlyEqual(a, b)
  return math.abs(a - b) < 0.01
end

local function sameUnit(a, b)
  return nearlyEqual(a.x, b.x) and nearlyEqual(a.y, b.y) and nearlyEqual(a.w, b.w) and nearlyEqual(a.h, b.h)
end

local function currentUnit(window)
  local frame = window:frame()
  local screenFrame = window:screen():frame()

  return {
    x = (frame.x - screenFrame.x) / screenFrame.w,
    y = (frame.y - screenFrame.y) / screenFrame.h,
    w = frame.w / screenFrame.w,
    h = frame.h / screenFrame.h,
  }
end

local function bindCycle(mods, key, position, cycleRatios)
  hs.hotkey.bind(mods, key, function()
    local window = hs.window.focusedWindow()
    if not window then return end

    local activeUnit = currentUnit(window)
    local nextIndex = 1
    for index, ratio in ipairs(cycleRatios) do
      if sameUnit(activeUnit, unit(position, ratio)) then
        nextIndex = (index % #cycleRatios) + 1
        break
      end
    end

    window:move(unit(position, cycleRatios[nextIndex]), nil, true)
  end)
end

local maximum = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 }
local resizeStep = 0.15

local function moveFocusedWindow(targetUnit)
  local window = hs.window.focusedWindow()
  if window then window:move(targetUnit, nil, true) end
end

local function resizeSnappedWindow(delta)
  local window = hs.window.focusedWindow()
  if not window then return end

  local activeUnit = currentUnit(window)
  local targetUnit = nil

  if sameUnit(activeUnit, maximum) and delta > 0 then
    targetUnit = {
      x = resizeStep,
      y = activeUnit.y,
      w = 1.00 - resizeStep,
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x, 0.00) then
    targetUnit = {
      x = 0.00,
      y = activeUnit.y,
      w = math.max(resizeStep, math.min(1.00, activeUnit.w + delta)),
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x + activeUnit.w, 1.00) then
    local nextWidth = math.max(resizeStep, math.min(1.00, activeUnit.w - delta))
    targetUnit = {
      x = 1.00 - nextWidth,
      y = activeUnit.y,
      w = nextWidth,
      h = activeUnit.h,
    }
  end

  if targetUnit then window:move(targetUnit, nil, true) end
end

mash = { 'ctrl', 'option', 'cmd' }
hs.hotkey.bind(mash, 'l', function() moveFocusedWindow(unit('right', 0.50)) end)
hs.hotkey.bind(mash, 'h', function() moveFocusedWindow(unit('left', 0.50)) end)
hs.hotkey.bind(mash, '.', function() resizeSnappedWindow(resizeStep) end)
hs.hotkey.bind(mash, ',', function() resizeSnappedWindow(-resizeStep) end)
bindCycle(mash, 'k', 'top', ratios.vertical)
bindCycle(mash, 'j', 'bottom', ratios.vertical)

bindCycle(mash, 'u', 'topleft', ratios.corner)
hs.hotkey.bind(mash, 'i', function() hs.application.launchOrFocus('Linear') end)
bindCycle(mash, 'o', 'bottomright', ratios.corner)
bindCycle(mash, 'p', 'bottomleft', ratios.corner)

hs.hotkey.bind(mash, 'm', function()
  local window = hs.window.focusedWindow()
  if window then window:move(maximum, nil, true) end
end)


local function logVivaldiShortcut(message)
  hs.printf('[vivaldi-shortcuts] %s', message)
end

local function focusVivaldiWorkspaceTab(label, workspace, tab)
  logVivaldiShortcut(string.format('%s requested; target workspace=%s tab=%s', label, workspace, tab or 'none'))

  hs.application.launchOrFocus('Vivaldi')
  logVivaldiShortcut('Called hs.application.launchOrFocus("Vivaldi")')

  hs.timer.doAfter(0.05, function()
    logVivaldiShortcut(string.format('Sending Vivaldi workspace shortcut ctrl+shift+%s', workspace))
    hs.eventtap.keyStroke({ 'ctrl', 'shift' }, tostring(workspace))

    if tab then
      hs.timer.doAfter(0.05, function()
        logVivaldiShortcut(string.format('Sending Vivaldi tab shortcut cmd+%s', tab))
        hs.eventtap.keyStroke({ 'cmd' }, tostring(tab))
      end)
    else
      logVivaldiShortcut(string.format('%s is workspace-only; skipping tab shortcut', label))
    end
  end)
end

local vivaldiShortcuts = {
  { key = 'g', label = 'Gmail', workspace = 2, tab = 1 },
  { key = 's', label = 'SMS', workspace = 2, tab = 3 },
  { key = 'y', label = 'Jellyfin', workspace = 3, tab = 2 },
  { key = 'v', label = 'Video workspace', workspace = 3 },
  { key = 'b', label = 'Airbnb workspace', workspace = 4 },
  { key = '4', label = 'Money', workspace = 5 },
  { key = 'd', label = 'DayZ', workspace = 6 },
}

for _, shortcut in ipairs(vivaldiShortcuts) do
  hs.hotkey.bind(mash, shortcut.key, function()
    logVivaldiShortcut(string.format('Global shortcut ctrl+option+cmd+%s fired', shortcut.key))
    focusVivaldiWorkspaceTab(shortcut.label, shortcut.workspace, shortcut.tab)
  end)
end


hs.hotkey.bind(mash, 'n', function()
  -- Get the focused window, its window frame dimensions, its screen frame dimensions,
  -- and the next screen's frame dimensions.
  local focusedWindow = hs.window.focusedWindow()
  local focusedScreenFrame = focusedWindow:screen():frame()
  local nextScreenFrame = focusedWindow:screen():next():frame()
  local windowFrame = focusedWindow:frame()

  -- Calculate the coordinates of the window frame in the next screen and retain aspect ratio
  windowFrame.x = ((((windowFrame.x - focusedScreenFrame.x) / focusedScreenFrame.w) * nextScreenFrame.w) + nextScreenFrame.x)
  windowFrame.y = ((((windowFrame.y - focusedScreenFrame.y) / focusedScreenFrame.h) * nextScreenFrame.h) + nextScreenFrame.y)
  windowFrame.h = ((windowFrame.h / focusedScreenFrame.h) * nextScreenFrame.h)
  windowFrame.w = ((windowFrame.w / focusedScreenFrame.w) * nextScreenFrame.w)

  -- Set the focused window's new frame dimensions
  focusedWindow:setFrame(windowFrame)
end)

function focus_app_tab(app, name)
  return function()
    hs.osascript.javascript([[
    (function() {
      var brave = Application(']] .. app .. [[');
      brave.activate();
      for (win of brave.windows()) {
        var tabIndex =
          win.tabs().findIndex(tab => tab.name().match(/]] .. name .. [[/));
        if (tabIndex != -1) {
          win.activeTabIndex = (tabIndex + 1);
          win.index = 1;
        }
      }
    })();
    ]])
  end
end

-- hs.hotkey.bind({"alt", "cmd"}, "Left", focus_app_tab('Google Chrome', '.*Inbox.*'));
