#!/usr/bin/env bash
pinfo () { #path info
    echo -e "\x1B[0;31mbranch: \x1B[0;36m$BRANCH"
    echo -e "\x1B[0;31mpath: \x1B[0m$PATH" | sed -e "s/:\//  \//g"
    echo -e "\x1B[0;31mpythonpath:  \x1B[0m$PYTHONPATH"
    echo -e "\x1B[0;31mmanpath:  \x1B[0m$MANPATH"
    echo -e "\x1B[0;31minfopath:  \x1B[0m$infopath"
}

function pginfo () { #postgres info
    echo -e "\x1B[0;31mPGHOST: \x1B[0m$PGHOST"
    echo -e "\x1B[0;31mPGPORT: \x1B[0m$PGPORT"
    echo -e "\x1B[0;31mPGDATABASE: \x1B[0m$PGDATABASE"
    echo -e "\x1B[0;31mPGUSER: \x1B[0m$PGUSER"
    if [[ -z "$PGPASSWORD" ]]; then
        echo -e "\x1B[0;31mPGPASSWORD: <NOT set>"
    else
        echo -e "\x1B[0;31mPGPASSWORD: \x1B[0;36m<set>"
    fi
}

ip () { #print external ip address
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g; s/<.*>//g'
}

cdl () { cd "$1" && l; }

switch_branch () {
    export BRANCH=$1
    export PATH=$ORIGINAL_PATH:/Users/mperrone/src/$BRANCH/bin
    export PYTHONPATH=/Users/mperrone/src/$BRANCH/lib
}

jump_branch () { #assumes svn branches are at ~/src/* (and currend PWD is in that tree)
    cd ~/src/$1/${PWD#$HOME/src/*/}/
}

fakefile () { #make a file of x MB
    perl -e "print '0' x 1024 x 1024 x $1" > $1-MB-fake-file.txt
}    

rep () { #to be able to output stuff to a file that's being used to generate the input
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

#TODO: remove find_line_num and replace_line, do the job of vl_switch.. with sed/awk
find_line_num (){ #args: search string, file path
    grep -n -m 1 "$1" "$2" | cut -d: -f1
}

replace_line (){ #args: replacement string, line number, file path
    sed "$2s/.*/$1/" "$3" | rep "$3"
}

vl_switch_target_format () { #args: format
    LINE_NUM=`find_line_num "Tex_DefaultTargetFormat"  ~/.vim/bundle/vim-latex/ftplugin/tex.vim`
    replace_line "let g:Tex_DefaultTargetFormat = '$1'" 1 ~/.vim/bundle/vim-latex/ftplugin/tex.vim
}

vlpdf () { #tell latex-suite to output to pdf
    vl_switch_target_format pdf
}

vldvi () { #tell latex-suite to output to dvi
    vl_switch_target_format dvi
}

highlight_red () { #output std with strings matching the parameter highlighted red
    perl -pe "s/$1/\e[0;31m$&\e[0m/g"
}

highlight_yellow () { #* * * * yellow
    perl -pe "s/$1/\e[0;33m$&\e[0m/g"
}

gri () { grep -r -i "$*" .; }
gr () { grep -r  "$*" .; }

#todo help:
td(){
    cat ~/Dropbox/**/todo.txt | highlight_red \\-\\-.* | highlight_yellow \\*\\*\\*.*
    cat ~/Dropbox/**/todo.txt > ~/Dropbox/todo.txt #so I can read the current todo on my phone!
}
etd(){
    vi ~/Dropbox/**/todo.txt #edit todo lists
    cat ~/Dropbox/**/todo.txt > ~/Dropbox/todo.txt #so I can read the current todo on my phone!
}

