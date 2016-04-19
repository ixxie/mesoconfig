#!/usr/bin/env bash
#
# bootstrap links dotfiles.

dot_root=$(pwd -P)

set -e

function link_file() {
    local src="$dot_root/$1"
    local dst="$HOME/$2"

    # Check for directory.
    if [ ! -e "${dst%/*}" ]; then
        read -r -p "No directory at target. Create a directory for '$dst' [y/n]? " prompt
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
        read -r -p "Directory '$dst' already exists. Do you wish to overwrite it [y/n]? " prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm -rf "$dst"
    elif [ -e "$dst" ]; then
        read -r -p "File '$dst' already exists. Do you wish to overwrite it [y/n]? " prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm "$dst"
    fi

    # Create symbolic link.
    echo "Symlinking $dst"
    ln -s "$src" "$dst"
}

# Taken from https://github.com/holman/dotfiles/blob/master/script/bootstrap
setup_gitconfig () {
  if [ ! -f git/.gitconfig.local ]; then
    git_credential='cache'
    
    if [ "$(uname -s)" == "Darwin" ]; then
      git_credential='osxkeychain'
    fi

    read -r -p "What is your GitHub author name? " git_authorname

    read -r -p "What is your github author email? " git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/.gitconfig.local.example > git/.gitconfig.local
  fi
}

function linker {
    link_file "bash/.bash_profile" ".bash_profile"
    link_file "bash/.bashrc" ".bashrc"
    link_file "git/.gitconfig" ".gitconfig"
    link_file "git/.gitignore" ".gitignore"
    link_file "git/.gitconfig.local" ".gitconfig.local"
}

setup_gitconfig
linker
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Running OSX-specific scripts."
    sh ./osx/defaults.sh
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Running Linux-specific scripts."
    # TODO
fi
