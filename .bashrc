if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if [ -f ~/.bash_switch_pg ]; then
    source ~/.bash_switch_pg
fi

#branchy pathy stuff:
export BRANCH=golden_set
export PATH=/usr/bin:/Users/mperrone/src/$BRANCH/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin
export PYTHONPATH=/Users/mperrone/src/$BRANCH/lib
export ORIGINAL_PATH=$PATH

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
export PROMPT_COMMAND='hpwd=$(history 1); hpwd="${hpwd# *[0-9]*  }"; if [[ ${hpwd%% *} == "cd" ]]; then cwd=$OLDPWD; else cwd=$PWD; fi; echo "cd $cwd && $hpwd" >> ~/.bash_directory_history'
shopt -s cmdhist #multiline saved as one line
shopt -s cdspell #autocorrect typos in path names when using cd
export MANPAGER="less -X" # Don’t clear the screen after quitting a manual page

branch_in_prompt (){
    if [ $BRANCH_IN_PROMPT ]; then
        echo '\e[0;35m$BRANCH'
    fi
}

colorizeprompt () {
  local YELLOW="\[\033[0;33m\]"
  local BLUE="\[\033[0;34m\]"
  local CYAN="\[\033[0;36m\]"
  local WHITE="\[\033[0;37m\]"
  export PS1="$WHITE\t $CYAN\u$WHITE@$YELLOW\h\[\033[00m\]:$BLUE\w\[\033[00m\] $ "
} 
colorizeprompt


#functions
ip () {
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' | sed 's/<.*>//g'
}
cdl () {
    cd "$1" && ls
}
pushrc () {
    scp ~/.bashrc $1:~/.bashrc
    scp ~/.bash_aliases $1:~/.bash_aliases
    scp ~/.bash_switch_pg $1:~/.bash_switch_pg
    scp ~/.vimrc $1:~/.vimrc
    scp ~/.inputrc $1:~/.inputrc
}
jump_branch () {
        cd ~/src/$1/${PWD#$HOME/src/*/}/
}
fakefile () {
    perl -e "print '0' x 1024 x 1024 x $1" > $1-MB-fake-file.txt
}    
function cd (){
    builtin cd "$@" 
    echo "$PWD" > ~/.bash_last_directory
}
