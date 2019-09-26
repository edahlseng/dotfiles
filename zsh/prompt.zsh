autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] )); then
	git="${commands[git]}"
else
	git="/usr/bin/git"
fi

git_prompt_info() {
	ref=$(${git} symbolic-ref HEAD 2>/dev/null) || ref=$(${git} describe --tags --exact-match 2>/dev/null) || return

	echo "${ref#refs/heads/}"
}

gitDirty() {
	if $(! ${git} status -s &> /dev/null); then
		echo ""
	else
		if [[ $(${git} status --porcelain) == "" ]]; then
			echo "on %{${fg_bold[green]}%}$(git_prompt_info)%{${reset_color}%}"
		else
			echo "on %{${fg_bold[red]}%}$(git_prompt_info)%{${reset_color}%}"
		fi
	fi
}

unpushedAndStashes() {
	local message=""

	if [ $(${git} rev-parse --is-inside-work-tree 2>/dev/null) ]; then
		local numberUnpushed=$(${git} rev-list --count HEAD ^@{upstream} 2>/dev/null || echo 0)
		local numberOfStashes=$(${git} rev-list --walk-reflogs --count refs/stash 2>/dev/null || echo 0)

		local transitionWord="with"

		if [[ ${numberUnpushed} != 0 ]]; then
			message="${message} with %{${fg_bold[magenta]}%}${numberUnpushed} unpushed%{${reset_color}%}"
			transitionWord="and"
		fi

		if [[ ${numberOfStashes} != 0 ]]; then
			local stashSuffix="es"
			if [[ ${numberOfStashes} == 1 ]]; then
				stashSuffix=""
			fi

			message="${message} ${transitionWord} %{$fg_bold[magenta]%}${numberOfStashes} stash${stashSuffix}%{${reset_color}%}"
		fi
	fi

	echo "${message}"
}

directoryName() {
	echo "%{${fg_bold[black]}%}%0~/%{${reset_color}%}"
}

export PROMPT=$'\n${fg_bold[black]}%m:%{${reset_color}%} $(directoryName) $(gitDirty)$(unpushedAndStashes)\n› '
setPrompt () {
	export RPROMPT="%{${fg_bold[cyan]}%}%{${reset_color}%}"
}

precmd() {
	setTitle
	setPrompt
}
