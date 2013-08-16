#!/usr/bin/env bash
export OLD_DOT_FILES=~/old_dot_files
if [ ! -d $OLD_DOT_FILES ]; then
    exit 0
fi


for f in .bashrc .bash_profile .inputrc .vimrc
do
    if [ -f $OLD_DOT_FILES/$f ]; then
        cp $OLD_DOT_FILES/$f ~/$f
    fi
done
rm -rf $OLD_DOT_FILES
