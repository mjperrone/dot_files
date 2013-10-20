#!/usr/bin/env bash
export OLD_DOT_FILES=~/old_dot_files
if [ ! -d $OLD_DOT_FILES ]; then
    exit 0 #if there isn't any old stuff, then don't go back
fi

#move the old stuff back, overwriting whatever
for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc .bash_prompt
do
    if [ -f $OLD_DOT_FILES/$f ]; then
        mv $OLD_DOT_FILES/$f ~/$f
    fi
done
rm ~/.vim
if [ -d $OLD_DOT_FILES/.vim ]; then
    mv $OLD_DOT_FILES/.vim ~/.vim
fi

#delete what's left
rm -rf $OLD_DOT_FILES
