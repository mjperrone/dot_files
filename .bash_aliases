#!/usr/bin/env bash

#edit configs fast:
alias eb='vi $DOT_FILES/.bashrc'
alias eba='vi $DOT_FILES/.bash_aliases'
alias ebs='vi $DOT_FILES/.bash_secrets'
alias ebf='vi $DOT_FILES/.bash_functions'
alias ev='vi $DOT_FILES/.vimrc'

#reset configs fast:
alias sb='source $DOT_FILES/.bashrc; echo source $DOT_FILES/.bashrc'

#go places:
alias drop='cd ~/Dropbox'
alias dot='cd ~/dot_files'

#relative navigation:
L=".." #this remaps '..' to 'cd ..', '...' to 'cd ../..', etc
R="../"
for i in  {1..7}
do
    alias $L="cd $R"
    L="$L."
    R="$R../"
done
unset L
unset R

alias -- -='cd -' #this remaps '-' to 'cd -'

#list:
alias ls='ls -FG' #default color + directory flags
alias ll='ls -GlaF' #detailed ls
alias l='ll' #too lazy
alias l.='ls -ldF .*' #only hidden stuff
alias ld='command ls -daG */' #non-hidden directories
alias ld.='command ls -daG .*/' #hidden directories
alias lf='ls -p | grep -v "/$"' #non-hidden files
alias lf.='ls -ap | grep -v "/$" | grep "^\."' #hidden files

#grep:
alias grep='grep --exclude-dir=".svn" --color -I' #be colorful and ignore binary files and svn directories
alias egrep='egrep --color -I'
alias fgrep='fgrep --color -I'

#tools:
alias pjson='python $DOT_FILES/python_helpers/pprint-jl' #pretty print json
alias csv='python $DOT_FILES/python_helpers/csvcolumn.py' #split csvs
alias email='python $DOT_FILES/python_helpers/sendemail.py' #used to pipe to an email
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'" #remove trailing and leading whitespace
alias count='sort | uniq -c | sort -n' #count how many times things appear
alias len='wc -l | trim' #how many lines in the file
alias pysum='egrep "class |def "' #summary of a python files based on function and class names
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" #print out the directory structure in a tree format
alias intersect="grep -xF -f" #set intersection of two files
alias sshl='ssh -L 5555:localhost:5432' #easy ssh tunnel
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app' #locks screen on mac only
alias beep='say "done running command" && tput bel' #second part makes notification on mac

#abbreviations
alias hist='history'
alias k='kill %1'
alias diff='git --no-pager diff --no-index' #default git's colorful diff
alias h='head -1'
alias t='tail -1'
alias m='make'
alias qq='exit'

#spell check:
alias ci='vi'

#for eliot:
alias cls='clear;ls'
alias cl='clear;l'
#for puneet:
alias dir='ls -l'
#for george and http://xkcd.com/530/  mac only...
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 10'"

#fun:
alias fucking='sudo'
alias lol='l'
alias gg='telnet towel.blinkenlights.nl' #Star Wars: A New Hope. In ascii art.
