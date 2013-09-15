#!/usr/bin/env bash
#edit rcs:
alias eb='vi ~/dot_files/.bashrc'
alias eba='vi ~/dot_files/.bash_aliases'
alias ebs='vi ~/dot_files/.bash_secrets'
alias ebf='vi ~/dot_files/.bash_functions'
alias sb='source ~/dot_files/.bashrc; echo source ~/dot_files/.bashrc'

#navigation:
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias -- -='cd -'

#list:
alias ls='ls -FG'
alias ll='ls -GlaF'
alias l='ll'
alias l.='ls -ldF .*'
alias ld='command ls -daG */'
alias ld.='command ls -daG .*/'
alias lf='ls -p | grep -v "/$"'
alias lf.='ls -ap | grep -v "/$" | grep "^\."'

#history
alias hist='history'

#todo help:
alias td='cat ~/Dropbox/**/todo.txt | highlight_red \-\-.* | highlight_yellow "\\*\\*\\*.*"'

#grep:
alias grep='grep --color'
alias g='grep'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
alias gri='grep -r -i'
alias gi='grep -i'

#tools:
alias pjson='python ~/dot_files/python_helpers/pprint-jl'
alias csv='python ~/dot_files/python_helpers/csvcolumn.py'
alias email='python ~/dot_files/python_helpers/sendemail.py'
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'"
alias count='sort | uniq -c | sort -n'
alias len='wc -l | trim'
alias h='head -1'
alias t='tail -1'
alias pysum='egrep "class |def "'

#random:
alias intersect="grep -xF -f"
alias sshl='ssh -L 5555:localhost:5432'
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app && exit' #for mac only

alias diff='git --no-pager diff --no-index'
alias k='kill %1'

#spell check:
alias ci='vi'
alias qq='exit'
alias :wq='exit'
alias :q='exit' #sure, you're in vim...

if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

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
alias gg='telnet towel.blinkenlights.nl'
alias beep='say "done running command"'
