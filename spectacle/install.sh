#!/usr/bin/env zsh

if [[ "$(uname -s)" == "Darwin" ]]; then
	executedFile="${BASH_SOURCE[0]}"
else
	executedFile=$(readlink -f "${BASH_SOURCE[0]}")
fi
parentDirectory=$(cd "$(dirname "${executedFile}")" && pwd)

ln -f -s "${parentDirectory}"/Shortcuts.json ~/Library/Application\ Support/Spectacle/Shortcuts.json
