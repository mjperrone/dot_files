#!/usr/bin/env bash
export OLD_DOT_FILES=~/old_dot_files
if [ ! -d $OLD_DOT_FILES ]; then
    echo "There isn't any old_dot_files folder, so we're going to just leave things be."
else
    
    #move the old stuff back, overwriting whatever
    for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc .bash_prompt .bash_history
    do
        if [ -h ~/$f ] || [ -e ~/$f ] ; then
            echo "$f exists, 'rm ~/$f'"
            rm ~/$f
        else
            echo "$f doesn't exist"
        fi
        if [ -f $OLD_DOT_FILES/$f ]; then
            mv $OLD_DOT_FILES/$f ~/$f
        fi
    done
    rm -f ~/.vim
    rm -f ~/.bash_directory_history
    
    if [ -d $OLD_DOT_FILES/.vim ]; then
        mv $OLD_DOT_FILES/.vim ~/.vim
    fi
    
    #delete what's left
    rm -rf $OLD_DOT_FILES
fi
