autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] )); then
	git="$commands[git]"
else
	git="/usr/bin/git"
fi

git_prompt_info() {
	ref=$($git symbolic-ref HEAD 2>/dev/null) || ref=$($git describe --tags --exact-match 2>/dev/null) || return

	echo "${ref#refs/heads/}"
}

gitDirty() {
	if $(! $git status -s &> /dev/null); then
		echo ""
	else
		if [[ $($git status --porcelain) == "" ]]
		then
			echo "on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
		else
			echo "on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
		fi
	fi
}

needPush() {
	if [ $($git rev-parse --is-inside-work-tree 2>/dev/null) ]; then
		number=$($git rev-list --count HEAD ^@{upstream} 2>/dev/null)

		if [[ $number == 0 ]]; then
			echo " "
		else
			echo " with %{$fg_bold[magenta]%}$number unpushed%{$reset_color%}"
		fi
	fi
}

directoryName() {
	echo "%{$fg_bold[black]%}%0~/%{$reset_color%}"
}

export PROMPT=$'\n$fg_bold[black]%m:%{$reset_color%} $(directoryName) $(gitDirty)$(needPush)\n› '
setPrompt () {
	export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
	setTitle
	setPrompt
}
