-- Hammerspoon config

hs.window.animationDuration = 0

opencodeStatus = {
  url = 'http://127.0.0.1:4097',
  port = 4097,
  command = os.getenv('HOME') .. '/.opencode/bin/opencode',
  logPath = os.getenv('HOME') .. '/Library/Logs/opencode-server-hammerspoon.log',
  healthcheckPath = os.getenv('HOME') .. '/code/mjperrone/dot_files/scripts/opencode-healthcheck.py',
  enabledHostnames = {
    ['mike’s MacBook Pro'] = true,
    ["mike's MacBook Pro"] = true,
  },
  isRunning = false,
  healthStatus = 'unknown',
  healthMessage = 'healthcheck not run',
  lastCheckedAt = nil,
  healthLastCheckedAt = nil,
  menubar = nil,
}

local setOpencodeMenuTitle
local updateOpencodeMenu
local checkOpencodeStatus
local checkOpencodeHealth

local function shellQuote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function openOpencode()
  hs.urlevent.openURL(opencodeStatus.url)
end

local function tableHasKey(table, key)
  return key and table[key] == true
end

local function shouldShowOpencodeMenu()
  return tableHasKey(opencodeStatus.enabledHostnames, hs.host.localizedName())
end

local function firstHealthIssue(output)
  for line in (output or ''):gmatch('[^\r\n]+') do
    if line:match('^FAIL ') then
      return line
    end

    if line:match('^WARN .+: MCP not configured')
        or line:match('^WARN .+: MCP configured but disabled')
        or line:match('^WARN .+: unknown MCP type')
        or line:match('^FAIL .+: command not found')
        or line:match('^FAIL .+: executable missing')
        or line:match('^FAIL .+: remote MCP missing URL') then
      return line
    end
  end

  return nil
end

local function startOpencodeServer()
  if opencodeStatus.isRunning then
    hs.alert.show('OpenCode server is already running')
    openOpencode()
    return
  end

  local command = table.concat({
    shellQuote(opencodeStatus.command),
    'serve',
    '--port',
    tostring(opencodeStatus.port),
    '>',
    shellQuote(opencodeStatus.logPath),
    '2>&1',
    '&',
  }, ' ')

  hs.execute(command, true)
  hs.alert.show('Starting OpenCode server')
  hs.timer.doAfter(1, checkOpencodeStatus)
  hs.timer.doAfter(3, checkOpencodeStatus)
end

local function stopOpencodeServer(callback)
  local command = string.format('lsof -ti tcp:%d | xargs kill 2>/dev/null || true', opencodeStatus.port)
  hs.task.new('/bin/zsh', function()
    hs.timer.doAfter(1, function()
      checkOpencodeStatus()
      if callback then callback() end
    end)
  end, { '-lc', command }):start()
end

local function restartOpencodeServer()
  hs.alert.show('Restarting OpenCode server')
  stopOpencodeServer(function()
    opencodeStatus.isRunning = false
    setOpencodeMenuTitle()
    updateOpencodeMenu()
    startOpencodeServer()
  end)
end

function setOpencodeMenuTitle()
  if not opencodeStatus.menubar then return end

  if not opencodeStatus.isRunning then
    opencodeStatus.menubar:setTitle(hs.styledtext.new('OC', {
      color = { red = 1, green = 0.18, blue = 0.18, alpha = 1 },
    }))
  elseif opencodeStatus.healthStatus == 'warning' then
    opencodeStatus.menubar:setTitle(hs.styledtext.new('OC', {
      color = { red = 1, green = 0.78, blue = 0.18, alpha = 1 },
    }))
  else
    opencodeStatus.menubar:setTitle('OC')
  end
end

function updateOpencodeMenu()
  if not opencodeStatus.menubar then return end

  local status = opencodeStatus.isRunning and 'running' or 'not running'
  local lastChecked = opencodeStatus.lastCheckedAt and os.date('%H:%M:%S', opencodeStatus.lastCheckedAt) or 'never'
  local healthChecked = opencodeStatus.healthLastCheckedAt and os.date('%H:%M:%S', opencodeStatus.healthLastCheckedAt) or 'never'
  opencodeStatus.menubar:setTooltip('OpenCode local server is ' .. status .. '; health is ' .. opencodeStatus.healthStatus)
  opencodeStatus.menubar:setMenu({
    { title = 'OpenCode server is ' .. status, disabled = true },
    { title = 'Last checked: ' .. lastChecked, disabled = true },
    { title = 'Health: ' .. opencodeStatus.healthStatus, disabled = true },
    { title = opencodeStatus.healthMessage, disabled = true },
    { title = 'Health checked: ' .. healthChecked, disabled = true },
    { title = '-' },
    { title = 'Open local OpenCode', fn = openOpencode },
    { title = 'Copy local URL', fn = function() hs.pasteboard.setContents(opencodeStatus.url) end },
    { title = 'Start server', fn = startOpencodeServer, disabled = opencodeStatus.isRunning },
    { title = 'Restart server', fn = restartOpencodeServer },
    { title = '-' },
    { title = 'Refresh status', fn = function() checkOpencodeStatus() end },
    { title = 'Run healthcheck', fn = function() checkOpencodeHealth() end },
    { title = 'Reload Hammerspoon', fn = function() hs.reload() end },
  })
