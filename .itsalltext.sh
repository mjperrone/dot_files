#!/bin/sh
osascript -e 'tell application "System Events"
    tell application "Terminal" to activate
    end tell'
osascript -e "tell application \"Terminal\" to do script \"/usr/bin/Vim \\\"$@\\\"\""
