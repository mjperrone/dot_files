-- Hammerspoon config, lives in ~/.hammerspoon/init.lua

hs.window.animationDuration = 0
units = {
  right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50        = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },

  topleft       = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  topright      = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  botleft       = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  botright      = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },

  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 }

}

mash = { 'ctrl', 'option', 'cmd' }
hs.hotkey.bind(mash, 'l', function() hs.window.focusedWindow():move(units.right50,    nil, true) end)
hs.hotkey.bind(mash, 'h', function() hs.window.focusedWindow():move(units.left50,     nil, true) end)
hs.hotkey.bind(mash, 'k', function() hs.window.focusedWindow():move(units.top50,      nil, true) end)
hs.hotkey.bind(mash, 'j', function() hs.window.focusedWindow():move(units.bot50,      nil, true) end)

hs.hotkey.bind(mash, 'u', function() hs.window.focusedWindow():move(units.topleft,      nil, true) end)
hs.hotkey.bind(mash, 'i', function() hs.window.focusedWindow():move(units.topright,      nil, true) end)
hs.hotkey.bind(mash, 'o', function() hs.window.focusedWindow():move(units.botright,      nil, true) end)
hs.hotkey.bind(mash, 'p', function() hs.window.focusedWindow():move(units.botleft,      nil, true) end)

hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.maximum,    nil, true) end)



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


local hyper = { "cmd", "alt" }

local applicationHotkeys = {
  space = 'Google Chrome', -- also need to disable the command alt space mac shortcut to search something in finder
  v = 'Visual Studio Code',
  c = 'Firefox',
  d = 'Spotify', -- also need to Turn Dock Hiding Off under launchpad in keyboard settings
  f = 'Signal',
}
for key, app in pairs(applicationHotkeys) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end
hs.hotkey.bind(hyper, , focus_app_tab('Firefox', '.*Task List.*'));