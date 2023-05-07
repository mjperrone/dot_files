#!/bin/zsh

source $DOT_FILES/.shell_exports

# Programs are expecting this config to be in the home directory. We want to store the source
# of truth in this repo directory, not the home directory, so we link everything up so they
# can be found there while living here.
for f in .editrc .gitconfig .psqlrc .zshrc
do
    ln -s -i $DOT_FILES/$f ~/$f
done

# XDG root compliant apps (https://xdgbasedirectoryspecification.com/)
mkdir -p ~/.config/git
ln -s -i $DOT_FILES/.gitignore_global ~/.config/git/ignore
ln -s -i $DOT_FILES/.gitconfig ~/.config/git/config

# non-XDG compliant but provides a way to override:
mkdir -p $XDG_CONFIG_HOME/readline
ln -s -i $DOT_FILES/.inputrc $INPUTRC

# Config that needs to be other than home or XDG root:
mkdir -p ~/.hammerspoon/
ln -s -i $DOT_FILES/init.lua ~/.hammerspoon/init.lua
ln -s -i $DOT_FILES/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json

#apply the changes to the current shell instance!
#(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
source $DOT_FILES/.zshrc
echo 'source $DOT_FILES/.zshrc'
source $DOT_FILES/setup/vscode.sh
