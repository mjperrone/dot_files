dot_files
=========

My unix dot files

This is my home. I can get home by running the following commands:

```bash
#$DOT_FILES can be set in .bashrc, default is ~/dot_files
git clone https://github.com/mjperrone/dot_files.git $DOT_FILES
source $DOT_FILES/setup/setup.sh
```

That will take the current user's config files, store them in ~/old_dot_files, and then put mine in their place, with a combination of copies and symlinks.

When I'm done, I run:

```bash
source $DOT_FILES/setup/teardown.sh
rm -rf $DOT_FILES
```
And it's like I was never there! 

The structure of my dotfiles is roughly as follows:

* .vim/ has my vim plugins
* .vimrc is my vim config file
* .bashrc sources all the other bash config files and handles things related to PATH variables, the PS1 prompt, and some general bash config stuff
* .bash_aliases has a bunch of my personal aliases
* .bash_functions has a bunch of my personal functions
* python_helpers/ has a few python scripts that are useful to pretend are bash commands
* .bash_secrets is being ignored by git, because it has secret things like server locations/passwords/access keys for work and play, depending on the machine.
* .git_functions are bash functions that relate to git specifically
* .inputrc literally just sets tab autocompletion to case insensitive
* completion/ has the auto completion scripts for various commands
* setup/ contains the scripts to set up all the config files, and to remove them.
* .pranks has a bunch of useless fun stuff with which one can mess with people


A lot of credit to <a href=http://learnvimscriptthehardway.stevelosh.com/>Steve Losh</a>,<a href=http://dailyvim.blogspot.com/>DailyVim</a>, <https://github.com/revans/bash-it>,<https://github.com/linduxed/dotfiles>, <a href=http://www.linkedin.com/in/vinaysethmohta>Vinay Seth Mohta</a>, <a href=https://github.com/GeorgeErickson/dotfiles>George Erickson</a>, <a href=http://www.youtube.com/watch?v=aHm36-na4-4>Damian Conway</a>, <a href=https://github.com/Ziphilt/dotfiles>Cal Stepanian</a>, <a href=https://github.com/justinmk/config/>Justinmk(holy...)</a>, <a href=http://bilalquadri.com/blog/2014/03/02/harmonizing-with-vi-nature/>Bilal Quadri</a> and numerous other people slowly throughout this journey.


todo
=========
* fully flesh out the .bash_directory_history idea (saving WHERE a command was run along the actual command, so better replication of old commands is possible)
* make sure teardown cleans up everything (.bash_directory_history, for example)
* make sure everything is compatible with ubuntu and somewhat with windows8(doesn't work on red.dev.... because it wont source ~/.bashrc when its a link)
* make colors reasonable
* make sure the .vimrc is version-safe
* use more environment variables for portability
* get vundle to work on new machines
* replace hard locations with vars. I'm very guilty of that since I mostly just
  use one machine, but it will cause problems when I switch.
