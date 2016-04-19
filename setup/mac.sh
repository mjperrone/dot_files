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

# un-hide bottom dock bar after 4 seconds of hovering over the bottom; I rarely
# use it and it takes up screen real estate
defaults write com.apple.Dock autohide-delay -float 0

# restart dock to propogate the changes:
killall Dock

# don't make the cursor big when you shake the mouse a bit
defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool YES

# shhhhhhhhhh on startup.
sudo nvram SystemAudioVolume=" "

# show the dock after hovering for 2 whole seconds cuz fuck the dock.
defaults write com.apple.Dock autohide-delay -float 2 && killall Dock

sudo easy_install pip
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap neovim/homebrew-neovim
brew install --HEAD neovim
brew install ag
brew install reattach-to-user-namespace # for allowing tmux to copy into system clipboard
brew install tmux

brew cask install clipmenu # clipboard history Kreygasm
brew cask install iterm2


echo "run `open Development/solarized/iterm2-colors-solarized/Solarized\ Dark.itermcolors` then Preferences>Profile>Colors>Load Presets..."
open location "http://iterm2.com/downloads.html"
