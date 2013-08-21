#!/usr/bin/env bash
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
done
if [ -d ~/$f ]; then
    mv  ~/.vim $OLD_DOT_FILES/.vim
fi



cat << EOF > ~/.bashrc
    source ~/dot_files/.bashrc
EOF
cat << EOF > ~/.bash_profile
    source ~/.bashrc
EOF
cp ~/dot_files/.inputrc ~/.inputrc
cp ~/dot_files/.vimrc ~/.vimrc
cp -r ~/dot_files/.vim ~/

source ~/.bashrc
