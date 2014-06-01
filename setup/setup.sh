#!/usr/bin/env bash

export DOT_FILES=~/dot_files
export OLD_DOT_FILES=~/old_dot_files
if [ -d "$OLD_DOT_FILES" ]; then
    echo "It looks like an old_dot_files directory exists, I'm going to need you to delete that manually if you really want to do this, as it would overwrite that."
else
    mkdir $OLD_DOT_FILES

    # save old dot files
    for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc .bash_prompt .bash_history
    do
        if [ -e ~/$f ]; then
            mv ~/$f $OLD_DOT_FILES/$f
        fi
    done
    if [ -d ~/$f ]; then
        mv  ~/.vim $OLD_DOT_FILES/.vim
    fi
    
    #link everything to the relevant file in $DOT_FILES?
    for f in .bashrc .bash_prompt .bash_colors .inputrc .editrc .vimrc .vim .vrapperrc 
    do
        ln -s $DOT_FILES/$f ~/$f
    done
    ln -s $DOT_FILES/.bashrc ~/.bash_profile #make .bash_profile+.bashrc the same
    # the difference is documented in , but I want both to do the same thing
    
    #apply the changes to the current shell instance!
    #(this is why you ought to run source $DOT_FILES/setup/setup.sh and not just sh $DOT_FILES/setup/setup.sh)
    source ~/.bashrc
fi
