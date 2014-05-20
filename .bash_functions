#!/usr/bin/env bash
pinfo () { #path info
    echo -e "\x1B[0;31mpath: \x1B[0m$PATH" | sed -e "s/:\//  \//g"
    echo -e "\x1B[0;31mpythonpath:  \x1B[0m$PYTHONPATH"
    echo -e "\x1B[0;31mmanpath:  \x1B[0m$MANPATH"
    echo -e "\x1B[0;31minfopath:  \x1B[0m$INFOPATH"
}

function pginfo () { #postgres info
    echo -e "\x1B[0;31mPGHOST: \x1B[0m$PGHOST"
    echo -e "\x1B[0;31mPGPORT: \x1B[0m$PGPORT"
    echo -e "\x1B[0;31mPGDATABASE: \x1B[0m$PGDATABASE"
    echo -e "\x1B[0;31mPGUSER: \x1B[0m$PGUSER"
    if [[ -z "$PGPASSWORD" ]]; then
        echo -e "\x1B[0;31mPGPASSWORD: \x1B[0m<NOT set>"
    else
        echo -e "\x1B[0;31mPGPASSWORD: \x1B[0m<set>"
    fi
}

ip () { #print external ip address
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g; s/<.*>//g'
}

cdl () { cd "$1" && l; }

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

highlight_red () { #output std with strings matching the parameter highlighted red
    perl -pe "s/$1/\e[0;31m$&\e[0m/g"
}

highlight_yellow () { #* * * * yellow
    perl -pe "s/$1/\e[0;33m$&\e[0m/g"
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
