#!/usr/bin/env bash
ip () { #print external ip address
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' | sed 's/<.*>//g'
}

cdl () {
    cd "$1" && l
}

jump_branch () { #assumes svn branches are at ~/src/*
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

function st () { #decide if it's a git or svn repo, print status based on result
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

vlpdf () { #tell latex-suite to output to pdf
    LINE_NUM=`grep -n -m 1 "Tex_DefaultTargetFormat"  ~/.vim/bundle/vim-latex/ftplugin/tex.vim | cut -d: -f1`
    echo "$LINE_NUM"
    sed "${LINE_NUM}s/.*/let g:Tex_DefaultTargetFormat = 'pdf'/" ~/.vim/bundle/vim-latex/ftplugin/tex.vim | rep ~/.vim/bundle/vim-latex/ftplugin/tex.vim
}

vldvi () { #tell latex-suite to output to dvi
    LINE_NUM=`grep -n -m 1 "Tex_DefaultTargetFormat"  ~/.vim/bundle/vim-latex/ftplugin/tex.vim | cut -d: -f1`
    echo "$LINE_NUM"
    sed "${LINE_NUM}s/.*/let g:Tex_DefaultTargetFormat = 'dvi'/" ~/.vim/bundle/vim-latex/ftplugin/tex.vim | rep ~/.vim/bundle/vim-latex/ftplugin/tex.vim
}

highlight_red () { #output std with strings matching the parameter highlighted red
    perl -pe "s/$1/\e[0;31m$&\e[0m/g"
}

highlight_yellow () { #* * * * yellow
    perl -pe "s/$1/\e[0;33m$&\e[0m/g"
}
