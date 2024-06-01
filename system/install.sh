#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -o errexit
set -o pipefail

parentDirectory="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
dotfilesDirectory="$(cd "$( dirname "${parentDirectory}" )" && pwd -P)"

source "${parentDirectory}/logging.sh"

logAsInfo() {
	while read -r data; do
		info "${data}"
	done
}

logAsError() {
	while read -r data; do
		fail "${data}"
	done
}

# Install homebrew if it doesn't already exist
if test ! $(which brew); then
	echo "  Installing Homebrew for you."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 1> >(logAsInfo) 2> >(logAsError)
fi

# Upgrade homebrew
echo ""
echo "› brew update"
brew update 1> >(logAsInfo) 2> >(logAsError)

cd "${parentDirectory}"

# Run Homebrew through the Brewfile
echo ""
echo "› brew bundle"
brew bundle install -v --file="${parentDirectory}/Brewfile" 1> >(logAsInfo) 2> >(logAsError)
$(brew --prefix)/opt/fzf/install --key-bindings --completion --update-rc 1> >(logAsInfo) 2> >(logAsError) # Installs useful key bindings and fuzzy completion

# Uninstall all Homebrew formulae not listed in Brewfile
echo ""
echo "> brew bundle cleanup"
brew bundle cleanup --force --zap --file="${parentDirectory}/Brewfile" 1> >(logAsInfo) 2> >(logAsError)

# find the installers and run them iteratively
echo ""
echo "Running all dotfiles installers..."
(find "${dotfilesDirectory}" -name install.sh | grep -v system/install.sh | while read installer ; do sh -c "\"${installer}\"" ; done) 1> >(logAsInfo) 2> >(logAsError)

echo ""
success "Dependencies installed"
