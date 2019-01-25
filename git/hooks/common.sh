changed_files="$(git diff-tree -r --name-only --no-commit-id ${1:-ORIG_HEAD} ${2:-HEAD})"

check_run() {
	fileNameRegex="$1"
	command="$2"

	if echo "$changed_files" | grep --quiet "$fileNameRegex"; then
		echo " * changes detected in $fileNameRegex"
		echo " * executing '$command'"
		eval "$command";
	fi
}
