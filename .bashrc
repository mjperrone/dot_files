#!/usr/bin/env bash

export DOT_FILES=~/dot_files

#trigger all those other dot files!
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi
if [ -f $DOT_FILES/completion/completionrc ]; then
    source $DOT_FILES/completion/completionrc
fi
for f in .bash_secrets .bash_aliases .bash_functions .bash_colors .bash_prompt .git_functions .bash_path
do
    if [ -f $DOT_FILES/$f ]; then
        source $DOT_FILES/$f
    fi
done


#bash settings
export HISTFILESIZE=30000 #store 30k of bash command history, you know, in case
export HISTCONTROL=ignoredups
shopt -s histappend #append to the bash history file rather than overwriting it
shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
shopt -s checkwinsize  #checks window size after each command, saves formatting madness
shopt -s dotglob # includes .* files in *
#bash >=4.0 #shopt -s globstar #** is directory-recursive filename expansion
complete -cf sudo man

#virtualenv stuff
export WORKON_HOME=~/.virtualenvs
[ -e /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

#https://github.com/joelthelion/autojump
[[ -s ~/.autojump/etc/profile.d/autojump.bash ]] && . ~/.autojump/etc/profile.d/autojump.bash


export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export ACK_OPTIONS="--ignore-dir=app/*/spec/*"

eval "$(rbenv init -)"
