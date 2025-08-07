# dot_files

My unix dot files

## Setup

Git is a prerequisite for this dev env setup. Get that, then run the following commands:

```zsh
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
# install ansible
brew install ansible
# check out this repo
DOT_FILES="$HOME/code/mjperrone/dot_files"
mkdir -p $DOT_FILES
git clone https://github.com/mjperrone/dot_files.git $DOT_FILES
```

Then to run the initial setup or to pull in the latest updates, run:

```zsh
cd ansible/
ansible-playbook main.yaml
```

There are also a few manual steps to take:

- Open hammerspoon, set it to launch at login, give it accessibility permissions
- Set the battery percent, volume control, and bluetooth to show in the menubar using the control center
- Set caps lock to escape

## Contents

* browser-shortcuts.html has bookmarks that enable mapping shortcut text to a basic url template like "wiki meta" -> "https://en.wikipedia.org/wiki/Special:Search/meta"
* .editrc is the config file for libedit: the line editor of many prompts
* .git_functions are shell functions that relate to git specifically
* .gitconfig is the git configuration
* .gitignore is this project's gitignore file
* .gitignore_global is the config for the new machine
* .inputrc is the config file for readline: a line editor of many prompts
* .psqlrc is the postgres config file
* .shell_aliases has a bunch of aliases
* .shell_functions has a bunch of functions
* .shell_exports has PATH related config
* .shell_secrets is ignored by git but sourced by .shellrc
* .shellrc is the main entrypoint shell agnostic config, sourcing many others
* .zshrc has zshell specific config and will trigger .shellrc
* init.lua is the hammerspoon config
* keybindings.json is VSCode keybindings config
* ansible/ contains the config ansible requires to set up these dot files

## Browser shortcuts

I like being able to type short strings into the address bar to quickly navigate to custom pages or custom searches. This is implemented differently in the different browsers.

In Firefox, you can do this with 'keywords' for bookmarks, and use `%s` as a placeholder for the string substitution. Since they are just bookmarks, you can use the bookmarks manager to import and export them. Go to the bookmarks manager (`shift-command-O`) and select `Import bookmarks from HTML...`.

In Chrome, you can do this with [custom search engines](https://support.google.com/chrome/answer/95426) and use `%s` for the string substitution. Unfortunately they have to be added manually. At the [search engine settings page](chrome://settings/searchEngines) you can add a new search engine with the shortcut as the keyword and the URL as the search string.

[browser-shortcuts.html](browser-shortcuts.html) is an HTML bookmark file which contains a list of browser shortcuts that I use.

# TODO:
- consoilidate ansible config into one playbook maybe with multiple roles
- dont install signal on work computer, so need roles that differentiate between work and personal