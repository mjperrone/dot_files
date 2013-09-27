#!/usr/bin/env bash

export OLD_DOT_FILES=~/old_dot_files
if [ -d "$OLD_DOT_FILES" ]; then
    exit 0 #don't overwrite saved dotfiles!
fi
mkdir $OLD_DOT_FILES

# save old dot files
for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc
do
    if [ -f ~/$f ]; then
        mv ~/$f $OLD_DOT_FILES/$f
    fi
done
if [ -d ~/$f ]; then
    mv  ~/.vim $OLD_DOT_FILES/.vim
fi


#have .bashrc point to the one in dot_files
cat << EOF > ~/.bashrc
    source ~/dot_files/.bashrc
EOF
cat << EOF > ~/.bash_profile
    source ~/.bashrc
EOF
#copy over the things that have to be, link the others
cp ~/dot_files/.inputrc ~/.inputrc
cp ~/dot_files/.vimrc ~/.vimrc
cp ~/dot_files/.vrapperrc ~/.vrapperrc
cp ~/dot_files/.editrc ~/.editrc
ln -s ~/dot_files/.vim ~/.vim

#apply the changes! (this is why you have to run source ~/dot_files/setup/setup.sh and not sh ~/dot_files/setup/setup.sh
source ~/.bashrc
