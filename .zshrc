autoload -U promptinit && promptinit
autoload -U colors && colors
setopt PROMPT_SUBST

PROMPT="%? %{$fg[white]%}%* %{$fg[cyan]%}%n%{$fg[white]%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg[blue]%}%~ %{$reset_color%}\$(get_git_branch) $ "
#time name@location:~/working/dir (branch)$
