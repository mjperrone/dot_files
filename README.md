# dot_files

My unix dot files


## Setup

First install git. Then run the following commands to get this repo down and run the setup scripts:

```zsh
echo 'export DOT_FILES=/Users/mperrone/code/mjperrone/dot_files' > ~/.shell_secrets
source ~/.shell_secrets
mkdir -p $DOT_FILES
cd $DOT_FILES/../
git clone https://github.com/mjperrone/dot_files.git $DOT_FILES
source $DOT_FILES/setup/setup.sh
source $DOT_FILES/setup/mac.sh
```

## Contents

* .editrc is the config file for libedit: the line editor of many prompts
* .git_functions are shell functions that relate to git specifically
* .gitconfig is the git configuration
* .gitignore is this project's gitignore file
* .gitignore_global is the config for the new machine
* .inputrc is the config file for readline: a line editor of many prompts
* .psqlrc is the postgres config file
* .shell_aliases has a bunch of aliases
* .shell_functions has a bunch of functions
* .shell_path has PATH related config
* .shell_secrets is ignored by git but sourced by .shellrc
* .shellrc is the main entrypoint for custom zsh rc files, sourcing the others
* .tmux.conf is tmux config
* .zshrc has zshell specific config and will trigger .shell_rc
* config.cson has 
* init.lua is the hammerspoon config
* keybindings.json is VSCode keybindings config
* input.json
* .inputrc is the readline init file
* setup/ contains the scripts to set up the config files for a new machine
