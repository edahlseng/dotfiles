#!/usr/bin/env bash
#
# link links dotfiles to their proper place.

set -e

parentDirectory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
dotfilesRoot=$(cd "$(dirname "${parentDirectory}")" && pwd -P)

source "${parentDirectory}/logging.sh"

setupGitConfig() {
	if ! [ -f git/gitconfig.local.symlink ]; then
		info 'Setting up gitconfig'

		git_credential='cache'
		if [ "$(uname -s)" == "Darwin" ]; then
			git_credential='osxkeychain'
		fi

		user ' - What is your github author name?'
		read -e git_authorname
		user ' - What is your github author email?'
		read -e git_authoremail

		sed -e "s/AUTHORNAME/${git_authorname}/g" -e "s/AUTHOREMAIL/${git_authoremail}/g" -e "s/GIT_CREDENTIAL_HELPER/${git_credential}/g" git/gitconfig.local.symlink.example > git/gitconfig.local.symlink

		success 'gitconfig'
	fi
}

linkFile() {
	local src="${1}" dst="${2}"

	local overwrite= backup= skip=
	local action=

	if [ -f "${dst}" ] || [ -d "${dst}" ] || [ -L "${dst}" ]; then
		if [ "${overwrite_all}" == "false" ] && [ "${backup_all}" == "false" ] && [ "${skip_all}" == "false" ]; then
			local currentSrc="$(readlink $dst)"

			if [ "${currentSrc}" == "${src}" ]; then
				skip=true;
			else
				user "File already exists: ${dst} ($(basename "${src}")), what do you want to do?\n\
				[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
				read -n 1 action

				case "${action}" in
					o )
					overwrite=true;;
					O )
					overwrite_all=true;;
					b )
					backup=true;;
					B )
					backup_all=true;;
					s )
					skip=true;;
					S )
					skip_all=true;;
					* )
					;;
				esac
			fi
		fi

		overwrite=${overwrite:-$overwrite_all}
		backup=${backup:-$backup_all}
		skip=${skip:-$skip_all}

		if [ "${overwrite}" == "true" ]; then
			rm -rf "${dst}"
			success "removed ${dst}"
		fi

		if [ "${backup}" == "true" ]; then
			mv "${dst}" "${dst}.backup"
			success "moved ${dst} to ${dst}.backup"
		fi

		if [ "${skip}" == "true" ]; then
			success "skipped ${src}"
		fi
	fi

	if [ "${skip}" != "true" ]; then
		ln -s "${1}" "${2}"
		success "linked ${1} to ${2}"
	fi
}

installDotfiles() {
	info 'Installing dotfiles'

	local overwrite_all=false backup_all=false skip_all=false

	# Get array of files regardless of special characters (like spaces) in the filenames
	while IFS='' read -r -d $'\0'; do
		destination="${HOME}/.$(basename "${REPLY%.*}")"
		linkFile "${REPLY}" "${destination}"
	done < <(find -H "$dotfilesRoot" -maxdepth 2 -name '*.symlink' -not -path '*.git*' -not -path '*.symlinkParent' -print0)
}

installDotfilesDirectory() {
	echo ""
	info 'Installing dotfiles directory'

	local overwrite_all=false backup_all=false skip_all=false

	linkFile "${dotfilesRoot}" "${HOME}/.dotfiles"
}

installLaunchAgents() {
	echo ""
	info 'Installing Launch Agents'

	local overwrite_all=false backup_all=false skip_all=false

	while IFS='' read -r -d $'\0'; do
		destination="${HOME}/Library/LaunchAgents/$(basename "${REPLY}")"
		launchctl unload "${destination}"
		linkFile "${REPLY}" "${destination}"
		launchctl load "${destination}"
	done < <(find -H "${dotfilesRoot}"/macos/LaunchAgents -maxdepth 1 -name '*.plist' -print0)

	while IFS='' read -r -d $'\0'; do
		info "Removing broken link: ${REPLY}"
		/bin/rm "${REPLY}"
	done < <(find "${HOME}"/Library/LaunchAgents -type l ! -exec test -e {} \; -print0)
}

# Startup
# ------------------------------------------------------------------------------

cd "${dotfilesRoot}"
echo ""

setupGitConfig
installDotfiles
installDotfilesDirectory
installLaunchAgents

echo ""
echo "  All installed!"
