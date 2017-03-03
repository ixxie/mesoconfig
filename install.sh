#!/usr/bin/env bash

dot_root=$(pwd -P)

set -e

function link_file() {
    local src="$dot_root/$1"
    local dst="$HOME/$2"

    # Check for directory.
    if [ ! -e "${dst%/*}" ]; then
        read -r -p "$(tput setaf 3)No directory at target. Create a directory for '$dst' [y/n]? $(tput sgr0)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        mkdir -p "${dst%/*}"
    fi

    # Unlink if link already exists.
    if [ -L "$dst" ]; then
        unlink "$dst"
    fi

    # Check if overwriting directory or file.
    if [ -d "$dst" ]; then
        read -r -p "$(tput setaf 3)Directory '$dst' already exists. Do you wish to overwrite it [y/n]? $(tput sgr0)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm -rf "$dst"
    elif [ -e "$dst" ]; then
        read -r -p "$(tput setaf 3)File '$dst' already exists. Do you wish to overwrite it [y/n]? $(tput sgr0)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm "$dst"
    fi

    # Create symbolic link.
    echo "$(tput setaf 6)Symlinking$(tput sgr0) $dst"
    ln -s "$src" "$dst"
}

# Taken from https://github.com/holman/dotfiles/blob/master/script/bootstrap
setup_gitconfig () {
  if [ ! -f git/.gitconfig.local ]; then
    git_credential='cache'

    if [ "$(uname -s)" == "Darwin" ]; then
      git_credential='osxkeychain'
    fi

    read -r -p "$(tput setaf 3)What is your GitHub author name? $(tput sgr0)" git_authorname

    read -r -p "$(tput setaf 3)What is your github author email? $(tput sgr0)" git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/.gitconfig.local.example > git/.gitconfig.local
  fi
}

function linker {
    link_file "sh/.bash_profile" ".bash_profile"
    link_file "sh/.bashrc" ".bashrc"
    link_file "sh/base16-shell" ".config/base16-shell"
    link_file "sh/.zshrc" ".zshrc"
    link_file "sh/.zsh/" ".zsh"
    link_file "git/.gitconfig" ".gitconfig"
    link_file "git/.gitignore" ".gitignore"
    link_file "git/.gitconfig.local" ".gitconfig.local"
    link_file "vim/.vimrc" ".vimrc"
    link_file "vim/pack/" ".vim/pack"
    link_file "vim/colors/base16-eighties.vim" ".vim/colors/base16-eighties.vim"
}

echo "$(tput bold && tput setaf 2)Setting up .gitconfig$(tput sgr0)"
setup_gitconfig
echo "$(tput bold && tput setaf 2)Linking non-specific files.$(tput sgr0)"
linker
echo "$(tput bold && tput setaf 2)Initializing submodules.$(tput sgr0)"
git submodule update --init --recursive

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$(tput bold &&tput setaf 2)Running OSX-specific scripts.$(tput sgr0)"
    link_file "tmux/.tmux-osx.conf" ".tmux.conf"
    read -r -p "$(tput setaf 3)Run defaults.sh? $(tput sgr0)" prompt
    if [[ $prompt =~ ^[Yy]$ ]]; then
        sh ./osx/defaults.sh
    fi
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "$(tput bold && tput setaf 2)Running Linux-specific scripts.$(tput sgr0)"
    link_file "tmux/.tmux-linux.conf" ".tmux.conf"
    link_file "linux/xfce-term/" ".config/xfce4/terminal"
    link_file "linux/openbox/" ".config/openbox"
    link_file "linux/x/.xinitrc" ".xinitrc"
    link_file "linux/x/.Xresources" ".Xresources"
    link_file "linux/x/.xbindkeysrc" ".xbindkeysrc"
    link_file "linux/napapiiri/" ".themes/napapiiri"
    link_file "linux/i3/" ".config/i3"
    link_file "linux/polybar/" ".config/polybar"
    link_file "linux/compton/compton.conf" ".config/compton.conf"
fi
echo "$(tput bold && tput setaf 2)Done."$(tput sgr0)

