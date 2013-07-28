ip () {
    curl -s "http://checkip.dyndns.org:8245/" | awk '{ print $6 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' | sed 's/<.*>//g'
}
cdl () {
    cd "$1" && ls
}
jump_branch () {
        cd ~/src/$1/${PWD#$HOME/src/*/}/
}
fakefile () {
    perl -e "print '0' x 1024 x 1024 x $1" > $1-MB-fake-file.txt
}    
function cd (){
    builtin cd "$@" 
    echo "$PWD" > ~/.bash_last_directory
}
