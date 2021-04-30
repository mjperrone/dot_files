#show hidden files in finder
defaults write com.apple.finder AppleShowAllFiles TRUE

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

tell application "System Events" to set the autohide of the dock preferences to true

# un-hide bottom dock bar instantly; no animation
defaults write com.apple.dock autohide-time-modifier -int 0

# show the dock after hovering for 2 whole seconds cuz fuck the dock.
defaults write com.apple.Dock autohide-delay -float 2
killall Dock

# don't make the cursor big when you shake the mouse a bit
defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool YES

# shhhhhhhhhh on startup.
sudo nvram SystemAudioVolume=" "


# Show battery percent and volume in menu bar
sudo defaults write com.apple.menuextra.battery ShowPercent YES
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Volume.menu"


# 24hr clock with date in the menu bar
defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm'


mkdir -p ~/code
mkdir -p ~/files/Downloads
mkdir -p ~/files/Documents
mkdir -p ~/files/Photos
mkdir -p ~/files/Screenshots
defaults write com.apple.screencapture location ~/files/Screenshots

brew install gh
brew install tmux
brew install zsh
brew install ag
brew install watchman

watchman watch-project $DOT_FILES/../notes/
watchman -j < $DOT_FILES/watchman/autocommit-notes.watchman.json

brew cask install clipmenu # clipboard history Kreygasm
brew cask install iterm2
brew cask install postman
brew cask install hammerstpoon

#brew cask install atom
#apm install vim-mode-plus
#apm install ex-mode
#apm install atom-ide-ui # dependency for atom-typescript
#apm install atom-typescript
#apm install goto-last-edit

ln -s $DOT_FILES/iterm_profiles.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/iterm_profiles.json"

echo "run `open ~/code/external/altercation/solarized/iterm2-colors-solarized/Solarized\ Dark.itermcolors` then Preferences>Profile>Colors>Load Presets..."
open location "http://iterm2.com/downloads.html"


# Manual
# Change chrome default download locatoin
