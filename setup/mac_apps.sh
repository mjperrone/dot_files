#!/bin/zsh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh
brew install tmux
brew install thefuck
brew install hammerspoon

brew install --cask notion
brew install --cask spotify

echo "Open hammerspoon, set it to launch at login, give it accessibility permissions"