#!/usr/bin/env bash

#uncategorized:
alias today='date +"%b_%d_%Y"'


#edit configs fast:
alias eb='vi $DOT_FILES/.bashrc'
alias eba='vi $DOT_FILES/.bash_aliases'
alias ebs='vi $DOT_FILES/.bash_secrets'
alias ebf='vi $DOT_FILES/.bash_functions'
alias ev='vi $DOT_FILES/.vimrc'

#reset configs fast:
alias sb='source $DOT_FILES/.bashrc; echo source $DOT_FILES/.bashrc'

#go places:
alias drop='cd "${DROPBOX_PATH}"'
alias dev='cd ~/Development'
alias ax='cd ~/Development/averagexkcd'
alias dot='cd $DOT_FILES'
alias note='cd "${DROPBOX_PATH}/Notes"'
alias notes='note'
alias food='cd "${DROPBOX_PATH}/food"'
alias rec='cd "${DROPBOX_PATH}/food/recipes"'

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

alias -- -='cd -' #this remaps '-' to 'cd -', don't ask me how

#list:
if [ `uname` = 'Linux' ] ; then
    alias ls='ls --color -F'
elif [ `uname` = 'Darwin' ] ; then
    alias ls='ls -FG' #default color + directory flags
fi
alias l='ls -la' #detailed ls
alias l.='ls -ld .*' #only hidden stuff
alias ld='command ls -daG */' #non-hidden directories
alias ld.='command ls -daG .*/' #hidden directories
alias lf='ls -p | grep -v "/$"' #non-hidden files
alias lf.='ls -ap | grep -v "/$" | grep "^\."' #hidden files

#grep:
alias grep='grep --exclude-dir=".svn" --color -I' #be colorful and ignore binary files and svn directories
alias egrep='egrep --color -I'
alias fgrep='fgrep --color -I'
alias ack='ack --pager="less -R"'
alias ag='ag -i --pager="less -R"'

#tools:
alias pjson='python $DOT_FILES/python_helpers/pprint-jl' #pretty print json
alias csv='python $DOT_FILES/python_helpers/csvcolumn.py' #split csvs
alias email='python $DOT_FILES/python_helpers/sendemail.py' #used to pipe to an email
alias trim="sed -e 's/^ *//g' -e 's/ *$//g'" #remove trailing and leading whitespace
alias count='sort | uniq -c | sort -n' #count how many times things appear
alias len='wc -l | trim' #how many lines given in stdin
alias pysum='egrep "class |def "' #quick outline of a python files based on function and class names
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" #print out the directory structure in a tree format
alias space='du -ks ./* | sort -n'
alias intersect="grep -xF -f" #set intersection of two files, linewise
alias sshl='ssh -L 5555:localhost:5432' #easy ssh tunnel
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app' #locks screen on mac only
alias beep='say "done running command" && tput bel' #second part makes notification on mac

#abbreviations
alias hist='history'
alias diff='git --no-pager diff --no-index' #default git's colorful diff
alias m='make'
alias qq='exit' #I use this all the time
alias vi='nvim'

#spell check:
alias ci='vi'
alias k='fc -s' # since I have vi mode, if I forget to hit ESC and hit k-enter,
#I expect the last command to run. this does that.
alias kk='fc -s -2' # and so on...
alias kkk='fc -s -3'

#for ben:
alias ben='set -o emacs'

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
