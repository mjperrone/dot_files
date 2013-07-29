#edit rcs:
alias eb='vi ~/dot_files/.bashrc'
alias eba='vi ~/dot_files/.bash_aliases'
alias ebpg='vi ~/dot_files/.bash_switch_pg'
alias sb='source ~/dot_files/.bashrc; echo source ~/dot_files/.bashrc'

#navigation:
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias -- -='cd -'

#list:
alias ls='ls -F --color'
alias ll='ls -GlaF'
alias l='ll'
alias l.='ls -ldF .*'
alias ld='command ls -d --color */'
alias ld.='command ls -da --color .*/'
alias lf='ls -p | grep -v "/$"'
alias lf.='ls -ap | grep -v "/$" | grep "^\."'

#history
alias hist='history'

#grep:
alias grep='grep --color'
alias g='grep'

#tools:
alias pjson='python ~/dot_files/python_helpers/pprint-jl'
alias csv='python ~/dot_files/python_helpers/csvcolumn.py'
alias email='python ~/dot_files/python_helpers/sendemail.py'
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'"
alias count='sort | uniq -c'
alias len='wc -l | trim'
alias h='head -1'
alias t='tail -1'

#version control:
alias st='svn status'

#random:
alias intersect="grep -xF -f"
alias sshl='ssh -L 5555:localhost:5432'
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app && exit' #for mac only
alias diff='git --no-pager diff --no-index'

#spell check:
alias ci='vi'
alias :wq='exit'
alias :q='exit' #sure, you're in vim...

#for eliot:
alias cls='clear;ls'
alias cl='clear;l'
#for puneet:
alias dir='ls -l'
#for george and http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 10'"


#fun:
alias lol='l'
alias gg='telnet towel.blinkenlights.nl'
alias beep='say "done running command"'

alias k='kill %1'


if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi
