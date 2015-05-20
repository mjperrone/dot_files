defaults write com.apple.finder AppleShowAllFiles TRUE #show hidden files in finder
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
sudo easy_install pip
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap neovim/homebrew-neovim
brew install --HEAD neovim
brew install ag
sudo nvram SystemAudioVolume=" " # shhhhhhhhhh on startup.
echo "install iterm2, then run `open Development/solarized/iterm2-colors-solarized/Solarized\ Dark.itermcolors` then Preferences>Profile>Colors>Load Presets..."
open location "http://iterm2.com/downloads.html"
