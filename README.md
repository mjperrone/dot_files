# dot_files

My unix dot files


## Setup

```bash
#$DOT_FILES can be set in .{bash,zsh}rc, default is `~/dot_files`
git clone https://github.com/mjperrone/dot_files.git $DOT_FILES
source $DOT_FILES/setup/setup.sh
```

To install all the vim plugins:

```viml
vim "+call InstallVundle()"
```

When I'm done, I run:

```bash
source $DOT_FILES/setup/teardown.sh
rm -rf $DOT_FILES
```
And it's like I was never there!

Structure

* .vimrc is vim config file (includes plugins with vundle)
* .bashrc and .zshrc have shell specific config for bash and zsh respectively, and also trigger the .shell_* series
* .shellrc sources all the other shell config files and handles things related to PATH variables, and some general shell config stuff
* .shell_aliases has a bunch of aliases
* .shell_functions has a bunch of functions
* python_helpers/ has a few python scripts that are useful to pretend are shell commands
* .shell_secrets is being ignored by git, because it has secret things like server ips and exploring/creating projects that I only care to run on one machine.
* .git_functions are shell functions that relate to git specifically
* .inputrc is the readline init file
* setup/ contains the scripts to set up the config files for a new machine
