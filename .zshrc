#zmodload zsh/zprof
export DOT_FILES=/Users/mperrone/code/mjperrone/dot_files

source $DOT_FILES/.shellrc

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY #after every command instead of on exit
setopt EXTENDED_HISTORY #save time and run time length

setopt GLOB_DOTS # includes .* files in *
setopt extended_glob # uses zsh's extended globa syntax

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

# Do reverse history search with control-R, like in bash
bindkey "^R" history-incremental-search-backward

# call nvm use automatically whenever you enter a directory that contains an .nvmrc file
autoload -U add-zsh-hook
load-nvmrc() {
 if [[ -f .nvmrc && -r .nvmrc ]]; then
   nvm use >/dev/null
 elif [[ $(nvm version) != $(nvm version default)  ]]; then
   nvm use default >/dev/null
 fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
#zprof