#!/bin/bash

git pull
git add --all
git commit -am "Changed file $*"
git push
