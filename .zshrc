#!/bin/zsh

## This is the entrypoint of zsh config.

# First, source all shell agnostic config.
source $DOT_FILES/.shellrc

# Then, do zsh specific things.

bindkey -v

setopt APPEND_HISTORY # append instead of replace, all zshells do that
setopt INC_APPEND_HISTORY # save after every command instead of on exit
setopt EXTENDED_HISTORY # save time and run time length
export HISTSIZE=10000 # commands loaded into memory
export SAVEHIST=50000 # commands saved in the file
export HISTFILE="$XDG_STATE_HOME"/zsh/history

setopt GLOB_DOTS # includes .* files in *

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

autoload -U compinit && compinit
autoload -U promptinit && promptinit
autoload -U colors && colors

eval "$(starship init zsh)"

bindkey "^?" backward-delete-char # Allow backspace to delete stuff in prompt insert mode

# Do reverse history search with control-R, like in bash
bindkey "^R" history-incremental-search-backward

# Caveat from brew install zsh-autosuggestions:
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
