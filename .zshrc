#!/bin/zsh

## This is the entrypoint of zsh config.

# First, source all shell agnostic config.
source $DOT_FILES/.shellrc

# Then, do zsh specific things.

setopt APPEND_HISTORY # append instead of replace, all zshells do that
setopt INC_APPEND_HISTORY # save after every command instead of on exit
setopt EXTENDED_HISTORY # save time and run time length
export HISTSIZE=10000 # commands loaded into memory
export SAVEHIST=50000 # commands saved in the file
export HISTFILE=~/.zsh_history

setopt GLOB_DOTS # includes .* files in *

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# autoload -U compinit && compinit # comment out bc convoy does this
autoload -U promptinit && promptinit
autoload -U colors && colors

setopt prompt_subst # allow parameter, command, and arithmetic substitutions in the prompt to allow the git branch
PROMPT="%? %{$fg[white]%}%D{%H:%M:%S} %{$fg[cyan]%}%n%{$fg[white]%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg[blue]%}%~ %{$reset_color%}\$(get_git_branch) $ "
#stauscCdeOfPreviousCommand time name@location:~/working/dir (branch)$

bindkey "^?" backward-delete-char # Allow backspace to delete stuff in prompt insert mode

# Do reverse history search with control-R, like in bash
bindkey "^R" history-incremental-search-backward
