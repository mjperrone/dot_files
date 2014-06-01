#!/usr/bin/env bash

export DOT_FILES=~/dot_files

#trigger all those other dot files!
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi
if [ -f $DOT_FILES/completion/completionrc ]; then
    source $DOT_FILES/completion/completionrc
fi
for f in .bash_aliases .bash_functions .bash_prompt .bash_secrets .git_functions
do
    if [ -f $DOT_FILES/$f ]; then
        source $DOT_FILES/$f
    fi
done

#branchy pathy stuff:
export PATH=/usr/local/Cellar/ctags/5.8/bin:$PATH
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
export PATH=$PATH:/usr/local/texlive/2013basic/bin/x86_64-darwin
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.3/bin #allows createdb, dropdb,.. to be found
export PATH=$PATH:/usr/local/Cellar/go/1.2/libexec/bin
export PYTHONPATH=$HOME/Development/averagexkcd
export AVERAGE_XKCD_CACHE_PATH=$HOME/Development/ax_path

export EDITOR="vim"

#bash settings
export HISTFILESIZE=30000 #store 30k of bash command history, you know, in case
export HISTCONTROL=ignoredups
shopt -s histappend #append to the bash history file rather than overwriting it
shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
export MANPAGER="less -X" # Don’t clear the screen after quitting a manual page
complete -cf sudo man

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


export ARCHFLAGS="-arch x86_64"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

eval "$(rbenv init -)"
