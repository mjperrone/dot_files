#!/usr/bin/env bash
export OLD_DOT_FILES=~/old_dot_files
if [ ! -d $OLD_DOT_FILES ]; then
    echo "There isn't any old_dot_files folder, so we're going to just leave things be."
else
    # move the old stuff back, overwriting whatever
    for f in .bashrc .bash_profile .inputrc .vimrc .vrapperrc .editrc .bash_prompt .bash_history .gitconfig .gitignore_global .zshrc .tmux.conf .shellrc .shell_colors .shell_functions .shell_aliases .shell_path
    do
        if [ -h ~/$f ] || [ -e ~/$f ] ; then
            rm ~/$f
        fi
        if [ -f $OLD_DOT_FILES/$f ]; then
            mv $OLD_DOT_FILES/$f ~/$f
        fi
    done
    rm -f ~/.vim

    if [ -d $OLD_DOT_FILES/.vim ]; then
        mv $OLD_DOT_FILES/.vim ~/.vim
    fi

    #delete what's left
    rm -rf $OLD_DOT_FILES
fi
