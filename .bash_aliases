#!/usr/bin/env bash

#edit configs fast:
alias eb='vi ~/dot_files/.bashrc'
alias eba='vi ~/dot_files/.bash_aliases'
alias ebs='vi ~/dot_files/.bash_secrets'
alias ebf='vi ~/dot_files/.bash_functions'

#reset configs fast:
alias sb='source ~/dot_files/.bashrc; echo source ~/dot_files/.bashrc'
alias refresh_dot_files='source ~/dot_files/setup/teardown.sh; source ~/dot_files/setup/setup.sh'

#relative navigation:
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
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
alias td='cat ~/Dropbox/**/todo.txt | highlight_red \-\-.* | highlight_yellow "\\*\\*\\*.*"'

#grep:
alias grep='grep --color -I' #be colorful and ignore binary files
alias g='grep'
alias egrep='egrep --color -I'
alias eg='egrep'
alias fgrep='fgrep --color -I'
alias gri='grep -r -i'
alias gi='grep -i'

#tools:
alias pjson='python ~/dot_files/python_helpers/pprint-jl' #pretty print json
alias csv='python ~/dot_files/python_helpers/csvcolumn.py' #split csvs
alias email='python ~/dot_files/python_helpers/sendemail.py' #used to pipe to an email
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'" #remove trailing and leading whitespace
alias count='sort | uniq -c | sort -n' #count how many times things appear
alias len='wc -l | trim' #how many lines in the file
alias h='head -1'
alias t='tail -1'
alias pysum='egrep "class |def "' #summary of a python files based on function and class names

#random:
alias intersect="grep -xF -f" #set intersectino of two files
alias sshl='ssh -L 5555:localhost:5432' #easy ssh tunnel
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app && exit' #locks screen on mac only
alias diff='git --no-pager diff --no-index' #default git's colorful diff
alias k='kill %1'
alias hist='history'

#spell check:
alias ci='vi'
alias qq='exit'
alias :wq='exit'
alias :q='exit' #sure, you're in vim...
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

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
alias beep='say "done running command"'
