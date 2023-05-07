#!/bin/zsh

#show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles TRUE
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# restart it so it can pick up the new config
killall Finder

# autohide the dock
defaults write com.apple.dock autohide -bool true
# un-hide bottom dock bar instantly; no animation
defaults write com.apple.dock autohide-time-modifier -int 0
# show the dock after hovering for 2 whole seconds cuz fuck the dock.
defaults write com.apple.Dock autohide-delay -float 1
# use the scale effect to minimize windows to the dock because it's faster
defaults write com.apple.Dock mineffect -string scale
# restart it so it can pick up the new config
killall Dock

# don't make the cursor big when you shake the mouse a bit
defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool YES

# Don't make the startup sound by setting volume down
sudo nvram SystemAudioVolume=" "

# Show battery percent and volume in menu bar
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Volume.menu"

# 24hr clock with date in the menu bar
defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm'

# dark mode
sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true


mkdir -p ~/files/Downloads
mkdir -p ~/files/Documents
mkdir -p ~/files/Photos
mkdir -p ~/files/Screenshots
defaults write com.apple.screencapture location ~/files/Screenshots

echo 'set the battery percent, volume control, and bluetooth to show in the menubar using the control center'
echo 'set caps lock to escape'
