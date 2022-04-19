#!/bin/zsh

# Programs are expecting this config to be in the home directory. We want to store the source
# of truth in this repo directory, not the home directory, so we link everything up so they
# can be found there while living here.
for f in .editrc .gitconfig .gitignore_global .inputrc .psqlrc .tmux.conf .zshrc 
do
    ln -s -i $DOT_FILES/$f ~/$f
done

# Config that needs to be other than home:
mkdir -p ~/.hammerspoon/
ln -s -i $DOT_FILES/init.lua ~/.hammerspoon/init.lua
ln -s -i $DOT_FILES/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
mkdir -p ~/.ipython/profile_default/
ln -s -i $DOT_FILES/ipython_config.py ~/.ipython/profile_default/ipython_config.py

#apply the changes to the current shell instance!
#(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
source $DOT_FILES/.zshrc
echo 'source $DOT_FILES/.zshrc'
source $DOT_FILES/setup/vscode.sh
