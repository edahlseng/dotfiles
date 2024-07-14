shouldAddFile() {
	if [[ -z "${1}" ]]; then
		echo "First parameter missing in call to internal \"addFile\" function"
		return -1
	fi

	if [[ -z "${2}" ]]; then
		echo "Second parameter missing in call to internal \"addFile\" function"
		return -1
	fi

	local src="${1}" dst="${2}"

	local overwrite= backup= skip=
	local action=

	if [ -f "${dst}" ] || [ -d "${dst}" ] || [ -L "${dst}" ]; then
		if [ "${overwrite_all}" == "false" ] && [ "${backup_all}" == "false" ] && [ "${skip_all}" == "false" ]; then
			local currentSrc="$(readlink ${dst})"

			if [ "${currentSrc}" == "${src}" ] || [[ -d "${dst}" && "${skipIfDirectory}" == "true" ]]; then
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
			success "Removed ${dst}"
		fi

		if [ "${backup}" == "true" ]; then
			mv "${dst}" "${dst}.backup"
			success "Moved ${dst} to ${dst}.backup"
		fi

		if [ "${skip}" == "true" ]; then
			success "Skipped ${src}"
		fi
	fi

	if [ "${skip}" != "true" ]; then
		return 0
	else
		return 1
	fi
}

linkFile() {
	local overwrite_all=false backup_all=false skip_all=false

	if [[ "${UNLINK}" == "true" ]]; then
		rm "${2}"
	else
		if shouldAddFile "${1}" "${2}"; then
			ln -s "${1}" "${2}"
			success "Linked ${1} to ${2}"
		fi
	fi
}

makeSymlinkParentDirectory() {
	local overwrite_all=false backup_all=false skip_all=false

	if skipIfDirectory="true" shouldAddFile "${1}" "${2}"; then
		mkdir -p "${2}"
		success "Created directory ${2}"
	fi
}
