#!/bin/bash

git pull
echo $*
git add --all
git commit -am "Changed file $*"
git push
