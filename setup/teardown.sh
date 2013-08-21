#!/usr/bin/env bash
export OLD_DOT_FILES=~/old_dot_files
if [ ! -d $OLD_DOT_FILES ]; then
    exit 0
fi

for f in .bashrc .bash_profile .inputrc .vimrc
do
    if [ -f $OLD_DOT_FILES/$f ]; then
        mv $OLD_DOT_FILES/$f ~/$f
    fi
done
if [ -d $OLD_DOT_FILES/.vim ]; then
    mv -r $OLD_DOT_FILES/.vim ~/
else
    rm -rf ~/.vim
fi

rm -rf $OLD_DOT_FILES
