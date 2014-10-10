#!/usr/bin/env bash
pinfo () { #path info
    echo -e "${_red}path: ${_reset}$PATH" | sed -e "s/:\//  \//g"
    echo -e "${_red}pythonpath:  ${_reset}$PYTHONPATH"
    echo -e "${_red}manpath:  ${_reset}$MANPATH"
    echo -e "${_red}infopath:  ${_reset}$INFOPATH"
}

function pginfo () { #postgres info
    echo -e "${_red}PGHOST: ${_reset}$PGHOST"
    echo -e "${_red}PGPORT: ${_reset}$PGPORT"
    echo -e "${_red}PGDATABASE: ${_reset}$PGDATABASE"
    echo -e "${_red}PGUSER: ${_reset}$PGUSER"
    if [[ -z "$PGPASSWORD" ]]; then
        echo -e "${_red}PGPASSWORD: ${_reset}<NOT set>"
    else
        echo -e "${_red}PGPASSWORD: ${_reset}<set>"
    fi
}

ip () { #print external ip address
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g; s/<.*>//g'
}

cdl () { cd "$*" && l; }

jump_branch () { #assumes svn branches are at ~/src/* (and currend PWD is in that tree)
    cd ~/src/$1/${PWD#$HOME/src/*/}/
}

fakefile () { #make a file of x MB
    perl -e "print '0' x 1024 x 1024 x $1" > $1-MB-fake-file.txt
}

rep () { #to be able to output stuff to a file that's being used to generate the input
    # for example `cat file.txt | wc -l | rep file.txt`
    # since this would fail `cat file.txt | wc -l > file.txt`
    # rep = replace
    TMPFILELOCATION=`mktemp -q /tmp/mpXXXXXXXXXXXXXXXX`
    cat >> $TMPFILELOCATION
    mv $TMPFILELOCATION $1
}

st () { #decide if it's a git or svn repo, print status based on result
    if [ -d .svn ]; then
        OUT=`svn status`
        if [ -z "$OUT" ]; then
            echo "svn repo, no status"
        else
            echo "$OUT"
        fi
    elif [ `git rev-parse --is-inside-work-tree 2>/dev/null` ]; then
        git status
    else
        echo 'neither git nor svn'
    fi
}

get_git_branch () { #if in git repo, return the branch. I currently only use
    #this for the bash prompt, hence the parens.
    if [ `git rev-parse --is-inside-work-tree 2>/dev/null` ]; then
        printf "("
        printf `git rev-parse --abbrev-ref HEAD | tr '\n' ' ' | trim`
        printf ")"
    fi
}

highlight_red () { #output std with strings matching the parameter highlighted red
    perl -pe "s/$1/${_red}$&${_reset}/g"
}

highlight_yellow () { #* * * * yellow
    perl -pe "s/$1/${_yellow}$&${_reset}/g"
}

gri () { grep -r -i "$*" .; } #search for the parameter here, recursively, case-insensitively

#todo help:
td(){
    cat ~/Dropbox/**/todo.txt | highlight_red \\-\\-.* | highlight_yellow \\*\\*\\*.*
    cat ~/Dropbox/**/todo.txt > ~/Dropbox/todo.txt #so I can read the current todo on my phone!
}
etd(){
    vi ~/Dropbox/**/todo.txt #edit todo lists
    cat ~/Dropbox/**/todo.txt > ~/Dropbox/todo.txt #so I can read the current todo on my phone!
}
decode() {
    echo `echo $1 | base64 --decode` | pjson
}

cd() {
    if [ -f "$*" ]; then
        builtin cd $(dirname "$*")
    else
        builtin cd "$*"
    fi
}
