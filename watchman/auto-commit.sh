#!/bin/zsh

git pull
echo "Files changed:" $*
git add --all
git commit -am "Changed file $*"
git push
