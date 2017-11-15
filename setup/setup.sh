#!/usr/bin/env bash

export DOT_FILES=~/dot_files
export OLD_DOT_FILES=~/old_dot_files


# link everything to the relevant file in $DOT_FILES
# this is the interface with the programs expecting config files
for f in .shellrc .inputrc .editrc .vimrc .vrapperrc .gitconfig .gitignore_global .vim .zshrc .tmux.conf .ignore .psqlrc
do
    ln -s $DOT_FILES/$f ~/$f
done
ln -s $DOT_FILES/.bashrc ~/.bash_profile #make .bash_profile+.bashrc the same
# the difference is documented at http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html, but I want both to do the same thing
ln -s $DOT_FILES/.vim ~/.nvim
mkdir -p ~/.config/nvim/
ln -s $DOT_FILES/.vimrc ~/.config/nvim/init.vim
mkdir -p ~/.ipython/profile_default/
ln -s $DOT_FILES/ipython_config.py ~/.ipython/profile_default/ipython_config.py

#apply the changes to the current shell instance!
#(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
if [ ! -n $BASH_VERSION ]; then
    source $DOT_FILES/.bashrc
elif [ ! -n $ZSH_VERSION ]; then
    source $DOT_FILES/.zshrc
fi


# make the development folder and checkout some stuff
mkdir -p ~/Development/
if [ ! -d ~/Development/solarized ]; then
    git clone https://github.com/altercation/solarized.git ~/Development/solarized
fi


# set up vim to install it's packages (see .vimrc where this is defined)
vim -c ":call InstallVundle() | q | q"
