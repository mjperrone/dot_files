dot_files
=========

My unix dot files

This is my home. I can get home by running the following commands:

```bash
#$DOT_FILES can be set in .{bash,zsh}rc, default is `~/dot_files`
git clone https://github.com/mjperrone/dot_files.git $DOT_FILES
source $DOT_FILES/setup/setup.sh
```

That will take the current user's config files, store them in ~/old_dot_files, and then put mine in their place, with a combination of copies and symlinks.

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

The structure of my dotfiles is roughly as follows:

* .vimrc is my vim config file(includes plugins with vundle)
* .bashrc and .zshrc have shell specific config for bash and zsh respectively
* .shellrc sources all the other shell config files and handles things related to PATH variables, and some general shell config stuff
  .bash_prompt sets the PS1 variable (prompt line)
* .shell_aliases has a bunch of my aliases
* .shell_functions has a bunch of my functions
* python_helpers/ has a few python scripts that are useful to pretend are shell commands
* .shell_secrets is being ignored by git, because it has secret things like server ips and exploring/creating projects that I only care to run on one machine.
* .git_functions are shell functions that relate to git specifically
* .inputrc is the readline init file
* completion/ has the auto completion scripts for git, ssh, ...
* setup/ contains the scripts to set up all the config files for a new machine, and to remove them.
* .pranks has a bunch of useless fun stuff with which one can mess with people
* Note: There are a handful of instances where functions are defined outside of
  `.bash_functions` and aliases outside of `.bash_aliases` to be groups with other
  logically connected units.


Some of the places/people from which I've stolen ideas:<a href=http://learnvimscriptthehardway.stevelosh.com/>Steve Losh</a>,<a href=http://dailyvim.blogspot.com/>DailyVim</a>, <https://github.com/revans/bash-it>,<https://github.com/linduxed/dotfiles>, <a href=http://www.linkedin.com/in/vinaysethmohta>Vinay Seth Mohta</a>, <a href=https://github.com/GeorgeErickson/dotfiles>George Erickson</a>, <a href=http://www.youtube.com/watch?v=aHm36-na4-4>Damian Conway</a>, <a href=https://github.com/Ziphilt/dotfiles>Cal Stepanian</a>, <a href=https://github.com/justinmk/config/>Justinmk(holy...)</a>, <a href=http://bilalquadri.com/blog/2014/03/02/harmonizing-with-vi-nature/>Bilal Quadri</a> and numerous other people slowly throughout this journey.


todo
=========
* fully flesh out the .bash_directory_history idea (saving WHERE a command was run along the actual command, so better replication of old commands is possible)
* make sure everything is compatible with ubuntu and somewhat with windows8(doesn't work on ubuntu because it won't source ~/.bashrc when its a link)
* default args to the setup script allowing different $DOT_FILES dirs to be set
  up automatically
* factor DOT_FILES into .shell_path (and find a better name for that file) for
  Path-y and Env-y config
* name tmux sessions by default, numbered or whatever
* make vimdiff usable
* set a python virtualenv up, and rbenv too while you're at it
* autopep8 on save
* iterm3 - json saved profiles
* make the setup scripts be idempotent, maybe also junk the old_bash_files
  thing, I'll never do this on someone else's computer and then revert, that's
silly af.
* fix `k` aliases in zsh
