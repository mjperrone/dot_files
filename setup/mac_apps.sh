#!/bin/zsh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh
brew install tmux
brew install thefuck
brew install hammerspoon

brew install --cask caffeine
brew install --cask spotify
brew install --cask firefox
brew install --cask discord
brew install --cask signal
brew install --cask android-file-transfer
brew install --cask vlc
brew install --cask audacity

echo "Open hammerspoon, set it to launch at login, give it accessibility permissions"