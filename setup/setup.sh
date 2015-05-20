#!/usr/bin/env bash

export DOT_FILES=~/dot_files
export OLD_DOT_FILES=~/old_dot_files
if [ -d "$OLD_DOT_FILES" ]; then
    echo "It looks like an old_dot_files directory exists, I'm going to need you to delete that manually if you really want to do this, as it would overwrite that."
else
    mkdir $OLD_DOT_FILES

    # save old dot files
    for f in .bashrc .bash_profile .bash_prompt .bash_colors .inputrc .editrc .vimrc .vrapperrc .bash_history .gitconfig .gitignore_global .zshrc
    do
        if [ -e ~/$f ]; then
            mv ~/$f $OLD_DOT_FILES/$f
        fi
    done
    if [ -d ~/$f ]; then
        mv  ~/.vim $OLD_DOT_FILES/.vim
    fi

    #link everything to the relevant file in $DOT_FILES
    for f in .bashrc .inputrc .editrc .vimrc .vrapperrc .gitconfig .gitignore_global .vim .zshrc .tmux.conf
    do
        ln -s $DOT_FILES/$f ~/$f
    done
    ln -s $DOT_FILES/.bashrc ~/.bash_profile #make .bash_profile+.bashrc the same
    # the difference is documented at http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html, but I want both to do the same thing
    ln -s $DOT_FILE/.vim ~/.nvim
    ln -s $DOT_FILE/.vimrc ~/.nvimrc

    #apply the changes to the current shell instance!
    #(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
    source ~/.bashrc


    # make the development folder and checkout some stuff
    mkdir ~/Development/
    git clone https://github.com/altercation/solarized.git ~/Development/solarized

    vim -c ":call InstallVundle() | q | q"
fi
