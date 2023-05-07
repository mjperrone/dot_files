#!/bin/zsh

source $DOT_FILES/.shell_exports

# The soure of truth are the files in this repo. Software expects config in other places.
# So we use links to connect the dots.

# Those that have to be in home:
for f in .editrc .zshrc
do
    ln -s -i $DOT_FILES/$f ~/$f
done

# XDG root compliant apps (https://xdgbasedirectoryspecification.com/)
mkdir -p ~/.config/git
ln -s -i $DOT_FILES/.gitignore_global $XDG_CONFIG_HOME/git/ignore
ln -s -i $DOT_FILES/.gitconfig $XDG_CONFIG_HOME/git/config

# non-XDG compliant, but works with env vars (see .shell_exports)
mkdir -p $XDG_CONFIG_HOME/readline
ln -s -i $DOT_FILES/.inputrc $INPUTRC

mkdir -p $XDG_STATE_HOME

mkdir -p $XDG_CONFIG_HOME/pg
ln -s -i $DOT_FILES/.psqlrc $PSQLRC

# for zsh HISTFILE, see .zshrc
mkdir -p $XDG_STATE_HOME"/zsh

# Hammerspoon requires this spelcial config: https://github.com/Hammerspoon/hammerspoon/issues/2175
mkdir $XDG_CONFIG_HOME/hammerspoon
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$XDG_CONFIG_HOME/hammerspoon/init.lua"
ln -s -i $DOT_FILES/init.lua $XDG_CONFIG_HOME/hammerspoon/init.lua

# Config that needs to be other than home or XDG root:

mkdir -p ~/.hammerspoon/
ln -s -i $DOT_FILES/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json

#apply the changes to the current shell instance!
#(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
source $DOT_FILES/.zshrc
echo 'source $DOT_FILES/.zshrc'
source $DOT_FILES/setup/vscode.sh
