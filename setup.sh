#! /bin/bash
export OLD_DOT_FILES=~/old_dot_files
if [ -d "$OLD_DOT_FILES" ]; then
    exit 0
fi

mkdir $OLD_DOT_FILES


for f in .bashrc .bash_profile .inputrc .vimrc
do
    if [ -f ~/$f ]; then
        mv ~/$f $OLD_DOT_FILES/$f
    fi
    cp ~/dot_files/$f ~/$f
done
