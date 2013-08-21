#!/usr/bin/env bash
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

if [ -f ~/dot_files/.bash_aliases ]; then
    source ~/dot_files/.bash_aliases
fi

if [ -f ~/dot_files/.bash_functions ]; then
    source ~/dot_files/.bash_functions
fi

if [ -f ~/dot_files/bash_secrets ]; then
    source ~/dot_files/.bash_secrets
fi

if [ -f ~/dot_files/completion/completionrc ]; then
    source ~/dot_files/completion/completionrc
fi

if [ -f ~/dot_files/.git_functions ]; then
    source ~/dot_files/.git_functions
fi

export MANPATH=/usr/local/texlive/2013/texmf-dist/doc/man
export INFOPATH=/usr/local/texlive/2013/texmf-dist/doc/info
#branchy pathy stuff:
export BRANCH=trunk
export ORIGINAL_PATH=/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/texlive/2013/bin/x86_64-darwin
export PATH=/usr/bin:/Users/mperrone/src/$BRANCH/bin:$ORIGINAL_PATH
export PYTHONPATH=/Users/mperrone/src/$BRANCH/lib

switch_branch () {
    export BRANCH=$1
    export PATH=$ORIGINAL_PATH:/Users/mperrone/src/$BRANCH/bin
    export PYTHONPATH=/Users/mperrone/src/$BRANCH/lib
}
alias pinfo='echo -e "\x1B[0;31mbranch: \x1B[0;36m$BRANCH"; echo -e "\x1B[0;31mpath:\x1B[0m$PATH" | sed -e "s/:/  /g" -e "s/path/path:/g"; echo -e "\x1B[0;31mpythonpath:  \x1B[0m$PYTHONPATH"'


#bash settings
export HISTFILESIZE=30000
export HISTCONTROL=ignoredups
shopt -s histappend #append to the bash history file rather than overwriting it
export PROMPT_COMMAND='hpwd=$(history 1); hpwd="${hpwd# *[0-9]*  }"; if [[ ${hpwd%% *} == "cd" ]]; then cwd=$OLDPWD; else cwd=$PWD; fi; echo "cd $cwd && $hpwd" >> ~/.bash_directory_history;if [[ `uname` != "Linux" ]];then update_terminal_cwd; fi'
shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
export MANPAGER="less -X" # Don’t clear the screen after quitting a manual page
set -o vi

colorizeprompt () {
  local YELLOW="\[\033[0;33m\]"
  local BLUE="\[\033[0;34m\]"
  local CYAN="\[\033[0;36m\]"
  local WHITE="\[\033[0;37m\]"
  export PS1="$WHITE\t $CYAN\u$WHITE@$YELLOW\h\[\033[00m\]:$BLUE\w\[\033[00m\] $ "
} 
colorizeprompt

