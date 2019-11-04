#!/bin/bash

git add --all
git commit -am "Changed file $*"
git push
