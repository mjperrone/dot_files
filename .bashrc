#!/usr/bin/env bash

export DOT_FILES=/Users/mperrone/code/mjperrone/dot_files

#trigger all those other dot files!
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi
source $DOT_FILES/.shellrc

# bash settings

export HISTFILESIZE=30000
export HISTCONTROL=ignoredups
shopt -s histappend #append to the bash history file rather than overwriting it
shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
shopt -s checkwinsize  #checks window size after each command, saves formatting madness
shopt -s dotglob # includes hidden .* files in *
if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    shopt -s globstar #** is directory-recursive filename expansion
fi
complete -cf sudo man

# Bash Prompt
# 0 21:24:02 mjperrone@mfa:~  $
# time name@location:~/working/dir (branch)$
export PS1="$? \[${_white}\]\t \[${_cyan}\]\u\[${_white}\]@\[${_yellow}\]\h\[${_reset}\]:\[${_blue}\]\w\[${_reset}\] \$(get_git_branch) \\$ "


export PATH="$HOME/.poetry/bin:$PATH"
