#!/usr/bin/env bash

export DOT_FILES=~/dot_files
export OLD_DOT_FILES=~/old_dot_files
if [ -d "$OLD_DOT_FILES" ]; then
    exit 0 #don't overwrite saved dotfiles!
fi
mkdir $OLD_DOT_FILES

# save old dot files
for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc .bash_prompt .bash_history
do
    if [ -e ~/$f ]; then
        mv ~/$f $OLD_DOT_FILES/$f
        echo "I just moved $f"
    fi
done
if [ -d ~/$e ]; then
    mv  ~/.vim $OLD_DOT_FILES/.vim
fi

#link everything to the relevant file in ~/dot+files/
ln -s $DOT_FILES/.bashrc ~/.bashrc
ln -s $DOT_FILES/.bashrc ~/.bash_profile #make .bash_profile+.bashrc the same
ln -s $DOT_FILES/.inputrc ~/.inputrc
ln -s $DOT_FILES/.vimrc ~/.vimrc
ln -s $DOT_FILES/.vrapperrc ~/.vrapperrc
ln -s $DOT_FILES/.editrc ~/.editrc
ln -s $DOT_FILES/.vim ~/.vim
ln -s $DOT_FILES/.bash_prompt ~/.bash_prompt

#apply the changes to the current shell instance!
#(this is why you have to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh
source ~/.bashrc
