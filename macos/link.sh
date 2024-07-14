#!/usr/bin/env bash
#
# links files to their proper place.

set -o errexit

parentDirectory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
dotfilesRoot=$(cd "$(dirname "${parentDirectory}")" && pwd -P)

source "${dotfilesRoot}/system/logging.sh"
source "${dotfilesRoot}/system/linking.sh"

# Startup
# ------------------------------------------------------------------------------

echo ""
if [[ -f "${HOME}/clean-downloads" ]]; then
    info "Skipping hard-linking of clean-downloads, as ~/clean-downloads already exists"
else
    info "Hard-linking clean-downloads to prevent sandbox errors"
    ln "${dotfilesRoot}/bin/clean-downloads" "${HOME}/clean-downloads"
fi

echo ""
info 'Installing Launch Agents'
mkdir -p "${HOME}/Library/LaunchAgents"

while IFS='' read -r -d $'\0'; do
	destination="${HOME}/Library/LaunchAgents/$(basename "${REPLY}")"
	launchctl unload "${destination}"
	linkFile "${REPLY}" "${destination}"
	info "Loading ${destination}"
	launchctl load "${destination}"
done < <(find -H "${dotfilesRoot}"/macos/LaunchAgents -maxdepth 1 -name '*.plist' -print0)

while IFS='' read -r -d $'\0'; do
	info "Removing broken link: ${REPLY}"
	/bin/rm "${REPLY}"
done < <(find "${HOME}"/Library/LaunchAgents -type l ! -exec test -e {} \; -print0)
