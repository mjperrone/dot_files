#!/usr/bin/env bash
ip () {
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' | sed 's/<.*>//g'
}
cdl () {
    cd "$1" && l
}
jump_branch () {
    cd ~/src/$1/${PWD#$HOME/src/*/}/
}
fakefile () {
    perl -e "print '0' x 1024 x 1024 x $1" > $1-MB-fake-file.txt
}    
rep () {
    TMPFILELOCATION=`mktemp -q /tmp/mpXXXXXXXXXXXXXXXX`
    cat >> $TMPFILELOCATION
    mv $TMPFILELOCATION $1
}
function st () {
    if [ -d .svn ]; then
        OUT=`svn status`
        if [ -z "$OUT" ]; then
            echo "svn repo, no status"
        else
            echo $OUT
        fi
    elif [ `git rev-parse --is-inside-work-tree 2>/dev/null` ]; then
        git status 
    else
        echo 'neither git nor svn'
    fi
}

vlpdf () {
    LINE_NUM=`grep -n -m 1 "Tex_DefaultTargetFormat"  ~/.vim/ftplugin/tex.vim | cut -d: -f1`
    echo "$LINE_NUM"
    sed "${LINE_NUM}s/.*/    TexLet g:Tex_DefaultTargetFormat = 'pdf'/" ~/.vim/ftplugin/tex.vim | rep ~/.vim/ftplugin/tex.vim
}

vldvi () {
    LINE_NUM=`grep -n -m 1 "Tex_DefaultTargetFormat"  ~/.vim/ftplugin/tex.vim | cut -d: -f1`
    echo "$LINE_NUM"
    sed "${LINE_NUM}s/.*/    TexLet g:Tex_DefaultTargetFormat = 'dvi'/" ~/.vim/ftplugin/tex.vim | rep ~/.vim/ftplugin/tex.vim
}

highlight_red () {
    perl -pe "s/$1/\e[0;31m$&\e[0m/g"
}
highlight_yellow () {
    perl -pe "s/$1/\e[0;33m$&\e[0m/g"
}

