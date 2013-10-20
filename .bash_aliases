#!/usr/bin/env bash

#edit configs fast:
alias eb='vi ~/dot_files/.bashrc'
alias eba='vi ~/dot_files/.bash_aliases'
alias ebs='vi ~/dot_files/.bash_secrets'
alias ebf='vi ~/dot_files/.bash_functions'
alias ebv='vi ~/dot_files/.vimrc'

#reset configs fast:
alias sb='source ~/dot_files/.bashrc; echo source ~/dot_files/.bashrc'
alias refresh_dot_files='source ~/dot_files/setup/teardown.sh; source ~/dot_files/setup/setup.sh'

#relative navigation:
L=".."
R="../"
for i in  {1..7}
do
    alias $L="cd $R"
    L="$L."
    R="$R../"
done
unset L
unset R
alias -- -='cd -'

#list:
alias ls='ls -FG' #default color + directory flags
alias ll='ls -GlaF' #detailed ls
alias l='ll' #too lazy
alias l.='ls -ldF .*' #only hidden stuff
alias ld='command ls -daG */' #non-hidden directories
alias ld.='command ls -daG .*/' #hidden directories
alias lf='ls -p | grep -v "/$"' #non-hidden files
alias lf.='ls -ap | grep -v "/$" | grep "^\."' #hidden files

#todo help:
alias td='cat ~/Dropbox/**/todo.txt | highlight_red \-\-.* | highlight_yellow "\\*\\*\\*.*"' #print todolists color coded
alias etd='vi ~/Dropbox/**/todo.txt' #edit todo lists

#grep:
alias grep='grep --color -I' #be colorful and ignore binary files
alias g='grep'
alias egrep='egrep --color -I'
alias eg='egrep'
alias fgrep='fgrep --color -I'
alias fg='fgrep'
alias gi='grep -i'

#tools:
alias pjson='python ~/dot_files/python_helpers/pprint-jl' #pretty print json
alias csv='python ~/dot_files/python_helpers/csvcolumn.py' #split csvs
alias email='python ~/dot_files/python_helpers/sendemail.py' #used to pipe to an email
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'" #remove trailing and leading whitespace
alias count='sort | uniq -c | sort -n' #count how many times things appear
alias len='wc -l | trim' #how many lines in the file
alias pysum='egrep "class |def "' #summary of a python files based on function and class names
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias intersect="grep -xF -f" #set intersectino of two files
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

#spell check:
alias ci='vi'
alias qq='exit'

#for eliot:
alias cls='clear;ls'
alias cl='clear;l'
#for puneet:
alias dir='ls -l'
#for george and http://xkcd.com/530/  mac only...
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 10'"

#fun:
alias lol='l'
alias gg='telnet towel.blinkenlights.nl' #Star Wars: A New Hope. In ascii art.
