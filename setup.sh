#! /bin/bash -x
export STR_IN_PROF=`grep "dot_files" ~/.bash_profile | grep "source" | grep "\.bashrc" | grep "then"`
if [ -z "$STR_IN_PROF" ]; then
    echo >> ~/.bash_profile "if [ -f ~/dot_files/.bashrc ]; then source ~/dot_files/.bashrc; fi"
else
    echo '' >> /dev/null
fi