end

function checkOpencodeStatus()
  hs.http.asyncGet(opencodeStatus.url, nil, function(status)
    opencodeStatus.isRunning = status ~= nil and status >= 200 and status < 500
    opencodeStatus.lastCheckedAt = os.time()
    setOpencodeMenuTitle()
    updateOpencodeMenu()
  end)
end

function checkOpencodeHealth()
  if not hs.fs.attributes(opencodeStatus.healthcheckPath) then
    opencodeStatus.healthStatus = 'warning'
    opencodeStatus.healthMessage = 'healthcheck script missing'
    opencodeStatus.healthLastCheckedAt = os.time()
    setOpencodeMenuTitle()
    updateOpencodeMenu()
    return
  end

  hs.task.new('/usr/bin/env', function(exitCode, stdout, stderr)
    local output = (stdout or '') .. '\n' .. (stderr or '')
    local issue = firstHealthIssue(output)

    opencodeStatus.healthLastCheckedAt = os.time()
    if exitCode ~= 0 then
      opencodeStatus.healthStatus = 'warning'
      opencodeStatus.healthMessage = issue or ('healthcheck failed with exit ' .. tostring(exitCode))
    elseif issue then
      opencodeStatus.healthStatus = 'warning'
      opencodeStatus.healthMessage = issue
    else
      opencodeStatus.healthStatus = 'ok'
      opencodeStatus.healthMessage = 'MCP setup ok'
    end

    setOpencodeMenuTitle()
    updateOpencodeMenu()
  end, { 'python3', opencodeStatus.healthcheckPath }):start()
end

if shouldShowOpencodeMenu() then
  opencodeStatus.menubar = hs.menubar.new()
  setOpencodeMenuTitle()
  updateOpencodeMenu()
  checkOpencodeStatus()
  checkOpencodeHealth()
  opencodeStatus.timer = hs.timer.doEvery(5, checkOpencodeStatus)
  opencodeStatus.healthTimer = hs.timer.doEvery(300, checkOpencodeHealth)
end

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
local resizeStep = 0.10

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
  return nextResizeEdgeFromEdges(resizeEdgesForWindow(window, true), currentEdge, direction, minEdge, maxEdge)
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

  if sameUnit(activeUnit, maximum) and delta > 0 then
    local nextLeftEdge = nextResizeEdge(window, activeUnit.x, delta, 0.00, 1.00 - resizeStep)
    targetUnit = {
      x = nextLeftEdge,
      y = activeUnit.y,
      w = 1.00 - nextLeftEdge,
      h = activeUnit.h,
    }
  elseif sameUnit(activeUnit, maximum) and delta < 0 then
    local nextRightEdge = nextResizeEdge(window, activeUnit.x + activeUnit.w, delta, resizeStep, 1.00)
    targetUnit = {
      x = 0.00,
      y = activeUnit.y,
      w = nextRightEdge,
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x, 0.00) then
    local nextRightEdge = nextResizeEdge(window, activeUnit.x + activeUnit.w, delta, resizeStep, 1.00)
    targetUnit = {
      x = 0.00,
      y = activeUnit.y,
      w = nextRightEdge,
      h = activeUnit.h,
    }
  elseif nearlyEqual(activeUnit.x + activeUnit.w, 1.00) then
    local nextLeftEdge = nextResizeEdge(window, activeUnit.x, delta, 0.00, 1.00 - resizeStep)
    targetUnit = {
      x = nextLeftEdge,
      y = activeUnit.y,
      w = 1.00 - nextLeftEdge,
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
bindCycle(mash, 'i', 'topright', ratios.corner)
bindCycle(mash, 'o', 'bottomright', ratios.corner)
bindCycle(mash, 'p', 'bottomleft', ratios.corner)
hs.hotkey.bind(mash, 't', function() hs.application.launchOrFocus('Linear') end)

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
