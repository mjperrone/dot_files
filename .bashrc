#!/usr/bin/env bash

export DOT_FILES=~/dot_files

#trigger all those other dot files!
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi
if [ -f completion/completionrc ]; then
    source /etc/bashrc
fi
for f in .bash_aliases .bash_functions .bash_prompt .bash_secrets .git_functions
do
    if [ -f $DOT_FILES/$f ]; then
        source $DOT_FILES/$f
    fi
done

#branchy pathy stuff:
export BRANCH=trunk
export ORIGINAL_PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin
export ORIGINAL_PATH=$ORIGINAL_PATH:/usr/local/texlive/2013/bin/x86_64-darwin
export ORIGINAL_PATH=$ORIGINAL_PATH:/Applications/Postgres.app/Contents/MacOS/bin #allows createdb, dropdb,.. work
export PATH=/Users/mperrone/src/$BRANCH/bin:$ORIGINAL_PATH
export PYTHONPATH=/Users/mperrone/src/$BRANCH/lib
export MANPATH=/usr/local/texlive/2013/texmf-dist/doc/man:$MANPATH
export INFOPATH=/usr/local/texlive/2013/texmf-dist/doc/info:$INFOPATH

#bash settings
export HISTFILESIZE=30000 #store 30k of bash command history, you know, in case
export HISTCONTROL=ignoredups
shopt -s histappend #append to the bash history file rather than overwriting it

shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
export MANPAGER="less -X" # Don’t clear the screen after quitting a manual page

#postgres defaults
export PGPORT=5432
export PGHOST=localhost
unset PGUSER
unset PGPASSWORD

#virtualenv stuff
export WORKON_HOME=~/.virtualenvs
[ -e /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

#https://github.com/joelthelion/autojump
[[ -s ~/.autojump/etc/profile.d/autojump.bash ]] && . ~/.autojump/etc/profile.d/autojump.bash
