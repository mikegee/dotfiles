# Customize zsh here.
# This file was not provided in thoughtbot's dotfiles

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# put Homebrew stuff on the top of the PATH
# (/usr/local/bin is already in my PATH,
#  I don't know where to change the original definition.)
export PATH="./script:/usr/local/bin:$PATH"

# add user's bin to the path
if [ -d $HOME/bin ]; then
  export PATH="$HOME/bin:$PATH"
fi

cdpath=( $HOME/Projects $HOME/Projects/cmm )

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Include RVM
if [ -e "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
fi
