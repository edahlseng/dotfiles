#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

parentDirectory="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
dotfilesDirectory="$(cd "$( dirname "$parentDirectory" )" && pwd -P)"

source "$parentDirectory/logging.sh"

# Install homebrew if it doesn't already exist
if test ! $(which brew); then
	echo "  Installing Homebrew for you."

	# Install the correct homebrew for each OS type
	if test "$(uname)" = "Darwin"; then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
	fi
fi

# Upgrade homebrew
echo "› brew update"
brew update

install() {
	cd "$parentDirectory"
	# Run Homebrew through the Brewfile
	echo "› brew bundle"
	brew bundle -v

	# Uninstall all Homebrew formulae not listed in Brewfile
	brew bundle cleanup

	# find the installers and run them iteratively
	# TODO: will need to make sure we use the proper base directory for this command
	find "$dotfilesDirectory" -name install.sh | grep -v scripts/install.sh | while read installer ; do sh -c "\"${installer}\"" ; done

	# Python installers
	# TODO: should maybe move these into themed directories
	pip install bugwarrior "bugwarrior[jira]" jira
	pip3 install pylint
	cd -
}

# Install dependencies
set -o pipefail
info "installing dependencies"
if install | while read -r data; do info "$data"; done; then
	success "dependencies installed"
else
	fail "error installing dependencies"
	exit 1
fi
