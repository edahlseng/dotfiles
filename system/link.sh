#!/usr/bin/env bash
#
# link links dotfiles to their proper place.

set -o errexit

parentDirectory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
dotfilesRoot=$(cd "$(dirname "${parentDirectory}")" && pwd -P)

source "${parentDirectory}/logging.sh"
source "${parentDirectory}/linking.sh"

setupGitConfig() {
	if ! [ -f git/gitconfig.local.symlink ]; then
		info 'Setting up gitconfig'

		git_credential='cache'
		if [ "$(uname -s)" == "Darwin" ]; then
			git_credential='osxkeychain'
		fi

		user ' - What is your github author name (i.e. "FIRST_NAME LAST_NAME")?'
		read -e git_authorname
		user ' - What is your github author email?'
		read -e git_authoremail

		sed -e "s/AUTHORNAME/${git_authorname}/g" -e "s/AUTHOREMAIL/${git_authoremail}/g" -e "s/GIT_CREDENTIAL_HELPER/${git_credential}/g" git/gitconfig.local.symlink.example > git/gitconfig.local.symlink

		success 'gitconfig'
	fi
}

installDotfilesFromSymlinkParent() {
	local sourceDirectory="${1}"
	local destinationDirectory="${2}"

	makeSymlinkParentDirectory "${sourceDirectory}" "${destinationDirectory}"

	# Get array of files regardless of special characters (like spaces) in the filenames
	# Use file descriptor 3 for read here, so that further reads inside of the loop work
	while IFS='' read -r -u 3 -d $'\0'; do
		linkFile "${REPLY}" "${destinationDirectory}/$(basename "${REPLY%.*}")"
	done 3< <(find -H "${sourceDirectory}" -maxdepth 1 -name '*.symlink' -not -path '*.git*' -print0)

	# Get array of files regardless of special characters (like spaces) in the filenames
	# Use file descriptor 3 for read here, so that further reads inside of the loop work
	while IFS='' read -r -u 3 -d $'\0'; do
		installDotfilesFromSymlinkParent "${REPLY}" "${destinationDirectory}/$(basename "${REPLY%.*}")"
	done 3< <(find -H "${sourceDirectory}" -maxdepth 1 -name '*.symlinkParent' -not -path '*.git*' -not -path "${sourceDirectory}" -print0)
}

installDotfiles() {
	info 'Installing dotfiles'

	local overwrite_all=false backup_all=false skip_all=false

	# Get array of files regardless of special characters (like spaces) in the filenames
	# Use file descriptor 3 for read here, so that further reads inside of the loop work
	while IFS='' read -r -u 3 -d $'\0'; do
		linkFile "${REPLY}" "${HOME}/.$(basename "${REPLY%.*}")"
	done 3< <(find -H "${dotfilesRoot}" -maxdepth 2 -name '*.symlink' -not -path '*.git*' -not -path '*.symlinkParent*' -print0)

	# TODO: Will also need to update documentation regarding symlink parent
	# Get array of files regardless of special characters (like spaces) in the filenames
	# Use file descriptor 3 for read here, so that further reads inside of the loop work
	while IFS='' read -r -u 3 -d $'\0'; do
		installDotfilesFromSymlinkParent "${REPLY}" "${HOME}/.$(basename "${REPLY%.*}")"
	done 3< <(find -H "${dotfilesRoot}" -maxdepth 2 -name '*.symlinkParent' -not -path '*.git*' -print0)
}

installDotfilesDirectory() {
	echo ""
	info 'Installing dotfiles directory'

	local overwrite_all=false backup_all=false skip_all=false

	linkFile "${dotfilesRoot}" "${HOME}/.dotfiles"
}

# Startup
# ------------------------------------------------------------------------------

cd "${dotfilesRoot}"
echo ""

linkFile "${dotfilesRoot}" ~/.dotfiles
setupGitConfig
installDotfiles
installDotfilesDirectory

# find the installers and run them iteratively
echo ""
echo "Running all dotfiles linkers..."
(find "${dotfilesRoot}" -name link.sh | grep -v system/link.sh | while read linker ; do sh -c "\"${linker}\"" ; done) 1> >(logAsInfo) 2> >(logAsError)

echo ""
echo "  All installed!"
