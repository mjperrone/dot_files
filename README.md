dot_files
=========

My unix dot files

This is my home. I can get home by running the following commands:

```bash
cd ~
git clone https://github.com/mjperrone/dot_files.git
source ~/dot_files/setup/setup.sh
```

That will take the current user's config files, store them in ~/old_dot_files, and then put mine in their place, with a combination of copies and symlinks.

When I'm done, I run:

```bash
source ~/dot_files/setup/teardown.sh
rm -rf ~/dot_files
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


A lot of credit to https://github.com/revans/bash-it and numerous other people slowly throughout this campaign.


todo
=========
* make the setups/teardown scripts deal with .bash_history
* fully flesh out the .bash_directory_history idea (saving WHERE a command was run along the actual command, so better replication of old commands is possible)
* make sure teardown cleans up everything (.bash_directory_history, for example)
* make .bash_profile and .bash_rc links
* make sure everything is compatible with ubuntu and somewhat with windows8
* make vlpdf and vldvi functions less gross
