#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump: Gmail Inbox
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ✉️
# @raycast.packageName Vivaldi Navigation

# Documentation:
# @raycast.description Focus an existing Gmail inbox tab in Vivaldi, or open it if missing.
# @raycast.author Mike Perrone

set -euo pipefail

osascript <<'APPLESCRIPT'
set gmailInboxUrl to "https://mail.google.com/mail/u/0/#inbox"
set foundTab to false

tell application "Vivaldi"
  activate

  repeat with windowIndex from 1 to count of windows
    set currentWindow to window windowIndex
    repeat with tabIndex from 1 to count of tabs of currentWindow
      set currentTab to tab tabIndex of currentWindow
      set currentUrl to URL of currentTab
      set currentTitle to title of currentTab

      if currentUrl contains "mail.google.com/mail" then
        if currentUrl contains "#inbox" or currentTitle contains "Inbox" then
          set active tab index of currentWindow to tabIndex
          set index of currentWindow to 1
          set foundTab to true
          exit repeat
        end if
      end if
    end repeat

    if foundTab then exit repeat
  end repeat

  if not foundTab then
    if (count of windows) is 0 then
      make new window
    end if

    tell window 1
      make new tab with properties {URL:gmailInboxUrl}
      set active tab index to count of tabs
      set index to 1
    end tell
  end if
end tell
APPLESCRIPT
