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
local resizeDebugLogPath = '/tmp/hammerspoon-resize-debug.log'

local function formatUnit(windowUnit)
  if not windowUnit then return 'nil' end
  return string.format('{x=%.4f,y=%.4f,w=%.4f,h=%.4f}', windowUnit.x, windowUnit.y, windowUnit.w, windowUnit.h)
end

local function formatFrame(frame)
  return string.format('{x=%.0f,y=%.0f,w=%.0f,h=%.0f}', frame.x, frame.y, frame.w, frame.h)
end

local function windowName(window)
  local app = window:application()
  local appName = app and app:name() or 'unknown app'
  local title = window:title() or ''
  return string.format('%s "%s"', appName, title)
end

local function logResizeDebug(message)
  local line = string.format('[%s] %s', os.date('%Y-%m-%d %H:%M:%S'), message)
  hs.printf('[resize-debug] %s', message)

  local file = io.open(resizeDebugLogPath, 'a')
  if file then
    file:write(line .. '\n')
    file:close()
  end
end

local function addResizeEdge(edges, edge)
  if edge < -0.01 or edge > 1.01 then return end

  edge = math.max(0.00, math.min(1.00, edge))

  for _, existingEdge in ipairs(edges) do
    if nearlyEqual(existingEdge, edge) then return end
  end

  table.insert(edges, edge)
end

local function resizeEdgesForWindow(window, includeGridEdges)
  local edges = {}
  local screen = window:screen()
  local screenId = screen:id()
  local screenFrame = screen:frame()

  if includeGridEdges then
    for index = 0, math.floor(1.00 / resizeStep) do
      addResizeEdge(edges, index * resizeStep)
    end
    addResizeEdge(edges, 1.00)
  end

  for _, otherWindow in ipairs(hs.window.visibleWindows()) do
    if otherWindow:id() ~= window:id() and otherWindow:screen():id() == screenId then
      local frame = otherWindow:frame()
      addResizeEdge(edges, (frame.x - screenFrame.x) / screenFrame.w)
      addResizeEdge(edges, (frame.x + frame.w - screenFrame.x) / screenFrame.w)
    end
  end

  table.sort(edges)
  return edges
end

local function nextResizeEdgeFromEdges(edges, currentEdge, direction, minEdge, maxEdge)
  if direction > 0 then
    for _, edge in ipairs(edges) do
      if edge >= minEdge and edge <= maxEdge and edge > currentEdge + 0.01 then
        return edge
      end
    end
  else
    for index = #edges, 1, -1 do
      local edge = edges[index]
      if edge >= minEdge and edge <= maxEdge and edge < currentEdge - 0.01 then
        return edge
      end
    end
  end

  return currentEdge
end

local function nextResizeEdge(window, currentEdge, direction, minEdge, maxEdge)
  local windowEdge = nextResizeEdgeFromEdges(resizeEdgesForWindow(window, false), currentEdge, direction, minEdge, maxEdge)
  if not nearlyEqual(windowEdge, currentEdge) then return windowEdge, 'window' end

  return nextResizeEdgeFromEdges(resizeEdgesForWindow(window, true), currentEdge, direction, minEdge, maxEdge), 'grid'
end

local function logResizeWindowState(window, delta, activeUnit, targetUnit, branchName, selectedEdge, selectedSource)
  local screen = window:screen()
  local screenId = screen:id()
  local screenFrame = screen:frame()
  local windowFrame = window:frame()
  local direction = delta > 0 and 'positive' or 'negative'

  logResizeDebug(string.format(
    'resize delta=%s branch=%s selectedEdge=%s selectedSource=%s focused=%s frame=%s screen=%s unit=%s target=%s',
    direction,
    branchName or 'none',
    selectedEdge and string.format('%.4f', selectedEdge) or 'nil',
    selectedSource or 'nil',
    windowName(window),
    formatFrame(windowFrame),
    formatFrame(screenFrame),
    formatUnit(activeUnit),
    formatUnit(targetUnit)
  ))

  for _, otherWindow in ipairs(hs.window.visibleWindows()) do
    if otherWindow:id() ~= window:id() and otherWindow:screen():id() == screenId then
      local frame = otherWindow:frame()
      local leftEdge = (frame.x - screenFrame.x) / screenFrame.w
      local rightEdge = (frame.x + frame.w - screenFrame.x) / screenFrame.w
      logResizeDebug(string.format(
        'candidate window=%s frame=%s leftEdge=%.4f rightEdge=%.4f',
        windowName(otherWindow),
        formatFrame(frame),
        leftEdge,
        rightEdge
      ))
    end
  end
end

local function moveFocusedWindow(targetUnit)
  local window = hs.window.focusedWindow()
  if window then window:move(targetUnit, nil, true) end
end

local function resizeSnappedWindow(delta)
  local window = hs.window.focusedWindow()
  if not window then return end

  local activeUnit = currentUnit(window)
  local targetUnit = nil
  local branchName = nil
  local selectedEdge = nil
  local selectedSource = nil

  if sameUnit(activeUnit, maximum) and delta > 0 then
    branchName = 'max-positive'
    local nextLeftEdge, edgeSource = nextResizeEdge(window, activeUnit.x, delta, 0.00, 1.00 - resizeStep)
    selectedEdge = nextLeftEdge
    selectedSource = edgeSource
    targetUnit = {
      x = nextLeftEdge,
      y = activeUnit.y,
      w = 1.00 - nextLeftEdge,
      h = activeUnit.h,
    }
  elseif sameUnit(activeUnit, maximum) and delta < 0 then
    branchName = 'max-negative'
    local nextRightEdge, edgeSource = nextResizeEdge(window, activeUnit.x + activeUnit.w, delta, resizeStep, 1.00)
    selectedEdge = nextRightEdge
    selectedSource = edgeSource
    targetUnit = {
      x = 0.00,
      y = activeUnit.y,
      w = nextRightEdge,
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x, 0.00) then
    branchName = 'left-edge'
    local nextRightEdge, edgeSource = nextResizeEdge(window, activeUnit.x + activeUnit.w, delta, resizeStep, 1.00)
    selectedEdge = nextRightEdge
    selectedSource = edgeSource
    targetUnit = {
      x = 0.00,
      y = activeUnit.y,
      w = nextRightEdge,
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x + activeUnit.w, 1.00) then
    branchName = 'right-edge'
    local nextLeftEdge, edgeSource = nextResizeEdge(window, activeUnit.x, delta, 0.00, 1.00 - resizeStep)
    selectedEdge = nextLeftEdge
    selectedSource = edgeSource
    targetUnit = {
      x = nextLeftEdge,
      y = activeUnit.y,
      w = 1.00 - nextLeftEdge,
      h = activeUnit.h,
    }
  end

  logResizeWindowState(window, delta, activeUnit, targetUnit, branchName, selectedEdge, selectedSource)
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
