#!/user/bin/zsh bash

export DOT_FILES=~/dot_files

#TODO: completionrc?
source $DOT_FILES/.shellrc

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY #after every command instead of on exit
setopt EXTENDED_HISTORY #save time and run time length

setopt GLOB_DOTS # includes .* files in *

autoload -U compinit && compinit
setopt completeinword # tab complete from the front of a word
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

autoload -U promptinit && promptinit
autoload -U colors && colors
setopt PROMPT_SUBST


PROMPT="%? %{$fg[white]%}%D{%H:%M:%S} %{$fg[cyan]%}%n%{$fg[white]%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg[blue]%}%~ %{$reset_color%}\$(get_git_branch) $ "
#stauscCdeOfPreviousCommand time name@location:~/working/dir (branch)$

export HISTSIZE=30000
export SAVEHIST=30000
export HISTFILE=~/.bash_history #TODO


bindkey "^?" backward-delete-char # Allow backspace to delete stuff in prompt insert mode
