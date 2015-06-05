#!/user/bin/zsh bash

export DOT_FILES=~/dot_files

#TODO: completionrc?
source $DOT_FILES/.shellrc

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY #after every command instead of on exit
setopt EXTENDED_HISTORY #save time and run time length

setopt GLOB_DOTS # includes .* files in *

autoload -U promptinit && promptinit
autoload -U colors && colors
setopt PROMPT_SUBST


PROMPT="%? %{$fg[white]%}%D{%H:%M:%S} %{$fg[cyan]%}%n%{$fg[white]%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg[blue]%}%~ %{$reset_color%}\$(get_git_branch) $ "
#time name@location:~/working/dir (branch)$

export HISTSIZE=30000
export SAVEHIST=30000
export HISTFILE=~/.bash_history #TODO
